From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/14] nfp: add extended error messages
Date: Tue,  4 Apr 2017 16:12:33 -0700
Message-ID: <20170404231235.32027-13-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34355 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755304AbdDDXND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:03 -0400
Received: by mail-pg0-f52.google.com with SMTP id 21so165173320pgg.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:03 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow NSP to set option code even when error is reported.  This provides
a way for NSP to give user more precise information about why command
failed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   | 37 +++++++++++++++++-----
 1 file changed, 29 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 225d07815375..96bb5f6bd87b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -97,6 +97,13 @@ enum nfp_nsp_cmd {
 	__MAX_SPCODE,
 };
 
+static const struct {
+	int code;
+	const char *msg;
+} nsp_errors[] = {
+	{ 0, "success" } /* placeholder to avoid warnings */
+};
+
 struct nfp_nsp {
 	struct nfp_cpp *cpp;
 	struct nfp_resource *res;
@@ -149,6 +156,18 @@ void nfp_nsp_config_clear_state(struct nfp_nsp *state)
 	state->idx = 0;
 }
 
+static void nfp_nsp_print_extended_error(struct nfp_nsp *state, u32 ret_val)
+{
+	int i;
+
+	if (!ret_val)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(nsp_errors); i++)
+		if (ret_val == nsp_errors[i].code)
+			nfp_err(state->cpp, "err msg: %s\n", nsp_errors[i].msg);
+}
+
 static int nfp_nsp_check(struct nfp_nsp *state)
 {
 	struct nfp_cpp *cpp = state->cpp;
@@ -282,7 +301,7 @@ nfp_nsp_wait_reg(struct nfp_cpp *cpp, u64 *reg,
 static int nfp_nsp_command(struct nfp_nsp *state, u16 code, u32 option,
 			   u32 buff_cpp, u64 buff_addr)
 {
-	u64 reg, nsp_base, nsp_buffer, nsp_status, nsp_command;
+	u64 reg, ret_val, nsp_base, nsp_buffer, nsp_status, nsp_command;
 	struct nfp_cpp *cpp = state->cpp;
 	u32 nsp_cpp;
 	int err;
@@ -335,18 +354,20 @@ static int nfp_nsp_command(struct nfp_nsp *state, u16 code, u32 option,
 		return err;
 	}
 
+	err = nfp_cpp_readq(cpp, nsp_cpp, nsp_command, &ret_val);
+	if (err < 0)
+		return err;
+	ret_val = FIELD_GET(NSP_COMMAND_OPTION, ret_val);
+
 	err = FIELD_GET(NSP_STATUS_RESULT, reg);
 	if (err) {
-		nfp_warn(cpp, "Result (error) code set: %d command: %d\n",
-			 -err, code);
+		nfp_warn(cpp, "Result (error) code set: %d (%d) command: %d\n",
+			 -err, (int)ret_val, code);
+		nfp_nsp_print_extended_error(state, ret_val);
 		return -err;
 	}
 
-	err = nfp_cpp_readq(cpp, nsp_cpp, nsp_command, &reg);
-	if (err < 0)
-		return err;
-
-	return FIELD_GET(NSP_COMMAND_OPTION, reg);
+	return ret_val;
 }
 
 static int nfp_nsp_command_buf(struct nfp_nsp *nsp, u16 code, u32 option,
-- 
2.11.0
