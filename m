From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][AX25] ax25_route: make ax25_route_lock BH safe
Date: Mon, 11 Feb 2008 12:42:51 +0000
Message-ID: <20080211124251.GB3597@ff.dom.local>
References: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jann Traschewski <jann@gmx.de>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:43969 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYBKMfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 07:35:46 -0500
Received: by fk-out-0910.google.com with SMTP id z23so4483531fkz.5
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 04:35:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Subject: [AX25] ax25_route: make ax25_route_lock BH safe

> =================================
> [ INFO: inconsistent lock state ]
> 2.6.24-dg8ngn-p02 #1
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-R} usage.
> linuxnet/3046 [HC0[0]:SC1[2]:HE1:SE0] takes:
>  (ax25_route_lock){--.+}, at: [<f8a0cfb7>] ax25_get_route+0x18/0xb7 [ax25]
> {softirq-on-W} state was registered at:
...

This lockdep report shows that ax25_route_lock is taken for reading in
softirq context, and for writing in process context with BHs enabled.
So, to make this safe, all write_locks in ax25_route.c are changed to
_bh versions.


Reported-by: Jann Traschewski <jann@gmx.de>,
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp 2.6.24-mm1-/net/ax25/ax25_route.c 2.6.24-mm1+/net/ax25/ax25_route.c
--- 2.6.24-mm1-/net/ax25/ax25_route.c	2008-02-05 07:45:38.000000000 +0000
+++ 2.6.24-mm1+/net/ax25/ax25_route.c	2008-02-11 11:58:47.000000000 +0000
@@ -45,7 +45,7 @@ void ax25_rt_device_down(struct net_devi
 {
 	ax25_route *s, *t, *ax25_rt;
 
-	write_lock(&ax25_route_lock);
+	write_lock_bh(&ax25_route_lock);
 	ax25_rt = ax25_route_list;
 	while (ax25_rt != NULL) {
 		s       = ax25_rt;
@@ -68,7 +68,7 @@ void ax25_rt_device_down(struct net_devi
 			}
 		}
 	}
-	write_unlock(&ax25_route_lock);
+	write_unlock_bh(&ax25_route_lock);
 }
 
 static int __must_check ax25_rt_add(struct ax25_routes_struct *route)
@@ -82,7 +82,7 @@ static int __must_check ax25_rt_add(stru
 	if (route->digi_count > AX25_MAX_DIGIS)
 		return -EINVAL;
 
-	write_lock(&ax25_route_lock);
+	write_lock_bh(&ax25_route_lock);
 
 	ax25_rt = ax25_route_list;
 	while (ax25_rt != NULL) {
@@ -92,7 +92,7 @@ static int __must_check ax25_rt_add(stru
 			ax25_rt->digipeat = NULL;
 			if (route->digi_count != 0) {
 				if ((ax25_rt->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
-					write_unlock(&ax25_route_lock);
+					write_unlock_bh(&ax25_route_lock);
 					return -ENOMEM;
 				}
 				ax25_rt->digipeat->lastrepeat = -1;
@@ -102,14 +102,14 @@ static int __must_check ax25_rt_add(stru
 					ax25_rt->digipeat->calls[i]    = route->digi_addr[i];
 				}
 			}
-			write_unlock(&ax25_route_lock);
+			write_unlock_bh(&ax25_route_lock);
 			return 0;
 		}
 		ax25_rt = ax25_rt->next;
 	}
 
 	if ((ax25_rt = kmalloc(sizeof(ax25_route), GFP_ATOMIC)) == NULL) {
-		write_unlock(&ax25_route_lock);
+		write_unlock_bh(&ax25_route_lock);
 		return -ENOMEM;
 	}
 
@@ -120,7 +120,7 @@ static int __must_check ax25_rt_add(stru
 	ax25_rt->ip_mode      = ' ';
 	if (route->digi_count != 0) {
 		if ((ax25_rt->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
-			write_unlock(&ax25_route_lock);
+			write_unlock_bh(&ax25_route_lock);
 			kfree(ax25_rt);
 			return -ENOMEM;
 		}
@@ -133,7 +133,7 @@ static int __must_check ax25_rt_add(stru
 	}
 	ax25_rt->next   = ax25_route_list;
 	ax25_route_list = ax25_rt;
-	write_unlock(&ax25_route_lock);
+	write_unlock_bh(&ax25_route_lock);
 
 	return 0;
 }
@@ -152,7 +152,7 @@ static int ax25_rt_del(struct ax25_route
 	if ((ax25_dev = ax25_addr_ax25dev(&route->port_addr)) == NULL)
 		return -EINVAL;
 
-	write_lock(&ax25_route_lock);
+	write_lock_bh(&ax25_route_lock);
 
 	ax25_rt = ax25_route_list;
 	while (ax25_rt != NULL) {
@@ -174,7 +174,7 @@ static int ax25_rt_del(struct ax25_route
 			}
 		}
 	}
-	write_unlock(&ax25_route_lock);
+	write_unlock_bh(&ax25_route_lock);
 
 	return 0;
 }
@@ -188,7 +188,7 @@ static int ax25_rt_opt(struct ax25_route
 	if ((ax25_dev = ax25_addr_ax25dev(&rt_option->port_addr)) == NULL)
 		return -EINVAL;
 
-	write_lock(&ax25_route_lock);
+	write_lock_bh(&ax25_route_lock);
 
 	ax25_rt = ax25_route_list;
 	while (ax25_rt != NULL) {
@@ -216,7 +216,7 @@ static int ax25_rt_opt(struct ax25_route
 	}
 
 out:
-	write_unlock(&ax25_route_lock);
+	write_unlock_bh(&ax25_route_lock);
 	return err;
 }
 
@@ -492,7 +492,7 @@ void __exit ax25_rt_free(void)
 {
 	ax25_route *s, *ax25_rt = ax25_route_list;
 
-	write_lock(&ax25_route_lock);
+	write_lock_bh(&ax25_route_lock);
 	while (ax25_rt != NULL) {
 		s       = ax25_rt;
 		ax25_rt = ax25_rt->next;
@@ -500,5 +500,5 @@ void __exit ax25_rt_free(void)
 		kfree(s->digipeat);
 		kfree(s);
 	}
-	write_unlock(&ax25_route_lock);
+	write_unlock_bh(&ax25_route_lock);
 }
