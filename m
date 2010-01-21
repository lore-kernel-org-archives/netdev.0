From: James Chapman <jchapman@katalix.com>
Subject: [PATCH] l2tp: Fix a UDP socket reference count bug in the pppol2tp
	driver
Date: Thu, 21 Jan 2010 16:10:09 +0000
Message-ID: <20100121161009.5223.34288.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42315 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514Ab0AUQKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 11:10:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bug can cause a kernel stack trace when a tunnel socket is closed.

WARNING: at include/net/sock.h:435 udp_lib_unhash+0x117/0x120()
Pid: 1086, comm: openl2tpd Not tainted 2.6.33-rc1 #8
Call Trace:
 [<c119e9b7>] ? udp_lib_unhash+0x117/0x120
 [<c101b871>] ? warn_slowpath_common+0x71/0xd0
 [<c119e9b7>] ? udp_lib_unhash+0x117/0x120
 [<c101b8e3>] ? warn_slowpath_null+0x13/0x20
 [<c119e9b7>] ? udp_lib_unhash+0x117/0x120
 [<c11598a7>] ? sk_common_release+0x17/0x90
 [<c11a5e33>] ? inet_release+0x33/0x60
 [<c11577b0>] ? sock_release+0x10/0x60
 [<c115780f>] ? sock_close+0xf/0x30
 [<c106e542>] ? __fput+0x52/0x150
 [<c106b68e>] ? filp_close+0x3e/0x70
 [<c101d2e2>] ? put_files_struct+0x62/0xb0
 [<c101eaf7>] ? do_exit+0x5e7/0x650
 [<c1081623>] ? mntput_no_expire+0x13/0x70
 [<c106b68e>] ? filp_close+0x3e/0x70
 [<c101eb8a>] ? do_group_exit+0x2a/0x70
 [<c101ebe1>] ? sys_exit_group+0x11/0x20
 [<c10029b0>] ? sysenter_do_call+0x12/0x26

Signed-off-by: James Chapman <jchapman@katalix.com>

---

This patch may be a candidate for -stable.
---
 drivers/net/pppol2tp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 9fbb2eb..0b5d96e 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -756,6 +756,7 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 
 	/* Try to dequeue as many skbs from reorder_q as we can. */
 	pppol2tp_recv_dequeue(session);
+	sock_put(sock);
 
 	return 0;
 
@@ -772,6 +773,7 @@ discard_bad_csum:
 	UDP_INC_STATS_USER(&init_net, UDP_MIB_INERRORS, 0);
 	tunnel->stats.rx_errors++;
 	kfree_skb(skb);
+	sock_put(sock);
 
 	return 0;
 
@@ -1661,6 +1663,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 		if (tunnel_sock == NULL)
 			goto end;
 
+		sock_hold(tunnel_sock);
 		tunnel = tunnel_sock->sk_user_data;
 	} else {
 		tunnel = pppol2tp_tunnel_find(sock_net(sk), sp->pppol2tp.s_tunnel);

