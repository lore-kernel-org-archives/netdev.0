From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] dccp: call inet_add_protocol after register_pernet_subsys in dccp_v4_init
Date: Tue, 20 Jun 2017 15:42:38 +0800
Message-ID: <9306540d6ad77c20e75b506df5cbd833c749f523.1497944558.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34961 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750960AbdFTHms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 03:42:48 -0400
Received: by mail-pf0-f193.google.com with SMTP id s66so21323279pfs.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 00:42:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now dccp_ipv4 works as a kernel module. During loading this module, if
one dccp packet is being recieved after inet_add_protocol but before
register_pernet_subsys in which v4_ctl_sk is initialized, a null pointer
dereference may be triggered because of init_net.dccp.v4_ctl_sk is 0x0.

Jianlin found this issue when the following call trace occurred:

[  171.950177] BUG: unable to handle kernel NULL pointer dereference at 0000000000000110
[  171.951007] IP: [<ffffffffc0558364>] dccp_v4_ctl_send_reset+0xc4/0x220 [dccp_ipv4]
[...]
[  171.984629] Call Trace:
[  171.984859]  <IRQ>
[  171.985061]
[  171.985213]  [<ffffffffc0559a53>] dccp_v4_rcv+0x383/0x3f9 [dccp_ipv4]
[  171.985711]  [<ffffffff815ca054>] ip_local_deliver_finish+0xb4/0x1f0
[  171.986309]  [<ffffffff815ca339>] ip_local_deliver+0x59/0xd0
[  171.986852]  [<ffffffff810cd7a4>] ? update_curr+0x104/0x190
[  171.986956]  [<ffffffff815c9cda>] ip_rcv_finish+0x8a/0x350
[  171.986956]  [<ffffffff815ca666>] ip_rcv+0x2b6/0x410
[  171.986956]  [<ffffffff810c83b4>] ? task_cputime+0x44/0x80
[  171.986956]  [<ffffffff81586f22>] __netif_receive_skb_core+0x572/0x7c0
[  171.986956]  [<ffffffff810d2c51>] ? trigger_load_balance+0x61/0x1e0
[  171.986956]  [<ffffffff81587188>] __netif_receive_skb+0x18/0x60
[  171.986956]  [<ffffffff8158841e>] process_backlog+0xae/0x180
[  171.986956]  [<ffffffff8158799d>] net_rx_action+0x16d/0x380
[  171.986956]  [<ffffffff81090b7f>] __do_softirq+0xef/0x280
[  171.986956]  [<ffffffff816b6a1c>] call_softirq+0x1c/0x30

This patch is to move inet_add_protocol after register_pernet_subsys in
dccp_v4_init, so that v4_ctl_sk is initialized before any incoming dccp
packets are processed.

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/dccp/ipv4.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f75482b..f85d901 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1033,33 +1033,34 @@ static int __init dccp_v4_init(void)
 {
 	int err = proto_register(&dccp_v4_prot, 1);
 
-	if (err != 0)
+	if (err)
 		goto out;
 
-	err = inet_add_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
-	if (err != 0)
-		goto out_proto_unregister;
-
 	inet_register_protosw(&dccp_v4_protosw);
 
 	err = register_pernet_subsys(&dccp_v4_ops);
 	if (err)
 		goto out_destroy_ctl_sock;
+
+	err = inet_add_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
+	if (err)
+		goto out_proto_unregister;
+
 out:
 	return err;
+out_proto_unregister:
+	unregister_pernet_subsys(&dccp_v4_ops);
 out_destroy_ctl_sock:
 	inet_unregister_protosw(&dccp_v4_protosw);
-	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
-out_proto_unregister:
 	proto_unregister(&dccp_v4_prot);
 	goto out;
 }
 
 static void __exit dccp_v4_exit(void)
 {
+	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 	unregister_pernet_subsys(&dccp_v4_ops);
 	inet_unregister_protosw(&dccp_v4_protosw);
-	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 	proto_unregister(&dccp_v4_prot);
 }
 
-- 
2.1.0
