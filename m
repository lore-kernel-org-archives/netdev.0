From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 14/15] nfp: bpf: byte swap the instructions
Date: Sun,  8 Oct 2017 21:04:16 -0700
Message-ID: <20171009040417.22172-15-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:57104 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbdJIEF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:58 -0400
Received: by mail-pf0-f174.google.com with SMTP id b85so1373476pfj.13
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:58 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device expects the instructions in little endian.  Make sure we
byte swap on big endian hosts.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index e0600d037773..f68052367db7 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1725,7 +1725,7 @@ static int nfp_bpf_optimize(struct nfp_prog *nfp_prog)
 	return 0;
 }
 
-static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog)
+static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog, __le64 *ustore)
 {
 	int i;
 
@@ -1737,6 +1737,8 @@ static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog)
 			return err;
 
 		nfp_prog->prog[i] = nfp_ustore_calc_ecc_insn(nfp_prog->prog[i]);
+
+		ustore[i] = cpu_to_le64(nfp_prog->prog[i]);
 	}
 
 	return 0;
@@ -1796,7 +1798,7 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 		goto out;
 	}
 
-	ret = nfp_bpf_ustore_calc(nfp_prog);
+	ret = nfp_bpf_ustore_calc(nfp_prog, (__force __le64 *)prog_mem);
 
 	res->n_instr = nfp_prog->prog_len;
 	res->dense_mode = false;
-- 
2.14.1
