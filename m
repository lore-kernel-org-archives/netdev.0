From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: mcast: RCU conversions
Date: Tue, 08 Jun 2010 09:05:02 +0200
Message-ID: <1275980702.2775.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41588 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab0FHHFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 03:05:08 -0400
Received: by wyi11 with SMTP id 11so2947692wyi.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 00:05:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- ipv6_sock_mc_join() : doesnt touch dev refcount

- ipv6_sock_mc_drop() : doesnt touch dev/idev refcounts

- ip6_mc_find_dev() becomes ip6_mc_find_dev_rcu() (called from rcu),
                    and doesnt touch dev/idev refcounts

- ipv6_sock_mc_close() : doesnt touch dev/idev refcounts

- ip6_mc_source() uses ip6_mc_find_dev_rcu()

- ip6_mc_msfilter() uses ip6_mc_find_dev_rcu()

- ip6_mc_msfget() uses ip6_mc_find_dev_rcu()

- ipv6_dev_mc_dec(), ipv6_chk_mcast_addr(),
  igmp6_event_query(), igmp6_event_report(),
  mld_sendpack(), igmp6_send() dont touch idev refcount

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/mcast.c |  183 +++++++++++++++++++++------------------------
 1 file changed, 87 insertions(+), 96 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 8752e80..3e36d15 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -152,18 +152,19 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	mc_lst->next = NULL;
 	ipv6_addr_copy(&mc_lst->addr, addr);
 
+	rcu_read_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
-			dev_hold(dev);
 			dst_release(&rt->u.dst);
 		}
 	} else
-		dev = dev_get_by_index(net, ifindex);
+		dev = dev_get_by_index_rcu(net, ifindex);
 
 	if (dev == NULL) {
+		rcu_read_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return -ENODEV;
 	}
@@ -180,8 +181,8 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	err = ipv6_dev_mc_inc(dev, addr);
 
 	if (err) {
+		rcu_read_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
-		dev_put(dev);
 		return err;
 	}
 
@@ -190,7 +191,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	np->ipv6_mc_list = mc_lst;
 	write_unlock_bh(&ipv6_sk_mc_lock);
 
-	dev_put(dev);
+	rcu_read_unlock();
 
 	return 0;
 }
@@ -213,18 +214,17 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			*lnk = mc_lst->next;
 			write_unlock_bh(&ipv6_sk_mc_lock);
 
-			dev = dev_get_by_index(net, mc_lst->ifindex);
+			rcu_read_lock();
+			dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
 			if (dev != NULL) {
-				struct inet6_dev *idev = in6_dev_get(dev);
+				struct inet6_dev *idev = __in6_dev_get(dev);
 
 				(void) ip6_mc_leave_src(sk, mc_lst, idev);
-				if (idev) {
+				if (idev)
 					__ipv6_dev_mc_dec(idev, &mc_lst->addr);
-					in6_dev_put(idev);
-				}
-				dev_put(dev);
 			} else
 				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
+			rcu_read_unlock();
 			sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 			return 0;
 		}
@@ -234,43 +234,36 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	return -EADDRNOTAVAIL;
 }
 
-static struct inet6_dev *ip6_mc_find_dev(struct net *net,
-					 struct in6_addr *group,
-					 int ifindex)
+/* called with rcu_read_lock() */
+static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
+					     struct in6_addr *group,
+					     int ifindex)
 {
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 
 	if (ifindex == 0) {
-		struct rt6_info *rt;
+		struct rt6_info *rt = rt6_lookup(net, group, NULL, 0, 0);
 
-		rt = rt6_lookup(net, group, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
 			dst_release(&rt->u.dst);
 		}
 	} else
-		dev = dev_get_by_index(net, ifindex);
+		dev = dev_get_by_index_rcu(net, ifindex);
 
 	if (!dev)
-		goto nodev;
-	idev = in6_dev_get(dev);
+		return NULL;
+	idev = __in6_dev_get(dev);
 	if (!idev)
-		goto release;
+		return NULL;;
 	read_lock_bh(&idev->lock);
-	if (idev->dead)
-		goto unlock_release;
-
+	if (idev->dead) {
+		read_unlock_bh(&idev->lock);
+		return NULL;
+	}
 	return idev;
-
-unlock_release:
-	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
-release:
-	dev_put(dev);
-nodev:
-	return NULL;
 }
 
 void ipv6_sock_mc_close(struct sock *sk)
@@ -286,19 +279,17 @@ void ipv6_sock_mc_close(struct sock *sk)
 		np->ipv6_mc_list = mc_lst->next;
 		write_unlock_bh(&ipv6_sk_mc_lock);
 
-		dev = dev_get_by_index(net, mc_lst->ifindex);
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
 		if (dev) {
-			struct inet6_dev *idev = in6_dev_get(dev);
+			struct inet6_dev *idev = __in6_dev_get(dev);
 
 			(void) ip6_mc_leave_src(sk, mc_lst, idev);
-			if (idev) {
+			if (idev)
 				__ipv6_dev_mc_dec(idev, &mc_lst->addr);
-				in6_dev_put(idev);
-			}
-			dev_put(dev);
 		} else
 			(void) ip6_mc_leave_src(sk, mc_lst, NULL);
-
+		rcu_read_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 
 		write_lock_bh(&ipv6_sk_mc_lock);
@@ -327,14 +318,17 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 
-	idev = ip6_mc_find_dev(net, group, pgsr->gsr_interface);
-	if (!idev)
+	rcu_read_lock();
+	idev = ip6_mc_find_dev_rcu(net, group, pgsr->gsr_interface);
+	if (!idev) {
+		rcu_read_unlock();
 		return -ENODEV;
+	}
 	dev = idev->dev;
 
 	err = -EADDRNOTAVAIL;
 
-	read_lock_bh(&ipv6_sk_mc_lock);
+	read_lock(&ipv6_sk_mc_lock);
 	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
 		if (pgsr->gsr_interface && pmc->ifindex != pgsr->gsr_interface)
 			continue;
@@ -358,7 +352,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		pmc->sfmode = omode;
 	}
 
-	write_lock_bh(&pmc->sflock);
+	write_lock(&pmc->sflock);
 	pmclocked = 1;
 
 	psl = pmc->sflist;
@@ -433,11 +427,10 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	ip6_mc_add_src(idev, group, omode, 1, source, 1);
 done:
 	if (pmclocked)
-		write_unlock_bh(&pmc->sflock);
-	read_unlock_bh(&ipv6_sk_mc_lock);
+		write_unlock(&pmc->sflock);
+	read_unlock(&ipv6_sk_mc_lock);
 	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
-	dev_put(dev);
+	rcu_read_unlock();
 	if (leavegroup)
 		return ipv6_sock_mc_drop(sk, pgsr->gsr_interface, group);
 	return err;
@@ -463,14 +456,17 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 	    gsf->gf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	idev = ip6_mc_find_dev(net, group, gsf->gf_interface);
+	rcu_read_lock();
+	idev = ip6_mc_find_dev_rcu(net, group, gsf->gf_interface);
 
-	if (!idev)
+	if (!idev) {
+		rcu_read_unlock();
 		return -ENODEV;
+	}
 	dev = idev->dev;
 
 	err = 0;
-	read_lock_bh(&ipv6_sk_mc_lock);
+	read_lock(&ipv6_sk_mc_lock);
 
 	if (gsf->gf_fmode == MCAST_INCLUDE && gsf->gf_numsrc == 0) {
 		leavegroup = 1;
@@ -512,7 +508,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 		(void) ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
 	}
 
-	write_lock_bh(&pmc->sflock);
+	write_lock(&pmc->sflock);
 	psl = pmc->sflist;
 	if (psl) {
 		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
@@ -522,13 +518,12 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 		(void) ip6_mc_del_src(idev, group, pmc->sfmode, 0, NULL, 0);
 	pmc->sflist = newpsl;
 	pmc->sfmode = gsf->gf_fmode;
-	write_unlock_bh(&pmc->sflock);
+	write_unlock(&pmc->sflock);
 	err = 0;
 done:
-	read_unlock_bh(&ipv6_sk_mc_lock);
+	read_unlock(&ipv6_sk_mc_lock);
 	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
-	dev_put(dev);
+	rcu_read_unlock();
 	if (leavegroup)
 		err = ipv6_sock_mc_drop(sk, gsf->gf_interface, group);
 	return err;
@@ -551,11 +546,13 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 
-	idev = ip6_mc_find_dev(net, group, gsf->gf_interface);
+	rcu_read_lock();
+	idev = ip6_mc_find_dev_rcu(net, group, gsf->gf_interface);
 
-	if (!idev)
+	if (!idev) {
+		rcu_read_unlock();
 		return -ENODEV;
-
+	}
 	dev = idev->dev;
 
 	err = -EADDRNOTAVAIL;
@@ -577,8 +574,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	psl = pmc->sflist;
 	count = psl ? psl->sl_count : 0;
 	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
-	dev_put(dev);
+	rcu_read_unlock();
 
 	copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
 	gsf->gf_numsrc = count;
@@ -604,8 +600,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	return 0;
 done:
 	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
-	dev_put(dev);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -822,6 +817,7 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 	struct ifmcaddr6 *mc;
 	struct inet6_dev *idev;
 
+	/* we need to take a reference on idev */
 	idev = in6_dev_get(dev);
 
 	if (idev == NULL)
@@ -860,7 +856,7 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 	setup_timer(&mc->mca_timer, igmp6_timer_handler, (unsigned long)mc);
 
 	ipv6_addr_copy(&mc->mca_addr, addr);
-	mc->idev = idev;
+	mc->idev = idev; /* (reference taken) */
 	mc->mca_users = 1;
 	/* mca_stamp should be updated upon changes */
 	mc->mca_cstamp = mc->mca_tstamp = jiffies;
@@ -915,16 +911,18 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 
 int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
 {
-	struct inet6_dev *idev = in6_dev_get(dev);
+	struct inet6_dev *idev;
 	int err;
 
-	if (!idev)
-		return -ENODEV;
-
-	err = __ipv6_dev_mc_dec(idev, addr);
+	rcu_read_lock();
 
-	in6_dev_put(idev);
+	idev = __in6_dev_get(dev);
+	if (!idev)
+		err = -ENODEV;
+	else
+		err = __ipv6_dev_mc_dec(idev, addr);
 
+	rcu_read_unlock();
 	return err;
 }
 
@@ -965,7 +963,8 @@ int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 	struct ifmcaddr6 *mc;
 	int rv = 0;
 
-	idev = in6_dev_get(dev);
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
 		for (mc = idev->mc_list; mc; mc=mc->next) {
@@ -992,8 +991,8 @@ int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 				rv = 1; /* don't filter unspecified source */
 		}
 		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 	}
+	rcu_read_unlock();
 	return rv;
 }
 
@@ -1104,6 +1103,7 @@ static int mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	return 1;
 }
 
+/* called with rcu_read_lock() */
 int igmp6_event_query(struct sk_buff *skb)
 {
 	struct mld2_query *mlh2 = NULL;
@@ -1127,7 +1127,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
 		return -EINVAL;
 
-	idev = in6_dev_get(skb->dev);
+	idev = __in6_dev_get(skb->dev);
 
 	if (idev == NULL)
 		return 0;
@@ -1137,10 +1137,8 @@ int igmp6_event_query(struct sk_buff *skb)
 	group_type = ipv6_addr_type(group);
 
 	if (group_type != IPV6_ADDR_ANY &&
-	    !(group_type&IPV6_ADDR_MULTICAST)) {
-		in6_dev_put(idev);
+	    !(group_type&IPV6_ADDR_MULTICAST))
 		return -EINVAL;
-	}
 
 	if (len == 24) {
 		int switchback;
@@ -1161,10 +1159,9 @@ int igmp6_event_query(struct sk_buff *skb)
 	} else if (len >= 28) {
 		int srcs_offset = sizeof(struct mld2_query) -
 				  sizeof(struct icmp6hdr);
-		if (!pskb_may_pull(skb, srcs_offset)) {
-			in6_dev_put(idev);
+		if (!pskb_may_pull(skb, srcs_offset))
 			return -EINVAL;
-		}
+
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
 		max_delay = (MLDV2_MRC(ntohs(mlh2->mld2q_mrc))*HZ)/1000;
 		if (!max_delay)
@@ -1173,28 +1170,23 @@ int igmp6_event_query(struct sk_buff *skb)
 		if (mlh2->mld2q_qrv)
 			idev->mc_qrv = mlh2->mld2q_qrv;
 		if (group_type == IPV6_ADDR_ANY) { /* general query */
-			if (mlh2->mld2q_nsrcs) {
-				in6_dev_put(idev);
+			if (mlh2->mld2q_nsrcs)
 				return -EINVAL; /* no sources allowed */
-			}
+
 			mld_gq_start_timer(idev);
-			in6_dev_put(idev);
 			return 0;
 		}
 		/* mark sources to include, if group & source-specific */
 		if (mlh2->mld2q_nsrcs != 0) {
 			if (!pskb_may_pull(skb, srcs_offset +
-			    ntohs(mlh2->mld2q_nsrcs) * sizeof(struct in6_addr))) {
-				in6_dev_put(idev);
+			    ntohs(mlh2->mld2q_nsrcs) * sizeof(struct in6_addr)))
 				return -EINVAL;
-			}
+
 			mlh2 = (struct mld2_query *)skb_transport_header(skb);
 			mark = 1;
 		}
-	} else {
-		in6_dev_put(idev);
+	} else
 		return -EINVAL;
-	}
 
 	read_lock_bh(&idev->lock);
 	if (group_type == IPV6_ADDR_ANY) {
@@ -1227,12 +1219,11 @@ int igmp6_event_query(struct sk_buff *skb)
 		}
 	}
 	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
 
 	return 0;
 }
 
-
+/* called with rcu_read_lock() */
 int igmp6_event_report(struct sk_buff *skb)
 {
 	struct ifmcaddr6 *ma;
@@ -1260,7 +1251,7 @@ int igmp6_event_report(struct sk_buff *skb)
 	    !(addr_type&IPV6_ADDR_LINKLOCAL))
 		return -EINVAL;
 
-	idev = in6_dev_get(skb->dev);
+	idev = __in6_dev_get(skb->dev);
 	if (idev == NULL)
 		return -ENODEV;
 
@@ -1280,7 +1271,6 @@ int igmp6_event_report(struct sk_buff *skb)
 		}
 	}
 	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
 	return 0;
 }
 
@@ -1396,12 +1386,14 @@ static void mld_sendpack(struct sk_buff *skb)
 	struct mld2_report *pmr =
 			      (struct mld2_report *)skb_transport_header(skb);
 	int payload_len, mldlen;
-	struct inet6_dev *idev = in6_dev_get(skb->dev);
+	struct inet6_dev *idev;
 	struct net *net = dev_net(skb->dev);
 	int err;
 	struct flowi fl;
 	struct dst_entry *dst;
 
+	rcu_read_lock();
+	idev = __in6_dev_get(skb->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
 	payload_len = (skb->tail - skb->network_header) - sizeof(*pip6);
@@ -1441,8 +1433,7 @@ out:
 	} else
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	rcu_read_unlock();
 	return;
 
 err_out:
@@ -1779,7 +1770,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 					 IPPROTO_ICMPV6,
 					 csum_partial(hdr, len, 0));
 
-	idev = in6_dev_get(skb->dev);
+	rcu_read_lock();
+	idev = __in6_dev_get(skb->dev);
 
 	dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
 	if (!dst) {
@@ -1806,8 +1798,7 @@ out:
 	} else
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	rcu_read_unlock();
 	return;
 
 err_out:


