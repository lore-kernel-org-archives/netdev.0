From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: [PATCH net] ipv6: If a public address is deleted then also delete
 all temporary addresses still referring to it
Date: Tue, 18 Mar 2014 21:46:40 +0100
Message-ID: <5328B0B0.7070305@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:54476 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757821AbaCRUrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 16:47:01 -0400
Received: from [192.168.178.101] ([84.153.195.113]) by smtp.web.de (mrweb002)
 with ESMTPSA (Nemesis) id 0MaJgG-1WfUQl4AgK-00JqaQ for
 <netdev@vger.kernel.org>; Tue, 18 Mar 2014 21:47:00 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a public address is deleted by an external trigger (e.g. via inet6_rtm_deladdr) then temporary
addresses still referring to it may remain. Happened here when the WiFi link broke and netifd
deleted the public address. Once the link was back and prefix_rcv created new public addresses
ipv6_create_tempaddr complained that the temporary address already existed.
IMHO no temporary address should live longer than its parent, especially because ifpub of the
temporary address still points to the then deleted public address otherwise.

Therefore delete all related temporary addresses before a public address is deleted in inet6_addr_del
which is called by inet6_rtm_del.

Also ensure in ipv6_del_addr that no temporary address lives longer than its parent.
However in addrconf_verify it might not be predetermined in which order a public address and the related
temporary address are deleted if they expire at the same time. Not sure about that ..

Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
---
 net/ipv6/addrconf.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 344e972..e5fd81d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -126,6 +126,7 @@ static void ipv6_regen_rndid(unsigned long data);
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
+static void ipv6_del_addr(struct inet6_ifaddr *ifp);
 
 /*
  *	Configured unicast address hash table
@@ -308,6 +309,31 @@ err_ip:
 	return -ENOMEM;
 }
 
+/* delete all temporary addresses referring to ifp
+   returns true if there have been addresses to be deleted */
+static int ifa_del_tempaddrs(struct inet6_ifaddr *ifp)
+{
+        struct inet6_dev *idev = ifp->idev;
+        struct inet6_ifaddr *ift;
+        int deleted = 0;
+
+        if(!(ifp->flags & IFA_F_MANAGETEMPADDR))
+                return 0;
+restart:
+        read_lock_bh(&idev->lock);
+        list_for_each_entry(ift, &idev->tempaddr_list, tmp_list) {
+                if (ifp != ift->ifpub)
+                        continue;
+                in6_ifa_hold(ift);
+                read_unlock_bh(&idev->lock);
+                deleted = 1;
+                ipv6_del_addr(ift);
+                goto restart;
+        }
+        read_unlock_bh(&idev->lock);
+        return deleted;
+}
+
 static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
@@ -990,6 +1016,10 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	enum cleanup_prefix_rt_t action = CLEANUP_PREFIX_RT_NOP;
 	unsigned long expires;
 
+	/* there should be no temporary address still referring to ifp */
+        if(ifa_del_tempaddrs(ifp))
+                pr_info("%s: stale temporary address(es) deleted\n", __func__);
+
 	spin_lock_bh(&ifp->state_lock);
 	state = ifp->state;
 	ifp->state = INET6_IFADDR_STATE_DEAD;
@@ -2506,6 +2536,7 @@ static int inet6_addr_del(struct net *net, int ifindex, const struct in6_addr *p
 			in6_ifa_hold(ifp);
 			read_unlock_bh(&idev->lock);
 
+			ifa_del_tempaddrs(ifp);
 			ipv6_del_addr(ifp);
 			return 0;
 		}
-- 
1.9.0.258.g00eda23.dirty
