From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] netdev: lockdep classes in register_netdevice Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Tue, 15 May 2007 07:31:01 +0200
Message-ID: <20070515053101.GA990@ff.dom.local>
References: <20070511.140309.59656886.davem@davemloft.net> <20070511141225.cf7a6909.akpm@linux-foundation.org> <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:34387 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754962AbXEOFY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 01:24:28 -0400
Content-Disposition: inline
In-Reply-To: <20070513.233937.99203647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 13, 2007 at 11:39:37PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Mon, 14 May 2007 08:07:00 +0200
> 
> > After sending this patch I was a little confused, when next
> > lockdep warning report appeared, and I thought - since this is 
> > not enough, this patch could be dumped. But now I changed my
> > mind: there are really many possibilities of strange connections
> > between locks taken from vlans, ppp (with pppoe), multicasts etc.
> > - that every one possibility less is a gain here.
>  ...
> > Of course, later, if somebody will find better solution, they could
> > be removed,
> 
> I already suggested a better fix, you ignored it.
> 
> For each unique netdev type, use a different locking class.
> 
> That will fix this forever, anything else is a situation specific
> band-aid (but then again isn't that what every lockdep annotation is
> :-).

So, I guess, you thought about something like this, plus
additional annotations in specific situations like vlan
(but some hint is needed, how much of this should be
considered). 

Jarek P.

--->

After initializing dev->_xmit_lock register_netdevice()
sets lockdep class according to dev->type.

Idea of this patch - by David Miller.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.22-/net/core/dev.c 2.6.22/net/core/dev.c
--- 2.6.22-/net/core/dev.c	2007-05-14 20:26:16.000000000 +0200
+++ 2.6.22/net/core/dev.c	2007-05-14 21:22:10.000000000 +0200
@@ -116,6 +116,7 @@
 #include <linux/dmaengine.h>
 #include <linux/err.h>
 #include <linux/ctype.h>
+#include <linux/if_arp.h>
 
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -217,6 +218,73 @@ extern void netdev_unregister_sysfs(stru
 #define	netdev_unregister_sysfs(dev)	do { } while(0)
 #endif
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+/*
+ * register_netdevice() inits dev->_xmit_lock and sets lockdep class
+ * according to dev->type
+ */
+static const unsigned short netdev_lock_type[] =
+	{ARPHRD_NETROM, ARPHRD_ETHER, ARPHRD_EETHER, ARPHRD_AX25,
+	 ARPHRD_PRONET, ARPHRD_CHAOS, ARPHRD_IEEE802, ARPHRD_ARCNET,
+	 ARPHRD_APPLETLK, ARPHRD_DLCI, ARPHRD_ATM, ARPHRD_METRICOM,
+	 ARPHRD_IEEE1394, ARPHRD_EUI64, ARPHRD_INFINIBAND, ARPHRD_SLIP,
+	 ARPHRD_CSLIP, ARPHRD_SLIP6, ARPHRD_CSLIP6, ARPHRD_RSRVD,
+	 ARPHRD_ADAPT, ARPHRD_ROSE, ARPHRD_X25, ARPHRD_HWX25,
+	 ARPHRD_PPP, ARPHRD_CISCO, ARPHRD_LAPB, ARPHRD_DDCMP,
+	 ARPHRD_RAWHDLC, ARPHRD_TUNNEL, ARPHRD_TUNNEL6, ARPHRD_FRAD,
+	 ARPHRD_SKIP, ARPHRD_LOOPBACK, ARPHRD_LOCALTLK, ARPHRD_FDDI,
+	 ARPHRD_BIF, ARPHRD_SIT, ARPHRD_IPDDP, ARPHRD_IPGRE,
+	 ARPHRD_PIMREG, ARPHRD_HIPPI, ARPHRD_ASH, ARPHRD_ECONET,
+	 ARPHRD_IRDA, ARPHRD_FCPP, ARPHRD_FCAL, ARPHRD_FCPL,
+	 ARPHRD_FCFABRIC, ARPHRD_IEEE802_TR, ARPHRD_IEEE80211,
+	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_VOID,
+	 ARPHRD_NONE};
+
+static const char *netdev_lock_name[] =
+	{"_xmit_NETROM", "_xmit_ETHER", "_xmit_EETHER", "_xmit_AX25",
+	 "_xmit_PRONET", "_xmit_CHAOS", "_xmit_IEEE802", "_xmit_ARCNET",
+	 "_xmit_APPLETLK", "_xmit_DLCI", "_xmit_ATM", "_xmit_METRICOM",
+	 "_xmit_IEEE1394", "_xmit_EUI64", "_xmit_INFINIBAND", "_xmit_SLIP",
+	 "_xmit_CSLIP", "_xmit_SLIP6", "_xmit_CSLIP6", "_xmit_RSRVD",
+	 "_xmit_ADAPT", "_xmit_ROSE", "_xmit_X25", "_xmit_HWX25",
+	 "_xmit_PPP", "_xmit_CISCO", "_xmit_LAPB", "_xmit_DDCMP",
+	 "_xmit_RAWHDLC", "_xmit_TUNNEL", "_xmit_TUNNEL6", "_xmit_FRAD",
+	 "_xmit_SKIP", "_xmit_LOOPBACK", "_xmit_LOCALTLK", "_xmit_FDDI",
+	 "_xmit_BIF", "_xmit_SIT", "_xmit_IPDDP", "_xmit_IPGRE",
+	 "_xmit_PIMREG", "_xmit_HIPPI", "_xmit_ASH", "_xmit_ECONET",
+	 "_xmit_IRDA", "_xmit_FCPP", "_xmit_FCAL", "_xmit_FCPL",
+	 "_xmit_FCFABRIC", "_xmit_IEEE802_TR", "_xmit_IEEE80211",
+	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_VOID",
+	 "_xmit_NONE"};
+
+static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
+
+static inline unsigned short netdev_lock_pos(unsigned short dev_type)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(netdev_lock_type); i++)
+		if (netdev_lock_type[i] == dev_type)
+			return i;
+	/* the last key is used by default */
+	return --i;
+}
+
+static inline void netdev_set_lockdep_class(spinlock_t *lock,
+					    unsigned short dev_type)
+{
+	int i;
+
+	i = netdev_lock_pos(dev_type);
+	lockdep_set_class_and_name(lock, &netdev_xmit_lock_key[i],
+				   netdev_lock_name[i]);
+}
+#else
+static inline void netdev_set_lockdep_class(spinlock_t *lock,
+					    unsigned short dev_type)
+{
+}
+#endif
 
 /*******************************************************************************
 
@@ -3001,6 +3069,7 @@ int register_netdevice(struct net_device
 
 	spin_lock_init(&dev->queue_lock);
 	spin_lock_init(&dev->_xmit_lock);
+	netdev_set_lockdep_class(&dev->_xmit_lock, dev->type);
 	dev->xmit_lock_owner = -1;
 	spin_lock_init(&dev->ingress_lock);
 
