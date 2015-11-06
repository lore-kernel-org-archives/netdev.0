From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] inet: delay address promotion check until last request in message
Date: Fri,  6 Nov 2015 14:51:35 -0500
Message-ID: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54025 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756582AbbKFTwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 14:52:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I recently got a report that, after a user added 40,000 addresses to an
interface and ran ip addr flush <dev>, their system blocked on interface access
for literally hours, and issued hundreds of hung task warnings. due to rtnl
being held during this operation.

While its certainly arguable that long delays on that flush can be expected, and
40k addresses on an interface isn't a realistic use case, it seems we might be
able to do better.

Looking at the address delete path for ipv4, it seems the problem is clear.
When deleting a primary address, the kernel by default promotes a secondary
address to be the new primary, which entails visiting each node in the address
list on the interface again.  This turns a O(n) runtime into O(n^2), and at
large address sets that becomes very lengthy, especially since rtnl has to be
held during this time.

The solution is to recognize that its pointless to promote an address to be a
new primary, if there is a possibility that it will just be removed in the near
future.  As such this patch peeks ahead to the next request in the provided
netlink message, and, if it is both valid and a RTM_DELADDR request, skips the
promotion check.  This eliminates the need to iterate through a nested for loop
until the last RTM_DELADDR request, returning our runtime to about O(n) for any
arbitrarily sized address list.

I've tested this on the reporters use case, and it allows me to flush 40k
addresses from an interface in a few seconds, rather than the previous few
hours.

Note that applying this patch uncovers a bug in iproute2, wherein I've found
that disabling promotion leads to EADDRNOTAVAIL return codes.  This is expected
due to the way iproute2 preforms a flush operation, and I've submitted a patch
for that here:
http://marc.info/?l=linux-netdev&m=144675329202075&w=2

Patch applies to the net tree HEAD

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: jiji@redhat.com
CC: "David S. Miller" <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/devinet.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cebd9d3..6c7bcb7 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -324,13 +324,13 @@ int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b)
 }
 
 static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
-			 int destroy, struct nlmsghdr *nlh, u32 portid)
+			 int destroy, struct nlmsghdr *nlh, int check_promote, u32 portid)
 {
 	struct in_ifaddr *promote = NULL;
 	struct in_ifaddr *ifa, *ifa1 = *ifap;
 	struct in_ifaddr *last_prim = in_dev->ifa_list;
 	struct in_ifaddr *prev_prom = NULL;
-	int do_promote = IN_DEV_PROMOTE_SECONDARIES(in_dev);
+	int do_promote = check_promote && IN_DEV_PROMOTE_SECONDARIES(in_dev);
 
 	ASSERT_RTNL();
 
@@ -421,12 +421,13 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 	}
 	if (destroy)
 		inet_free_ifa(ifa1);
+
 }
 
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy)
 {
-	__inet_del_ifa(in_dev, ifap, destroy, NULL, 0);
+	__inet_del_ifa(in_dev, ifap, destroy, NULL, 1, 0);
 }
 
 static void check_lifetime(struct work_struct *work);
@@ -575,7 +576,10 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct in_device *in_dev;
 	struct ifaddrmsg *ifm;
 	struct in_ifaddr *ifa, **ifap;
+	struct nlmsghdr *nnlh;
 	int err = -EINVAL;
+	int check_promote = 1;
+	int len = skb->len;
 
 	ASSERT_RTNL();
 
@@ -590,8 +594,20 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
+	/*
+	 * Only check for address promotion when this is the last request
+	 * in this netlink transaction.  It allows this operation to complete
+	 * in O(n) time rather than O(n^2)
+	 */
+	if (len > nlh->nlmsg_len) {
+		nnlh = NLMSG_NEXT(nlh, len);
+		if (NLMSG_OK(nnlh, len) && (nnlh->nlmsg_type == RTM_DELADDR))
+			check_promote = 0;
+	}
+
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
+
 		if (tb[IFA_LOCAL] &&
 		    ifa->ifa_local != nla_get_in_addr(tb[IFA_LOCAL]))
 			continue;
@@ -606,7 +622,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		if (ipv4_is_multicast(ifa->ifa_address))
 			ip_mc_config(net->ipv4.mc_autojoin_sk, false, ifa);
-		__inet_del_ifa(in_dev, ifap, 1, nlh, NETLINK_CB(skb).portid);
+		__inet_del_ifa(in_dev, ifap, 1, nlh, check_promote, NETLINK_CB(skb).portid);
 		return 0;
 	}
 
-- 
2.1.0
