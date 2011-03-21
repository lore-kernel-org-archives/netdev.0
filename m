From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH v3] xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 16:37:03 +0800
Message-ID: <4D870E2F.50601@cn.fujitsu.com>
References: <4D86F1FD.3080009@cn.fujitsu.com>	<20110320.234606.183056322.davem@davemloft.net>	<4D8701C3.5010304@cn.fujitsu.com> <20110321.010037.59680394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57529 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752193Ab1CUIgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 04:36:36 -0400
In-Reply-To: <20110321.010037.59680394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 'xfrm: Move IPsec replay detection functions to a separate file'
  (9fdc4883d92d20842c5acea77a4a21bb1574b495)
introduce repl field to struct xfrm_state, and only initialize it
under SA's netlink create path, the other path, such as pf_key,
ipcomp/ipcomp6 etc, the repl field remaining uninitialize. So if
the SA is created by pf_key, any input packet with SA's encryption
algorithm will cause panic.

    int xfrm_input()
    {
        ...
        x->repl->advance(x, seq);
        ...
    }

This patch fixed it by introduce new function __xfrm_init_state().

Pid: 0, comm: swapper Not tainted 2.6.38-next+ #14 Bochs Bochs
EIP: 0060:[<c078e5d5>] EFLAGS: 00010206 CPU: 0
EIP is at xfrm_input+0x31c/0x4cc
EAX: dd839c00 EBX: 00000084 ECX: 00000000 EDX: 01000000
ESI: dd839c00 EDI: de3a0780 EBP: dec1de88 ESP: dec1de64
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process swapper (pid: 0, ti=dec1c000 task=c09c0f20 task.ti=c0992000)
Stack:
 00000000 00000000 00000002 c0ba27c0 00100000 01000000 de3a0798 c0ba27c0
 00000033 dec1de98 c0786848 00000000 de3a0780 dec1dea4 c0786868 00000000
 dec1debc c074ee56 e1da6b8c de3a0780 c074ed44 de3a07a8 dec1decc c074ef32
Call Trace:
 [<c0786848>] xfrm4_rcv_encap+0x22/0x27
 [<c0786868>] xfrm4_rcv+0x1b/0x1d
 [<c074ee56>] ip_local_deliver_finish+0x112/0x1b1
 [<c074ed44>] ? ip_local_deliver_finish+0x0/0x1b1
 [<c074ef32>] NF_HOOK.clone.1+0x3d/0x44
 [<c074ef77>] ip_local_deliver+0x3e/0x44
 [<c074ed44>] ? ip_local_deliver_finish+0x0/0x1b1
 [<c074ec03>] ip_rcv_finish+0x30a/0x332
 [<c074e8f9>] ? ip_rcv_finish+0x0/0x332
 [<c074ef32>] NF_HOOK.clone.1+0x3d/0x44
 [<c074f188>] ip_rcv+0x20b/0x247
 [<c074e8f9>] ? ip_rcv_finish+0x0/0x332
 [<c072797d>] __netif_receive_skb+0x373/0x399
 [<c0727bc1>] netif_receive_skb+0x4b/0x51
 [<e0817e2a>] cp_rx_poll+0x210/0x2c4 [8139cp]
 [<c072818f>] net_rx_action+0x9a/0x17d
 [<c0445b5c>] __do_softirq+0xa1/0x149
 [<c0445abb>] ? __do_softirq+0x0/0x149

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
Changelog:
  v2 -> v3 export __xfrm_init_state().
---
 include/net/xfrm.h    |    1 +
 net/xfrm/xfrm_state.c |   15 ++++++++++++++-
 net/xfrm/xfrm_user.c  |    2 +-
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 42a8c32..cffa5dc 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1430,6 +1430,7 @@ extern void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 extern u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
 extern int xfrm_init_replay(struct xfrm_state *x);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
+extern int __xfrm_init_state(struct xfrm_state *x, bool init_replay);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index d575f05..f83a3d1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1907,7 +1907,7 @@ int xfrm_state_mtu(struct xfrm_state *x, int mtu)
 	return res;
 }
 
-int xfrm_init_state(struct xfrm_state *x)
+int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
 {
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_mode *inner_mode;
@@ -1980,12 +1980,25 @@ int xfrm_init_state(struct xfrm_state *x)
 	if (x->outer_mode == NULL)
 		goto error;
 
+	if (init_replay) {
+		err = xfrm_init_replay(x);
+		if (err)
+			goto error;
+	}
+
 	x->km.state = XFRM_STATE_VALID;
 
 error:
 	return err;
 }
 
+EXPORT_SYMBOL(__xfrm_init_state);
+
+int xfrm_init_state(struct xfrm_state *x)
+{
+	return __xfrm_init_state(x, true);
+}
+
 EXPORT_SYMBOL(xfrm_init_state);
 
 int __net_init xfrm_state_init(struct net *net)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 706385a..fc152d2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -511,7 +511,7 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 
 	xfrm_mark_get(attrs, &x->mark);
 
-	err = xfrm_init_state(x);
+	err = __xfrm_init_state(x, false);
 	if (err)
 		goto error;
 
-- 
1.6.5.2


