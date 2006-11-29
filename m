From: Horms <horms@verge.net.au>
Subject: Re: [PATCH] [IPVS] use msleep_interruptable() instead of ssleep() aka msleep()
Date: Wed, 29 Nov 2006 09:58:35 +0900
Message-ID: <20061129005834.GA25535@verge.net.au>
References: <20061128062716.GA32377@verge.net.au> <Pine.LNX.4.58.0611281031190.2787@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dean Manners <deanm@ispone.com.au>,
	Wensong Zhan <wensong@linux-vs.org>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:19100 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1758733AbWK2BpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 20:45:02 -0500
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0611281031190.2787@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 28, 2006 at 10:35:01AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 28 Nov 2006, Horms wrote:
> 
> > Dean Manners notices that when an IPVS synchonisation daemons are
> > started the system load slowly climbs up to 1. This seems to be related
> > to the call to ssleep(1) (aka msleep(1000) in the main loop. Replacing
> > this with a call to msleep_interruptable() seems to make the problem go
> > away. Though I'm not sure that it is correct.
> 
> 	The same is needed for sync_backup_loop

Good point. It also seems as well to change it in fork_sync_thread()
and start_sync_thread(), though these are unlikely to be causing a problem.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

Dean Manners notices that when an IPVS synchonisation daemons are
started the system load slowly climbs up to 1. This seems to be related
to the call to ssleep(1) (aka msleep(1000) in the main loop. Replacing
this with a call to msleep_interruptable() seems to make the problem go
away. Though I'm not sure that it is correct.

This is the second edition of this patch, which replaces ssleep()
in the main loop for both the master and backup threads, as well
as some thread synchronisation code. The latter is just for thorougness
as it shouldn't be causing any problems.

Cc: Dean Manners <deanm@ispone.com.au>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_sync.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2006-11-28 15:30:00.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_sync.c	2006-11-29 09:46:27.000000000 +0900
@@ -657,7 +657,7 @@
 		if (stop_master_sync)
 			break;
 
-		ssleep(1);
+		msleep_interruptible(1000);
 	}
 
 	/* clean up the sync_buff queue */
@@ -714,7 +714,7 @@
 		if (stop_backup_sync)
 			break;
 
-		ssleep(1);
+		msleep_interruptible(1000);
 	}
 
 	/* release the sending multicast socket */
@@ -826,7 +826,7 @@
 	if ((pid = kernel_thread(sync_thread, startup, 0)) < 0) {
 		IP_VS_ERR("could not create sync_thread due to %d... "
 			  "retrying.\n", pid);
-		ssleep(1);
+		msleep_interruptible(1000);
 		goto repeat;
 	}
 
@@ -860,7 +860,7 @@
 	if ((pid = kernel_thread(fork_sync_thread, &startup, 0)) < 0) {
 		IP_VS_ERR("could not create fork_sync_thread due to %d... "
 			  "retrying.\n", pid);
-		ssleep(1);
+		msleep_interruptible(1000);
 		goto repeat;
 	}
 
