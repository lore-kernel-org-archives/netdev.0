From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net: make neigh_priv_len in struct net_device 16bit instead of 8bit
Date: Thu, 12 Dec 2013 10:15:59 +0100
Message-ID: <1386839759-24042-1-git-send-email-bigeasy@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38869 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab3LLJQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 04:16:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neigh_priv_len is defined as u8. With all debug enabled struct
ipoib_neigh has 200 bytes. The largest part is sk_buff_head with 96
bytes and here the spinlock with 72 bytes.
The size value still fits in this u8 leaving some room for more.

On -RT struct ipoib_neigh put on weight and has 392 bytes. The main
reason is sk_buff_head with 288 and the fatty here is spinlock with 192
bytes. This does no longer fit into into neigh_priv_len and gcc
complains.

This patch changes neigh_priv_len from being 8bit to 16bit. Since the
following element (dev_id) is 16bit followed by a spinlock which is
aligned, the struct remains with a total size of 3200 (allmodconfig) /
2048 (with as much debug off as possible) bytes on x86-64.
On x86-32 the struct is 1856 (allmodconfig) / 1216 (with as much debug
off as possible) bytes long. The numbers were gained with and without
the patch to prove that this change does not increase the size of the
struct.

Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0ca8100..56da573 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1255,7 +1255,7 @@ struct net_device {
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
 	unsigned char		addr_assign_type; /* hw address assignment type */
 	unsigned char		addr_len;	/* hardware address length	*/
-	unsigned char		neigh_priv_len;
+	unsigned short		neigh_priv_len;
 	unsigned short          dev_id;		/* Used to differentiate devices
 						 * that share the same link
 						 * layer address
-- 
1.8.5.1
