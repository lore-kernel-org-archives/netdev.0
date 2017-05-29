From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 08/13] nfp: support variable NSP response lengths
Date: Sun, 28 May 2017 17:52:59 -0700
Message-ID: <20170529005304.20847-9-jakub.kicinski@netronome.com>
References: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35942 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdE2Ayf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 20:54:35 -0400
Received: by mail-pg0-f52.google.com with SMTP id x64so15377425pgd.3
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 17:54:35 -0700 (PDT)
In-Reply-To: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to support extendable commands, where newer versions
of the management FW may provide more information.  Zero out
the communication buffer before passing control to NSP.  This
way if management FW is old and only fills in first N bytes,
the remaining ones will be zeros which extended ABI fields
should reserve as not supported/not available.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index 2fa9247bb23d..58cc3d532769 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -419,6 +419,14 @@ static int nfp_nsp_command_buf(struct nfp_nsp *nsp, u16 code, u32 option,
 		if (err < 0)
 			return err;
 	}
+	/* Zero out remaining part of the buffer */
+	if (out_buf && out_size && out_size > in_size) {
+		memset(out_buf, 0, out_size - in_size);
+		err = nfp_cpp_write(cpp, cpp_id, cpp_buf + in_size,
+				    out_buf, out_size - in_size);
+		if (err < 0)
+			return err;
+	}
 
 	ret = nfp_nsp_command(nsp, code, option, cpp_id, cpp_buf);
 	if (ret < 0)
-- 
2.11.0
