From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] Fix NULL dereference in tcp_4_send_ack()
Date: Tue, 30 Sep 2008 20:13:29 +0400
Message-ID: <200809302013.30051.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
	Denis Lunev <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29133 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbYI3QFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 12:05:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix NULL dereference in tcp_4_send_ack().

As skb->dev is reset to NULL in tcp_v4_rcv() thus OOPS occurs:

BUG: unable to handle kernel NULL pointer dereference at 00000000000004d0
IP: [<ffffffff80498503>] tcp_v4_send_ack+0x203/0x250

Stack:  ffff810005dbb000 ffff810015c8acc0 e77b2c6e5f861600 a01610802e90cb6d
 0a08010100000000 88afffff88afffff 0000000080762be8 0000000115c872e8
 0004122000000000 0000000000000001 ffffffff80762b88 0000000000000020
Call Trace:
 <IRQ>  [<ffffffff80499c33>] tcp_v4_reqsk_send_ack+0x20/0x22
 [<ffffffff8049bce5>] tcp_check_req+0x108/0x14c
 [<ffffffff8047aaf7>] ? rt_intern_hash+0x322/0x33c
 [<ffffffff80499846>] tcp_v4_do_rcv+0x399/0x4ec
 [<ffffffff8045ce4b>] ? skb_checksum+0x4f/0x272
 [<ffffffff80485b74>] ? __inet_lookup_listener+0x14a/0x15c
 [<ffffffff8049babc>] tcp_v4_rcv+0x6a1/0x701
 [<ffffffff8047e739>] ip_local_deliver_finish+0x157/0x24a
 [<ffffffff8047ec9a>] ip_local_deliver+0x72/0x7c
 [<ffffffff8047e5bd>] ip_rcv_finish+0x38d/0x3b2
 [<ffffffff803d3548>] ? scsi_io_completion+0x19d/0x39e
 [<ffffffff8047ebe5>] ip_rcv+0x2a2/0x2e5
 [<ffffffff80462faa>] netif_receive_skb+0x293/0x303
 [<ffffffff80465a9b>] process_backlog+0x80/0xd0
 [<ffffffff802630b4>] ? __rcu_process_callbacks+0x125/0x1b4
 [<ffffffff8046560e>] net_rx_action+0xb9/0x17f
 [<ffffffff80234cc5>] __do_softirq+0xa3/0x164
 [<ffffffff8020c52c>] call_softirq+0x1c/0x28
 <EOI>  [<ffffffff8020de1c>] do_softirq+0x34/0x72
 [<ffffffff80234b8e>] local_bh_enable_ip+0x3f/0x50
 [<ffffffff804d43ca>] _spin_unlock_bh+0x12/0x14
 [<ffffffff804599cd>] release_sock+0xb8/0xc1
 [<ffffffff804a6f9a>] inet_stream_connect+0x146/0x25c
 [<ffffffff80243078>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff8045751f>] sys_connect+0x68/0x8e
 [<ffffffff80291818>] ? fd_install+0x5f/0x68
 [<ffffffff80457784>] ? sock_map_fd+0x55/0x62
 [<ffffffff8020b39b>] system_call_after_swapgs+0x7b/0x80

Code: 41 10 11 d0 83 d0 00 4d 85 ed 89 45 c0 c7 45 c4 08 00 00 00 74 07 41 8b 45 04 89 45 c8 48 8b 43 20 8b 4d b8 48 8d 55 b0 48 89 de <48> 8b 80 d0 04 00 00 48 8b b8 60 01 00 00 e8 20 ae fe ff 65 48
RIP  [<ffffffff80498503>] tcp_v4_send_ack+0x203/0x250
 RSP <ffffffff80762b78>
CR2: 00000000000004d0


Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

---
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1b4fee2..011478e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -618,7 +618,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(skb->dst->dev);
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));

