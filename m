From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v3] vxlan: fix rcu related warning
Date: Sun, 4 Aug 2013 17:17:39 -0700
Message-ID: <20130804171739.63ee771e@nehalam.linuxnetplumber.net>
References: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
	<CALnjE+qx1L5p6CzFcd4nMTvWbxm-7_bz10wjbuUJdt12Q4Kqpg@mail.gmail.com>
	<20130730160245.4b7b84a1@nehalam.linuxnetplumber.net>
	<1375225499.10515.31.camel@edumazet-glaptop>
	<20130730173516.3d536077@nehalam.linuxnetplumber.net>
	<CALnjE+obgWjqDhuyWUJ=kimMKQbbweenRdxbU1ZCBWBP_qe8Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:44816 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984Ab3HEARn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 20:17:43 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so2676168pbb.0
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 17:17:43 -0700 (PDT)
In-Reply-To: <CALnjE+obgWjqDhuyWUJ=kimMKQbbweenRdxbU1ZCBWBP_qe8Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vxlan remote list is protected by RCU and guaranteed to be non-empty.
Split out the rcu and non-rcu access to the list to fix warning

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v3 - remove one __rcu

--- a/drivers/net/vxlan.c	2013-08-04 11:04:01.922478082 -0700
+++ b/drivers/net/vxlan.c	2013-08-04 16:54:33.214598043 -0700
@@ -177,9 +177,14 @@ static inline struct hlist_head *vs_head
 /* First remote destination for a forwarding entry.
  * Guaranteed to be non-NULL because remotes are never deleted.
  */
-static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
+static inline struct vxlan_rdst *first_remote_rcu(struct vxlan_fdb *fdb)
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
@@ -297,7 +302,8 @@ static void vxlan_fdb_notify(struct vxla
 	if (skb == NULL)
 		goto errout;
 
-	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, first_remote(fdb));
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0,
+			     first_remote_rtnl(fdb));
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -740,7 +746,7 @@ static bool vxlan_snoop(struct net_devic
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
-		struct vxlan_rdst *rdst = first_remote(f);
+		struct vxlan_rdst *rdst = first_remote_rcu(f);
 
 		if (likely(rdst->remote_ip == src_ip))
 			return false;
@@ -1005,7 +1011,7 @@ static int arp_reduce(struct net_device
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && first_remote(f)->remote_ip == htonl(INADDR_ANY)) {
+		if (f && first_remote_rcu(f)->remote_ip == htonl(INADDR_ANY)) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
