From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: linux-next: net build failure
Date: Thu, 27 Mar 2008 19:30:06 +0900 (JST)
Message-ID: <20080327.193006.132922343.yoshfuji@linux-ipv6.org>
References: <20080327182441.8d09b8ad.sfr@canb.auug.org.au>
	<20080327.022206.100283150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55329 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550AbYC0K2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 06:28:42 -0400
In-Reply-To: <20080327.022206.100283150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080327.022206.100283150.davem@davemloft.net> (at Thu, 27 Mar 2008 02:22:06 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 27 Mar 2008 18:24:41 +1100
> 
> > Today's linux-next build (powerpc allnoconfig (i.e. CONFIG_NET not
> > defined)) fails thusly:
> > 
> > In file included from include/linux/rtc.h:112,
> >                  from include/linux/efi.h:20,
> >                  from init/main.c:44:
> > include/linux/seq_file.h: In function 'seq_file_net':
> > include/linux/seq_file.h:81: error: 'init_net' undeclared (first use in this function)
> > include/linux/seq_file.h:81: error: (Each undeclared identifier is reported only once
> > include/linux/seq_file.h:81: error: for each function it appears in.)
> > 
> > Introduced by commit 1218854afa6f659be90b748cf1bc7badee954a35 ("[NET]
> > NETNS: Omit seq_net_private->net without CONFIG_NET_NS.").
> 
> Yoshifuji-san, please fix this.
> 
> I tried to, but the cases, especially those in netdevice.h, are
> difficult to resolve.
> 
> Thank you.

How about this?
I believe all functions are not used outside the net subsystem.

I'm still testing with allmodconfig but 
at least, allnoconfig works for me.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 15fa84a..f51c89c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -739,6 +739,7 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
+#ifdef CONFIG_NET
 /*
  * Net namespace inlines
  */
@@ -759,6 +760,7 @@ void dev_net_set(struct net_device *dev, struct net *net)
 	dev->nd_net = net;
 #endif
 }
+#endif
 
 /**
  *	netdev_priv - access network device private data
@@ -831,6 +833,7 @@ extern rwlock_t				dev_base_lock;		/* Device list lock */
 		list_for_each_entry_continue(d, &(net)->dev_base_head, dev_list)
 #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
 
+#ifdef CONFIG_NET
 static inline struct net_device *next_net_device(struct net_device *dev)
 {
 	struct list_head *lh;
@@ -846,6 +849,7 @@ static inline struct net_device *first_net_device(struct net *net)
 	return list_empty(&net->dev_base_head) ? NULL :
 		net_device_entry(net->dev_base_head.next);
 }
+#endif
 
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index d870a82..ff51e03 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -70,6 +70,7 @@ struct seq_net_private {
 #endif
 };
 
+#ifdef CONFIG_NET
 int seq_open_net(struct inode *, struct file *,
 		 const struct seq_operations *, int);
 int seq_release_net(struct inode *, struct file *);
@@ -81,6 +82,7 @@ static inline struct net *seq_file_net(struct seq_file *seq)
 	return &init_net;
 #endif
 }
+#endif
 
 #endif
 #endif
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 8bec0d6..aa85a41 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -218,6 +218,7 @@ extern struct neighbour 	*neigh_event_ns(struct neigh_table *tbl,
 extern struct neigh_parms	*neigh_parms_alloc(struct net_device *dev, struct neigh_table *tbl);
 extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
 
+#ifdef CONFIG_NET
 static inline
 struct net			*neigh_parms_net(const struct neigh_parms *parms)
 {
@@ -227,6 +228,7 @@ struct net			*neigh_parms_net(const struct neigh_parms *parms)
 	return &init_net;
 #endif
 }
+#endif
 
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
 
@@ -235,6 +237,7 @@ extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
 extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
 
+#ifdef CONFIG_NET
 static inline
 struct net			*pneigh_net(const struct pneigh_entry *pneigh)
 {
@@ -244,6 +247,7 @@ struct net			*pneigh_net(const struct pneigh_entry *pneigh)
 	return &init_net;
 #endif
 }
+#endif
 
 extern void neigh_app_ns(struct neighbour *n);
 extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
diff --git a/include/net/sock.h b/include/net/sock.h
index 1c9d059..a6047cb 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1347,6 +1347,7 @@ static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_e
 }
 #endif
 
+#ifdef CONFIG_NET
 static inline
 struct net *sock_net(const struct sock *sk)
 {
@@ -1376,6 +1377,7 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
 	put_net(sock_net(sk));
 	sock_net_set(sk, net);
 }
+#endif
 
 extern void sock_enable_timestamp(struct sock *sk);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
