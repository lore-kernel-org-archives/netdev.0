From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vxlan: fix rcu related warnings
Date: Tue, 30 Jul 2013 13:18:44 -0700
Message-ID: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34607 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab3G3USs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 16:18:48 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so6900017pde.38
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 13:18:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vxlan remote list is protected by RCU but since first_remote
returns a bare pointer, sparse complains.
Split out the rcu and non-rcu access to the list.

Ok to replace list_for_or_null with just list_entry_rcu because
remotes list must be non-empty.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-07-24 12:42:42.919769763 -0700
+++ b/drivers/net/vxlan.c	2013-07-30 13:15:21.436571647 -0700
@@ -176,9 +176,14 @@ static inline struct hlist_head *vs_head
 /* First remote destination for a forwarding entry.
  * Guaranteed to be non-NULL because remotes are never deleted.
  */
-static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
+static inline struct vxlan_rdst __rcu *first_remote_rcu(struct vxlan_fdb *fdb)
 {
-	return list_first_or_null_rcu(&fdb->remotes, struct vxlan_rdst, list);
+	return list_entry_rcu(fdb->remotes.next, struct vxlan_rdst, list);
+}
+
+static inline struct vxlan_rdst *first_remote_rtnl(struct vxlan_fdb *fdb)
+{
+	return list_first_entry(&fdb->remotes, struct vxlan_rdst, list);
 }
 
 /* Find VXLAN socket based on network namespace and UDP port */
@@ -296,7 +301,8 @@ static void vxlan_fdb_notify(struct vxla
 	if (skb == NULL)
 		goto errout;
 
-	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, first_remote(fdb));
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0,
+			     first_remote_rtnl(fdb));
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -739,7 +745,7 @@ static bool vxlan_snoop(struct net_devic
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
-		struct vxlan_rdst *rdst = first_remote(f);
+		struct vxlan_rdst *rdst = first_remote_rcu(f);
 
 		if (likely(rdst->remote_ip == src_ip))
 			return false;
@@ -987,7 +993,7 @@ static int arp_reduce(struct net_device
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && first_remote(f)->remote_ip == htonl(INADDR_ANY)) {
+		if (f && first_remote_rcu(f)->remote_ip == htonl(INADDR_ANY)) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
