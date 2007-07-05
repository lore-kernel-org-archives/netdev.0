From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH 1/2][IPV6] addrconf: fix timer deleting on exit
Date: Thu, 5 Jul 2007 13:12:46 +0200
Message-ID: <20070705111246.GB1569@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S\. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:50409 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755857AbXGELES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 07:04:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It looks like a timer function can be running and rearm
the timer after removing a ipv6 module.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.22-rc7-/net/ipv6/addrconf.c 2.6.22-rc7/net/ipv6/addrconf.c
--- 2.6.22-rc7-/net/ipv6/addrconf.c	2007-07-02 09:03:29.000000000 +0200
+++ 2.6.22-rc7/net/ipv6/addrconf.c	2007-07-05 12:27:22.000000000 +0200
@@ -2957,8 +2957,11 @@ restart:
 		read_unlock(&addrconf_hash_lock);
 	}
 
-	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
-	add_timer(&addr_chk_timer);
+	if (ipv6_dev_notf.notifier_call) {	/* exit time? */
+		addr_chk_timer.expires = time_before(next, jiffies + HZ)
+							? jiffies + HZ : next;
+		add_timer(&addr_chk_timer);
+	}
 	spin_unlock_bh(&addrconf_verify_lock);
 }
 
@@ -4281,9 +4284,13 @@ void __exit addrconf_cleanup(void)
 			 */
 		}
 	}
+
+	/* now exit flag for a timer... */
+	ipv6_dev_notf.notifier_call = NULL;
 	write_unlock_bh(&addrconf_hash_lock);
 
-	del_timer(&addr_chk_timer);
+	if (!del_timer_sync(&addr_chk_timer))
+		del_timer_sync(&addr_chk_timer);
 
 	rtnl_unlock();
 
