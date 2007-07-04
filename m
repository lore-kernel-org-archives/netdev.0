From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -rc7 1/1] netpoll: Fix a leak-n-bug in netpoll_cleanup()
Date: Wed, 04 Jul 2007 16:36:41 +0530
Message-ID: <20070704110641.28497.92035.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57174 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761243AbXGDLIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[1/1] netpoll: Fix a leak-n-bug in netpoll_cleanup()

93ec2c723e3f8a216dde2899aeb85c648672bc6b applied excessive duct tape to
the netpoll beast's netpoll_cleanup(), thus substituting one leak with
another, and opening up a little buglet :-)

net_device->npinfo (netpoll_info) is a shared and refcounted object and
cannot simply be set NULL the first time netpoll_cleanup() is called.
Otherwise, further netpoll_cleanup()'s see np->dev->npinfo == NULL and
become no-ops, thus leaking. And it's a bug too: the first call to
netpoll_cleanup() would thus (annoyingly) "disable" other (still alive)
netpolls too. Maybe nobody noticed this because netconsole (only user
of netpoll) never supported multiple netpoll objects earlier.

This is a trivial and obvious one-line fixlet.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[ Andrew, this is diffed against 2.6.22-rc7 but applies successfully to
the 2.6.22-rc6-mm1 tree also. ]

---

 net/core/netpoll.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

---

diff -ruNp a/net/core/netpoll.c b/net/core/netpoll.c
--- a/net/core/netpoll.c	2007-07-02 22:11:21.000000000 +0530
+++ b/net/core/netpoll.c	2007-07-03 16:28:10.000000000 +0530
@@ -782,7 +782,6 @@ void netpoll_cleanup(struct netpoll *np)
 				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 			}
 
-			np->dev->npinfo = NULL;
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
 				skb_queue_purge(&npinfo->arp_tx);
 				skb_queue_purge(&npinfo->txq);
@@ -796,6 +795,7 @@ void netpoll_cleanup(struct netpoll *np)
 					kfree_skb(skb);
 				}
 				kfree(npinfo);
+				np->dev->npinfo = NULL;
 			}
 		}
 
