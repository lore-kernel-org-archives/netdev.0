From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: [PATCH] Deadlock on ip_mc_list->lock
Date: Mon, 6 Oct 2003 16:03:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006140320.GB24082@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,
   for past few days I'm getting reproducible
complaint from net/ipv4/igmp.c:159, saying that it
attempts to lock spinlock which was already locked at
net/ipv4/igmp.c:1388. It happens when slp daemon goes down on
system shutdown.

   Currently this 'return -EINVAL' below is one I suspect from
being guilty, as it looks to me like that nobody is unlocking
spinlock & bh in this case, and so system dies horrible death
after this (saying that userspace scheduled while in_atomic:1).

  I do not know why it now fails with -EINVAL while it worked
in the past (I see no igmp.c changes between test6 and current bk,
yet test6 worked while current bk does not), but it might be caused 
by slpd update, and not by something in the kernel.
					Thanks,
						Petr Vandrovec
						vandrove@vc.cvut.cz



diff -urN linux-2.6.0-test6-c1451.dist/net/ipv4/igmp.c linux-2.6.0-test6-c1451/net/ipv4/igmp.c
--- linux-2.6.0-test6-c1451.dist/net/ipv4/igmp.c	2003-10-05 20:42:05.000000000 +0200
+++ linux-2.6.0-test6-c1451/net/ipv4/igmp.c	2003-10-06 15:53:10.000000000 +0200
@@ -1391,8 +1391,9 @@
 	sf_markstate(pmc);
 #endif
 	if (!delta) {
+		err = -EINVAL;
 		if (!pmc->sfcount[sfmode])
-			return -EINVAL;
+			goto out_unlock;
 		pmc->sfcount[sfmode]--;
 	}
 	err = 0;
@@ -1423,6 +1424,7 @@
 		igmp_ifc_event(pmc->interface);
 #endif
 	}
+out_unlock:
 	spin_unlock_bh(&pmc->lock);
 	return err;
 }
