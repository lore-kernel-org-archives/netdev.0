From: Thomas Graf <tgraf@suug.ch>
Subject: [NEIGH]: Combine neighbour cleanup and release
Date: Sun, 22 Jul 2007 12:35:19 +0200
Message-ID: <20070722103519.GH3651@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52983 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbXGVKe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 06:34:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces neigh_cleanup_and_release() to be used after a
neighbour has been removed from its neighbour table. Serves
as preparation to add event notifications.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/core/neighbour.c
===================================================================
--- net-2.6.orig/net/core/neighbour.c	2007-07-22 11:41:46.000000000 +0200
+++ net-2.6/net/core/neighbour.c	2007-07-22 11:42:02.000000000 +0200
@@ -104,6 +104,14 @@ static int neigh_blackhole(struct sk_buf
 	return -ENETDOWN;
 }
 
+static void neigh_cleanup_and_release(struct neighbour *neigh)
+{
+	if (neigh->parms->neigh_cleanup)
+		neigh->parms->neigh_cleanup(neigh);
+
+	neigh_release(neigh);
+}
+
 /*
  * It is random distribution in the interval (1/2)*base...(3/2)*base.
  * It corresponds to default IPv6 settings and is not overridable,
@@ -140,9 +148,7 @@ static int neigh_forced_gc(struct neigh_
 				n->dead = 1;
 				shrunk	= 1;
 				write_unlock(&n->lock);
-				if (n->parms->neigh_cleanup)
-					n->parms->neigh_cleanup(n);
-				neigh_release(n);
+				neigh_cleanup_and_release(n);
 				continue;
 			}
 			write_unlock(&n->lock);
@@ -213,9 +219,7 @@ static void neigh_flush_dev(struct neigh
 				NEIGH_PRINTK2("neigh %p is stray.\n", n);
 			}
 			write_unlock(&n->lock);
-			if (n->parms->neigh_cleanup)
-				n->parms->neigh_cleanup(n);
-			neigh_release(n);
+			neigh_cleanup_and_release(n);
 		}
 	}
 }
@@ -676,9 +680,7 @@ static void neigh_periodic_timer(unsigne
 			*np = n->next;
 			n->dead = 1;
 			write_unlock(&n->lock);
-			if (n->parms->neigh_cleanup)
-				n->parms->neigh_cleanup(n);
-			neigh_release(n);
+			neigh_cleanup_and_release(n);
 			continue;
 		}
 		write_unlock(&n->lock);
@@ -2094,11 +2096,8 @@ void __neigh_for_each_release(struct nei
 			} else
 				np = &n->next;
 			write_unlock(&n->lock);
-			if (release) {
-				if (n->parms->neigh_cleanup)
-					n->parms->neigh_cleanup(n);
-				neigh_release(n);
-			}
+			if (release)
+				neigh_cleanup_and_release(n);
 		}
 	}
 }
