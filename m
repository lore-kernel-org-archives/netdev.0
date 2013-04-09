From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: ipv6: also allow token to be set when device not ready
Date: Tue,  9 Apr 2013 15:47:15 +0200
Message-ID: <1365515236-7154-3-git-send-email-dborkman@redhat.com>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936028Ab3DINrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 09:47:24 -0400
In-Reply-To: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we set the iftoken in inet6_set_iftoken(), we return -EINVAL
when the device does not have flag IF_READY. This is however not
necessary and rather an artificial usability barrier, since we
simply can set the token despite that, and in case the device is
ready, we just send out our rs, otherwise ifup et al. will do
this for us anyway.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/addrconf.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 645bf31..713ebe3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4296,9 +4296,9 @@ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
 
 static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 {
-	struct in6_addr ll_addr;
 	struct inet6_ifaddr *ifp;
 	struct net_device *dev = idev->dev;
+	bool update_rs = false;
 
 	if (token == NULL)
 		return -EINVAL;
@@ -4306,8 +4306,6 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 		return -EINVAL;
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
 		return -EINVAL;
-	if (idev->dead || !(idev->if_flags & IF_READY))
-		return -EINVAL;
 	if (!ipv6_accept_ra(idev))
 		return -EINVAL;
 	if (idev->cnf.rtr_solicits <= 0)
@@ -4320,11 +4318,23 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 
 	write_unlock_bh(&idev->lock);
 
-	ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE | IFA_F_OPTIMISTIC);
-	ndisc_send_rs(dev, &ll_addr, &in6addr_linklocal_allrouters);
+	if (!idev->dead && (idev->if_flags & IF_READY)) {
+		struct in6_addr ll_addr;
+
+		ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE |
+				IFA_F_OPTIMISTIC);
+
+		/* If we're not ready, then normal ifup will take care
+		 * of this. Otherwise, we need to request our rs here.
+		 */
+		ndisc_send_rs(dev, &ll_addr, &in6addr_linklocal_allrouters);
+		update_rs = true;
+	}
 
 	write_lock_bh(&idev->lock);
-	idev->if_flags |= IF_RS_SENT;
+
+	if (update_rs)
+		idev->if_flags |= IF_RS_SENT;
 
 	/* Well, that's kinda nasty ... */
 	list_for_each_entry(ifp, &idev->addr_list, if_list) {
-- 
1.7.1
