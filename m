From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: [PATCH 2/2] Bluetooth: Fix crash with incoming L2CAP connections
Date: Sat, 16 Jul 2011 01:30:21 -0300
Message-ID: <1310790621-28510-3-git-send-email-padovan@profusion.mobi>
References: <1310790621-28510-1-git-send-email-padovan@profusion.mobi>
 <1310790621-28510-2-git-send-email-padovan@profusion.mobi>
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, Ilia Kolomisnky <iliak@ti.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35522 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab1GPEbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2011 00:31:14 -0400
In-Reply-To: <1310790621-28510-2-git-send-email-padovan@profusion.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilia Kolomisnky <iliak@ti.com>

Another regression fix considering incomming l2cap connections with
defer_setup enabled. In situations when incomming connection is
extracted with l2cap_sock_accept, it's bt_sock info will have
'parent' member zerroed, but 'parent' may be used unconditionally
in l2cap_conn_start() and l2cap_security_cfm() when defer_setup
is enabled.

Backtrace:
[<bf02d5ac>] (l2cap_security_cfm+0x0/0x2ac [bluetooth]) from [<bf01f01c>] (hci_event_pac
ket+0xc2c/0x4aa4 [bluetooth])
[<bf01e3f0>] (hci_event_packet+0x0/0x4aa4 [bluetooth]) from [<bf01a844>] (hci_rx_task+0x
cc/0x27c [bluetooth])
[<bf01a778>] (hci_rx_task+0x0/0x27c [bluetooth]) from [<c008eee4>] (tasklet_action+0xa0/
0x15c)
[<c008ee44>] (tasklet_action+0x0/0x15c) from [<c008f38c>] (__do_softirq+0x98/0x130)
 r7:00000101 r6:00000018 r5:00000001 r4:efc46000
[<c008f2f4>] (__do_softirq+0x0/0x130) from [<c008f524>] (do_softirq+0x4c/0x58)
[<c008f4d8>] (do_softirq+0x0/0x58) from [<c008f5e0>] (run_ksoftirqd+0xb0/0x1b4)
 r4:efc46000 r3:00000001
[<c008f530>] (run_ksoftirqd+0x0/0x1b4) from [<c009f2a8>] (kthread+0x84/0x8c)
 r7:00000000 r6:c008f530 r5:efc47fc4 r4:efc41f08
[<c009f224>] (kthread+0x0/0x8c) from [<c008cc84>] (do_exit+0x0/0x5f0)

Signed-off-by: Ilia Kolomisnky <iliak@ti.com>
Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
---
 net/bluetooth/l2cap_core.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 4fbf67e..7705e26 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -620,7 +620,8 @@ static void l2cap_conn_start(struct l2cap_conn *conn)
 					struct sock *parent = bt_sk(sk)->parent;
 					rsp.result = cpu_to_le16(L2CAP_CR_PEND);
 					rsp.status = cpu_to_le16(L2CAP_CS_AUTHOR_PEND);
-					parent->sk_data_ready(parent, 0);
+					if (parent)
+						parent->sk_data_ready(parent, 0);
 
 				} else {
 					sk->sk_state = BT_CONFIG;
@@ -4009,7 +4010,8 @@ static int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 					struct sock *parent = bt_sk(sk)->parent;
 					res = L2CAP_CR_PEND;
 					stat = L2CAP_CS_AUTHOR_PEND;
-					parent->sk_data_ready(parent, 0);
+					if (parent)
+						parent->sk_data_ready(parent, 0);
 				} else {
 					sk->sk_state = BT_CONFIG;
 					res = L2CAP_CR_SUCCESS;
-- 
1.7.6

