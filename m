From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 3/8] Sometimes the ISDN chip only controls the D-channel
Date: Sat, 28 Apr 2012 13:43:19 +0200
Message-ID: <1335613404-10187-4-git-send-email-kkeil@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52994 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab2D1LrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:25 -0400
In-Reply-To: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The B-channels are only accessed via the PCM backplane.
Add infrastruckture for this special mode.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/socket.c |    3 +++
 include/linux/mISDNhw.h     |    3 +++
 include/linux/mISDNif.h     |   13 +++++++++----
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index abe2d69..502bcf1 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -270,6 +270,7 @@ data_sock_release(struct socket *sock)
 		break;
 	case ISDN_P_LAPD_TE:
 	case ISDN_P_LAPD_NT:
+	case ISDN_P_B_PCM:
 	case ISDN_P_B_RAW:
 	case ISDN_P_B_HDLC:
 	case ISDN_P_B_X75SLP:
@@ -544,6 +545,7 @@ data_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 		err = create_l2entity(_pms(sk)->dev, &_pms(sk)->ch,
 				      sk->sk_protocol, maddr);
 		break;
+	case ISDN_P_B_PCM:
 	case ISDN_P_B_RAW:
 	case ISDN_P_B_HDLC:
 	case ISDN_P_B_X75SLP:
@@ -800,6 +802,7 @@ mISDN_sock_create(struct net *net, struct socket *sock, int proto, int kern)
 	case ISDN_P_NT_E1:
 	case ISDN_P_LAPD_TE:
 	case ISDN_P_LAPD_NT:
+	case ISDN_P_B_PCM:
 	case ISDN_P_B_RAW:
 	case ISDN_P_B_HDLC:
 	case ISDN_P_B_X75SLP:
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 4af8414..74d5734 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -5,6 +5,7 @@
  *   Basic declarations for the mISDN HW channels
  *
  * Copyright 2008  by Karsten Keil <kkeil@novell.com>
+ * Copyright 2009-2012  by Karsten Keil <kkeil@linux-pingi.de>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -148,6 +149,8 @@ struct bchannel {
 	u_int			state;
 	void			*hw;
 	int			slot;	/* multiport card channel slot */
+	int			pcm_tx;	/* PCM tx slot nr */
+	int			pcm_rx;	/* PCM rx slot nr */
 	struct timer_list	timer;
 	/* receive data */
 	struct sk_buff		*rx_skb;
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index b5e7f22..bdda647 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		21
+#define MISDN_RELEASE		24
 
 /* primitives for information exchange
  * generell format
@@ -229,7 +229,7 @@
 
 #define ISDN_P_B_MASK		0x1f
 #define ISDN_P_B_START		0x20
-
+#define ISDN_P_B_PCM		0x20
 #define ISDN_P_B_RAW		0x21
 #define ISDN_P_B_HDLC		0x22
 #define ISDN_P_B_X75SLP		0x23
@@ -360,8 +360,8 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_LOOP			0x0001
 #define MISDN_CTRL_CONNECT		0x0002
 #define MISDN_CTRL_DISCONNECT		0x0004
-#define MISDN_CTRL_PCMCONNECT		0x0010
-#define MISDN_CTRL_PCMDISCONNECT	0x0020
+#define MISDN_CTRL_GET_PCM_SLOTS	0x0010
+#define MISDN_CTRL_SET_PCM_SLOTS	0x0020
 #define MISDN_CTRL_SETPEER		0x0040
 #define MISDN_CTRL_UNSETPEER		0x0080
 #define MISDN_CTRL_RX_OFF		0x0100
@@ -381,6 +381,10 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_HFC_WD_INIT		0x4009
 #define MISDN_CTRL_HFC_WD_RESET		0x400A
 
+/* special PCM slot numbers */
+#define MISDN_PCM_SLOT_DISABLE	-1	/* PCM disabled */
+#define MISDN_PCM_SLOT_IGNORE	-2	/* PCM setting will be not changed */
+
 /* socket options */
 #define MISDN_TIME_STAMP		0x0001
 
@@ -389,6 +393,7 @@ struct mISDN_ctrl_req {
 	int		channel;
 	int		p1;
 	int		p2;
+	int		p3;
 };
 
 /* muxer options */
-- 
1.7.3.4
