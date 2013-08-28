From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 05/11] ipv6: do not call ndisc_send_rs() with write lock
Date: Wed, 28 Aug 2013 13:22:53 +0800
Message-ID: <1377667379-2315-6-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab3H1FX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:23:59 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Because vxlan module will call ip6_dst_lookup() in TX path,
which will hold write lock. So we have to release this write lock
before calling ndisc_send_rs(), otherwise could deadlock.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8e68466..1bb0861 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3088,6 +3088,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 static void addrconf_rs_timer(unsigned long data)
 {
 	struct inet6_dev *idev = (struct inet6_dev *)data;
+	struct net_device *dev = idev->dev;
 	struct in6_addr lladdr;
 
 	write_lock(&idev->lock);
@@ -3102,12 +3103,14 @@ static void addrconf_rs_timer(unsigned long data)
 		goto out;
 
 	if (idev->rs_probes++ < idev->cnf.rtr_solicits) {
-		if (!__ipv6_get_lladdr(idev, &lladdr, IFA_F_TENTATIVE))
-			ndisc_send_rs(idev->dev, &lladdr,
+		write_unlock(&idev->lock);
+		if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
+			ndisc_send_rs(dev, &lladdr,
 				      &in6addr_linklocal_allrouters);
 		else
-			goto out;
+			goto put;
 
+		write_lock(&idev->lock);
 		/* The wait after the last probe can be shorter */
 		addrconf_mod_rs_timer(idev, (idev->rs_probes ==
 					     idev->cnf.rtr_solicits) ?
@@ -3123,6 +3126,7 @@ static void addrconf_rs_timer(unsigned long data)
 
 out:
 	write_unlock(&idev->lock);
+put:
 	in6_dev_put(idev);
 }
 
-- 
1.7.7.6
