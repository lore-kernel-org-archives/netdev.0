From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Sat, 30 Aug 2014 12:58:21 +0200
Message-ID: <20140830105821.GB18155@kria>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
 <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
 <20140829195339.GA9780@kria>
 <1409363489.2980.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Cong Wang <cwang@twopensource.com>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <trinity-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409363489.2980.17.camel@localhost>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

2014-08-30, 03:51:29 +0200, Hannes Frederic Sowa wrote:
> Hi Sabrina,
> 
> [...]
> 
> Sorry, just had time to look at this.
> 
> The reason is not to have list corruption but that the calls down to
> ndo_set_rx_mode expect rtnl to be locked by the drivers. Filter lists
> are locked by addr_list_lock and that's why I think we never saw any
> problems with that, but drivers expect rtnl locked for those calls.
> 
> But this problem also affects multicast join, so patch seems incomplete
> to me (and for that matter ssm multicast join, too).
> 
> Also rtnl_lock and rcu_read_lock compose in that order, so we don't need
> to change dev_get_by_flags, but as this is the only user it sure is
> possible. RCU locked version is just easier composeable, so I wouldn't
> touch that if needed in future, just also take rcu lock as before.
> 
> So just adding rtnl_lock add appropriate places seems to be ok to me,
> but still need to review parts of the ssm code.
> 
> Also we should move ASSERT_RTNL checks from addrconf_join_solict to
> ipv6_dev_mc_inc/dec.
> 
> Thanks,
> Hannes

Thanks for explaining.

I had a look at what you suggested.


So, for anycast, on top of the previous patch, we'd have:

---
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 210183244689..61dd3046b804 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
 static void aca_put(struct ifacaddr6 *ac)
@@ -233,6 +235,8 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
 	struct rt6_info *rt;
 	int err;
 
+	ASSERT_RTNL();
+
 	idev = in6_dev_get(dev);
 
 	if (idev == NULL)
@@ -302,6 +306,8 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct ifacaddr6 *aca, *prev_aca;
 
+	ASSERT_RTNL();
+
 	write_lock_bh(&idev->lock);
 	prev_aca = NULL;
 	for (aca = idev->ac_list; aca; aca = aca->aca_next) {
@@ -336,6 +342,8 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
 
+	ASSERT_RTNL();
+
 	if (idev == NULL)
 		return -ENODEV;
 	return __ipv6_dev_ac_dec(idev, addr);

---


And for multicast:
 - locking order in the patch below: rtnl -> rcu -> ipv6_sk_mc_lock
 - ipv6_sock_mc_join: maybe move all the _unlock()'s together at the end of the function
 - do we need to modify rcu_dereference_protected in ipv6_sock_mc_drop/ipv6_sock_mc_close
 - I had a look at the other codepaths that call ipv6_dev_mc_inc/dec
   - ipv6_mc_destroy_dev, dev_forward_change, ipv6_add_dev,
     addrconf_join_solict -- all take rtnl or already have an
     ASSERT_RTNL()
   - pndisc_destructor, called from pneigh_ifdown/pneigh_delete
   - pndisc_constructor, called from pneigh_lookup -- pneigh_lookup
     has ASSERT_RTNL(), but pneigh_lookup is called from ip6_forward and
     ndisc_recv_na
   - (hope I didn't miss any callers)

As far as I could see, apart maybe from pndisc_constructor, it seems
okay, but I'd like to hear your comments.


Current modifications:

---
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 70881795da96..d73ac1ef65f2 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -172,6 +172,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	mc_lst->next = NULL;
 	mc_lst->addr = *addr;
 
+	rtnl_lock();
 	rcu_read_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
@@ -185,6 +186,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	if (dev == NULL) {
 		rcu_read_unlock();
+		rtnl_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return -ENODEV;
 	}
@@ -202,6 +204,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	if (err) {
 		rcu_read_unlock();
+		rtnl_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return err;
 	}
@@ -212,6 +215,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	spin_unlock(&ipv6_sk_mc_lock);
 
 	rcu_read_unlock();
+	rtnl_unlock();
 
 	return 0;
 }
@@ -229,6 +233,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	if (!ipv6_addr_is_multicast(addr))
 		return -EINVAL;
 
+	rtnl_lock();
 	spin_lock(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list;
 	     (mc_lst = rcu_dereference_protected(*lnk,
@@ -252,12 +257,15 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			} else
 				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
 			rcu_read_unlock();
+			rtnl_unlock();
+
 			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
 			kfree_rcu(mc_lst, rcu);
 			return 0;
 		}
 	}
 	spin_unlock(&ipv6_sk_mc_lock);
+	rtnl_unlock();
 
 	return -EADDRNOTAVAIL;
 }
@@ -302,6 +310,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 	if (!rcu_access_pointer(np->ipv6_mc_list))
 		return;
 
+	rtnl_lock();
 	spin_lock(&ipv6_sk_mc_lock);
 	while ((mc_lst = rcu_dereference_protected(np->ipv6_mc_list,
 				lockdep_is_held(&ipv6_sk_mc_lock))) != NULL) {
@@ -328,6 +337,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 		spin_lock(&ipv6_sk_mc_lock);
 	}
 	spin_unlock(&ipv6_sk_mc_lock);
+	rtnl_unlock();
 }
 
 int ip6_mc_source(int add, int omode, struct sock *sk,
@@ -845,6 +855,8 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 	struct ifmcaddr6 *mc;
 	struct inet6_dev *idev;
 
+	ASSERT_RTNL();
+
 	/* we need to take a reference on idev */
 	idev = in6_dev_get(dev);
 
@@ -916,6 +928,8 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct ifmcaddr6 *ma, **map;
 
+	ASSERT_RTNL();
+
 	write_lock_bh(&idev->lock);
 	for (map = &idev->mc_list; (ma = *map) != NULL; map = &ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, addr)) {
@@ -942,6 +956,8 @@ int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
 	struct inet6_dev *idev;
 	int err;
 
+	ASSERT_RTNL();
+
 	rcu_read_lock();
 
 	idev = __in6_dev_get(dev);

---


Thanks,

-- 
Sabrina
