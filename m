From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] net: af_packet should disable preempt around
	sock_prot_inuse_add()
Date: Mon, 24 Nov 2008 16:02:40 +0300
Message-ID: <20081124130240.GB6255@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, dada1@cosmosbay.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:16093 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbYKXNCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:02:49 -0500
Received: by ey-out-2122.google.com with SMTP id 6so806622eyi.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 05:02:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BUG: using smp_processor_id() in preemptible [00000000] code: dhc

caller is sock_prot_inuse_add+0x24/0x42
Pid: 1776, comm: dhcpcd Tainted: G        W  2.6.28-rc6-next-2008

Call Trace:
 [<ffffffff8037fb72>] debug_smp_processor_id+0xca/0xe0
 [<ffffffff8046afc9>] sock_prot_inuse_add+0x24/0x42
 [<ffffffff804bd0a7>] packet_release+0x178/0x198
 [<ffffffff804695c6>] sock_release+0x20/0xc0
 [<ffffffff80469688>] sock_close+0x22/0x26
 [<ffffffff8029fa30>] __fput+0xeb/0x18a
 [<ffffffff8029fae4>] fput+0x15/0x17
 [<ffffffff8029cfac>] filp_close+0x67/0x72
 [<ffffffff8029d05c>] sys_close+0xa5/0xe4
 [<ffffffff8020b75b>] system_call_fastpath+0x16/0x1b

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 net/packet/af_packet.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b4870a3..8b7ddf7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -910,7 +910,9 @@ static int packet_release(struct socket *sock)
 	skb_queue_purge(&sk->sk_receive_queue);
 	sk_refcnt_debug_release(sk);
 
+	preempt_disable();
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
+	preempt_enable();
 	sock_put(sk);
 	return 0;
 }
@@ -1085,8 +1087,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 
 	write_lock_bh(&net->packet.sklist_lock);
 	sk_add_node(sk, &net->packet.sklist);
-	write_unlock_bh(&net->packet.sklist_lock);
 	sock_prot_inuse_add(net, &packet_proto, 1);
+	write_unlock_bh(&net->packet.sklist_lock);
 	return(0);
 out:
 	return err;
