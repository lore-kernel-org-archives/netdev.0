From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 6/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:12 -0500
Message-ID: <1289524032.5167.70.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60783 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206Ab0KLBIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:08:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 478181d..88be3ab 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1990,18 +1990,35 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d %-8lu\n",
-			   s,
-			   s->sk_protocol,
-			   nlk->pid,
-			   nlk->groups ? (u32)nlk->groups[0] : 0,
-			   sk_rmem_alloc_get(s),
-			   sk_wmem_alloc_get(s),
-			   nlk->cb,
-			   atomic_read(&s->sk_refcnt),
-			   atomic_read(&s->sk_drops),
-			   sock_i_ino(s)
-			);
+		/* Only expose kernel addresses to privileged readers */
+		if (capable(CAP_NET_ADMIN))
+			seq_printf(seq, "%p %-3d %-6d %08x %-8d "
+				   "%-8d %p %-8d %-8d %-8lu\n",
+				   s,
+				   s->sk_protocol,
+				   nlk->pid,
+				   nlk->groups ? (u32)nlk->groups[0] : 0,
+				   sk_rmem_alloc_get(s),
+				   sk_wmem_alloc_get(s),
+				   nlk->cb,
+				   atomic_read(&s->sk_refcnt),
+				   atomic_read(&s->sk_drops),
+				   sock_i_ino(s)
+				);
+		else
+			seq_printf(seq, "%d %-3d %-6d %08x %-8d "
+				   "%-8d %d %-8d %-8d %-8lu\n",
+				   0,
+				   s->sk_protocol,
+				   nlk->pid,
+				   nlk->groups ? (u32)nlk->groups[0] : 0,
+				   sk_rmem_alloc_get(s),
+				   sk_wmem_alloc_get(s),
+				   0,
+				   atomic_read(&s->sk_refcnt),
+				   atomic_read(&s->sk_drops),
+				   sock_i_ino(s)
+				);
 
 	}
 	return 0;



