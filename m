From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.6 patch] IPV6 addrconf.c: remove unused functions and variables
Date: Sat, 13 Mar 2004 20:39:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313193959.GB14833@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch

  [IPV6]: Do not report {multi,any}cast in inet6_dump_ifaddr().

in Linus' tree removed the only uses of two functions and two variables
and therefore caused the following compile warnings:

<--  snip  -->

...
  CC      net/ipv6/addrconf.o
net/ipv6/addrconf.c: In function `inet6_dump_ifaddr':
net/ipv6/addrconf.c:2638: warning: unused variable `ifmca'
net/ipv6/addrconf.c:2639: warning: unused variable `ifaca'
net/ipv6/addrconf.c: At top level:
net/ipv6/addrconf.c:2558: warning: `inet6_fill_ifmcaddr' defined but not used
net/ipv6/addrconf.c:2595: warning: `inet6_fill_ifacaddr' defined but not used
...

<--  snip  -->


The patch below removes these functions and variables.


diffstat output: 

net/ipv6/addrconf.c |   76 --------------------------------------------
 1 files changed, 76 deletions(-)


cu
Adrian


--- linux-2.6.4-mm1-full/net/ipv6/addrconf.c.old	2004-03-13 20:27:45.000000000 +0100
+++ linux-2.6.4-mm1-full/net/ipv6/addrconf.c	2004-03-13 20:35:20.000000000 +0100
@@ -2553,80 +2553,6 @@
 	return -1;
 }
 
-static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
-				u32 pid, u32 seq, int event)
-{
-	struct ifaddrmsg *ifm;
-	struct nlmsghdr  *nlh;
-	struct ifa_cacheinfo ci;
-	unsigned char	 *b = skb->tail;
-
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
-	ifm = NLMSG_DATA(nlh);
-	ifm->ifa_family = AF_INET6;	
-	ifm->ifa_prefixlen = 128;
-	ifm->ifa_flags = IFA_F_PERMANENT;
-	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
-	if (ipv6_addr_scope(&ifmca->mca_addr)&IFA_SITE)
-		ifm->ifa_scope = RT_SCOPE_SITE;
-	ifm->ifa_index = ifmca->idev->dev->ifindex;
-	RTA_PUT(skb, IFA_ADDRESS, 16, &ifmca->mca_addr);
-	ci.cstamp = (__u32)(TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifmca->mca_cstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.tstamp = (__u32)(TIME_DELTA(ifmca->mca_tstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifmca->mca_tstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.ifa_prefered = INFINITY_LIFE_TIME;
-	ci.ifa_valid = INFINITY_LIFE_TIME;
-	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
-
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
-}
-
-static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
-				u32 pid, u32 seq, int event)
-{
-	struct ifaddrmsg *ifm;
-	struct nlmsghdr  *nlh;
-	struct ifa_cacheinfo ci;
-	unsigned char	 *b = skb->tail;
-
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
-	ifm = NLMSG_DATA(nlh);
-	ifm->ifa_family = AF_INET6;	
-	ifm->ifa_prefixlen = 128;
-	ifm->ifa_flags = IFA_F_PERMANENT;
-	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
-	if (ipv6_addr_scope(&ifaca->aca_addr)&IFA_SITE)
-		ifm->ifa_scope = RT_SCOPE_SITE;
-	ifm->ifa_index = ifaca->aca_idev->dev->ifindex;
-	RTA_PUT(skb, IFA_ADDRESS, 16, &ifaca->aca_addr);
-	ci.cstamp = (__u32)(TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifaca->aca_cstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.tstamp = (__u32)(TIME_DELTA(ifaca->aca_tstamp, INITIAL_JIFFIES) / HZ
-		    * 100 + TIME_DELTA(ifaca->aca_tstamp, INITIAL_JIFFIES) % HZ
-		    * 100 / HZ);
-	ci.ifa_prefered = INFINITY_LIFE_TIME;
-	ci.ifa_valid = INFINITY_LIFE_TIME;
-	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
-
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
-}
-
 static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx, ip_idx;
@@ -2635,8 +2561,6 @@
 	struct net_device *dev;
 	struct inet6_dev *idev = NULL;
 	struct inet6_ifaddr *ifa;
-	struct ifmcaddr6 *ifmca;
-	struct ifacaddr6 *ifaca;
 	
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
