From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 3/7] nfp: store NSP ABI version in state structure
Date: Sun, 19 Feb 2017 11:58:10 -0800
Message-ID: <20170219195814.40471-4-jakub.kicinski@netronome.com>
References: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        kubakici@wp.pl, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36244 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751663AbdBST6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 14:58:23 -0500
Received: by mail-pg0-f44.google.com with SMTP id v184so31033131pgv.3
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 11:58:22 -0800 (PST)
In-Reply-To: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We read the status register on each NSP open, we can store the NSP
ABI version in the state structure so that we don't have to read
it again.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   | 27 +++++++++++-----------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index f07f2fc3fba0..f2d737c3d1df 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -99,6 +99,10 @@ enum nfp_nsp_cmd {
 struct nfp_nsp {
 	struct nfp_cpp *cpp;
 	struct nfp_resource *res;
+	struct {
+		u16 major;
+		u16 minor;
+	} ver;
 };
 
 static int nfp_nsp_check(struct nfp_nsp *state)
@@ -120,11 +124,12 @@ static int nfp_nsp_check(struct nfp_nsp *state)
 		return -ENODEV;
 	}
 
-	if (FIELD_GET(NSP_STATUS_MAJOR, reg) != NSP_MAJOR ||
-	    FIELD_GET(NSP_STATUS_MINOR, reg) < NSP_MINOR) {
-		nfp_err(cpp, "Unsupported ABI %lld.%lld\n",
-			FIELD_GET(NSP_STATUS_MAJOR, reg),
-			FIELD_GET(NSP_STATUS_MINOR, reg));
+	state->ver.major = FIELD_GET(NSP_STATUS_MAJOR, reg);
+	state->ver.minor = FIELD_GET(NSP_STATUS_MINOR, reg);
+
+	if (state->ver.major != NSP_MAJOR || state->ver.minor < NSP_MINOR) {
+		nfp_err(cpp, "Unsupported ABI %hu.%hu\n",
+			state->ver.major, state->ver.minor);
 		return -EINVAL;
 	}
 
@@ -301,15 +306,9 @@ static int nfp_nsp_command_buf(struct nfp_nsp *nsp, u16 code, u32 option,
 	int ret, err;
 	u32 cpp_id;
 
-	err = nfp_cpp_readq(cpp, nfp_resource_cpp_id(nsp->res),
-			    nfp_resource_address(nsp->res) + NSP_STATUS, &reg);
-	if (err < 0)
-		return err;
-
-	if (FIELD_GET(NSP_STATUS_MINOR, reg) < 13) {
-		nfp_err(cpp, "NSP: Code 0x%04x with buffer not supported (ABI %lld.%lld)\n",
-			code, FIELD_GET(NSP_STATUS_MAJOR, reg),
-			FIELD_GET(NSP_STATUS_MINOR, reg));
+	if (nsp->ver.minor < 13) {
+		nfp_err(cpp, "NSP: Code 0x%04x with buffer not supported (ABI %hu.%hu)\n",
+			code, nsp->ver.major, nsp->ver.minor);
 		return -EOPNOTSUPP;
 	}
 
-- 
2.11.0
