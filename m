From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] nfp: bpf: improve handling for disabled BPF syscall
Date: Fri, 23 Sep 2016 22:23:59 +0200
Message-ID: <20160923202443.4130858-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I stumbled over a new warning during randconfig testing,
with CONFIG_BPF_SYSCALL disabled:

drivers/net/ethernet/netronome/nfp/nfp_net_offload.c: In function 'nfp_net_bpf_offload':
drivers/net/ethernet/netronome/nfp/nfp_net_offload.c:263:3: error: '*((void *)&res+4)' may be used uninitialized in this function [-Werror=maybe-uninitialized]
drivers/net/ethernet/netronome/nfp/nfp_net_offload.c:263:3: error: 'res.n_instr' may be used uninitialized in this function [-Werror=maybe-uninitialized]

As far as I can tell, this is a false positive caused by the compiler
getting confused about a function that is partially inlined, but it's
easy to avoid while improving the code:

The nfp_bpf_jit() stub helper for that configuration is unusual as it
is defined in a header file but not marked 'static inline'. By moving
the compile-time check into the caller using the IS_ENABLED() macro,
we can remove that stub and simplify the nfp_net_bpf_offload_prepare()
function enough to unconfuse the compiler.

Fixes: 7533fdc0f77f ("nfp: bpf: add hardware bpf offload")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h         | 10 ----------
 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c |  3 +++
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index fc220cd04115..87aa8a3e9112 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -192,20 +192,10 @@ struct nfp_bpf_result {
 	bool dense_mode;
 };
 
-#ifdef CONFIG_BPF_SYSCALL
 int
 nfp_bpf_jit(struct bpf_prog *filter, void *prog, enum nfp_bpf_action_type act,
 	    unsigned int prog_start, unsigned int prog_done,
 	    unsigned int prog_sz, struct nfp_bpf_result *res);
-#else
-int
-nfp_bpf_jit(struct bpf_prog *filter, void *prog, enum nfp_bpf_action_type act,
-	    unsigned int prog_start, unsigned int prog_done,
-	    unsigned int prog_sz, struct nfp_bpf_result *res)
-{
-	return -ENOTSUPP;
-}
-#endif
 
 int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 43f42f842eda..8acfb631a0ea 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -148,6 +148,9 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	unsigned int max_mtu;
 	int ret;
 
+	if (!IS_ENABLED(CONFIG_BPF_SYSCALL))
+		return -ENOTSUPP;
+
 	ret = nfp_net_bpf_get_act(nn, cls_bpf);
 	if (ret < 0)
 		return ret;
-- 
2.9.0
