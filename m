From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v3 2/2] vxlan: allow specifying multiple default
 destinations
Date: Sun, 2 Jun 2013 13:29:42 +0300
Message-ID: <20130602102942.GA21706@zed>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
 <20130530110948.GA10532@casper.infradead.org>
 <CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
 <20130530113739.GB10532@casper.infradead.org>
 <20130531091740.70b3e077@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:33073 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753411Ab3FBK3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 06:29:49 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so2335351wgh.6
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 03:29:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130531091740.70b3e077@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 7:17 PM, Stephen Hemminger <stephen@networkplumber.org> wrote:
> Looking at this code in more detail, I see a slew of problems.
>
> First the list of destinations isn't really a list. The default one is still
> embedded in the fdb entry. This means you can't change it safely.
>
> Also the notification via netlink only sends back a single destination
> value.
>
> And the lack of locking on the open coded link list means it is not safe since
> the forwarding table is used with RCU. In order to be safe, proper RCU
> barriers would be needed or better yet convert to list_rcu..
>
> Overall, I feel guilty for not inspecting this more closely and am surprised
> that others did not catch the lack of locking.

I've tried to convert remotes list to use hlist_rcu. The patch below implements the conversion, but it does not address the netlink notification issue.

>From 4de2001606a258462369520231643874e3e5c14c Mon Sep 17 00:00:00 2001
From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Sun, 2 Jun 2013 13:21:23 +0300
Subject: [PATCH] vxlan: convert remotes list to hlist_rcu

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 75 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 47 insertions(+), 28 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8111565..664853e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -101,7 +101,8 @@ struct vxlan_rdst {
 	__be16			 remote_port;
 	u32			 remote_vni;
 	u32			 remote_ifindex;
-	struct vxlan_rdst	*remote_next;
+	struct hlist_node	 hlist;
+	struct rcu_head		 rcu;
 };
 
 /* Forwarding table entry */
@@ -110,7 +111,7 @@ struct vxlan_fdb {
 	struct rcu_head	  rcu;
 	unsigned long	  updated;	/* jiffies */
 	unsigned long	  used;
-	struct vxlan_rdst remote;
+	struct hlist_head remotes;
 	u16		  state;	/* see ndm_state */
 	u8		  flags;	/* see ndm_flags */
 	u8		  eth_addr[ETH_ALEN];
@@ -163,6 +164,13 @@ static inline struct hlist_head *vs_head(struct net *net, __be16 port)
 	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
 }
 
+/* The first remote destination in FDB remotes list */
+static inline struct vxlan_rdst *remotes_head(struct vxlan_fdb *f)
+{
+	return hlist_entry(hlist_first_rcu(&f->remotes),
+			   struct vxlan_rdst, hlist);
+}
+
 /* Find VXLAN socket based on network namespace and UDP port */
 static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
 {
@@ -278,7 +286,7 @@ static void vxlan_fdb_notify(struct vxlan_dev *vxlan,
 	if (skb == NULL)
 		goto errout;
 
-	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, &fdb->remote);
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, remotes_head(fdb));
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -297,11 +305,14 @@ static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb f;
+	struct vxlan_rdst remote;
 
 	memset(&f, 0, sizeof f);
 	f.state = NUD_STALE;
-	f.remote.remote_ip = ipa; /* goes to NDA_DST */
-	f.remote.remote_vni = VXLAN_N_VID;
+	remote.remote_ip = ipa; /* goes to NDA_DST */
+	remote.remote_vni = VXLAN_N_VID;
+
+	hlist_add_head_rcu(&remote.hlist, &f.remotes);
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
 }
@@ -370,17 +381,16 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 static int vxlan_fdb_append(struct vxlan_fdb *f,
 			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
 {
-	struct vxlan_rdst *rd_prev, *rd;
+	struct vxlan_rdst *rd;
 
-	rd_prev = NULL;
-	for (rd = &f->remote; rd; rd = rd->remote_next) {
+	hlist_for_each_entry_rcu(rd, &f->remotes, hlist) {
 		if (rd->remote_ip == ip &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
 		    rd->remote_ifindex == ifindex)
 			return 0;
-		rd_prev = rd;
 	}
+
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
@@ -388,8 +398,9 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	rd->remote_port = port;
 	rd->remote_vni = vni;
 	rd->remote_ifindex = ifindex;
-	rd->remote_next = NULL;
-	rd_prev->remote_next = rd;
+
+	hlist_add_head_rcu(&rd->hlist, &f->remotes);
+
 	return 1;
 }
 
@@ -441,16 +452,13 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			return -ENOMEM;
 
 		notify = 1;
-		f->remote.remote_ip = ip;
-		f->remote.remote_port = port;
-		f->remote.remote_vni = vni;
-		f->remote.remote_ifindex = ifindex;
-		f->remote.remote_next = NULL;
 		f->state = state;
 		f->flags = ndm_flags;
 		f->updated = f->used = jiffies;
 		memcpy(f->eth_addr, mac, ETH_ALEN);
 
+		vxlan_fdb_append(f, ip, port, vni, ifindex);
+
 		++vxlan->addrcnt;
 		hlist_add_head_rcu(&f->hlist,
 				   vxlan_fdb_head(vxlan, mac));
@@ -462,16 +470,22 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	return 0;
 }
 
+static void vxlan_rdst_free(struct rcu_head *head)
+{
+	struct vxlan_rdst *rd = container_of(head, struct vxlan_rdst, rcu);
+	kfree(rd);
+}
+
 static void vxlan_fdb_free(struct rcu_head *head)
 {
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
+	struct vxlan_rdst *rd;
 
-	while (f->remote.remote_next) {
-		struct vxlan_rdst *rd = f->remote.remote_next;
-
-		f->remote.remote_next = rd->remote_next;
-		kfree(rd);
+	hlist_for_each_safe(rd, &f->remotes, hlist) {
+		hlist_del_rcu(&rd->hlist);
+		call_rcu(&rd->rcu, vxlan_rdst_free);
 	}
+
 	kfree(f);
 }
 
@@ -581,7 +595,7 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 
 		hlist_for_each_entry_rcu(f, &vxlan->fdb_head[h], hlist) {
 			struct vxlan_rdst *rd;
-			for (rd = &f->remote; rd; rd = rd->remote_next) {
+			hlist_for_each_entry_rcu(rd, &f->remotes, hlist) {
 				if (idx < cb->args[0])
 					goto skip;
 
@@ -613,15 +627,17 @@ static void vxlan_snoop(struct net_device *dev,
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
-		if (likely(f->remote.remote_ip == src_ip))
+		struct vxlan_rdst *remote = remotes_head(f);
+
+		if (likely(remote->remote_ip == src_ip))
 			return;
 
 		if (net_ratelimit())
 			netdev_info(dev,
 				    "%pM migrated from %pI4 to %pI4\n",
-				    src_mac, &f->remote.remote_ip, &src_ip);
+				    src_mac, &remote->remote_ip, &src_ip);
 
-		f->remote.remote_ip = src_ip;
+		remote->remote_ip = src_ip;
 		f->updated = jiffies;
 	} else {
 		/* learned new entry */
@@ -856,6 +872,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 	if (n) {
 		struct vxlan_fdb *f;
 		struct sk_buff	*reply;
+		struct vxlan_rdst *remote;
 
 		if (!(n->nud_state & NUD_CONNECTED)) {
 			neigh_release(n);
@@ -863,7 +880,8 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && f->remote.remote_ip == htonl(INADDR_ANY)) {
+		remote = remotes_head(f);
+		if (f && remote->remote_ip == htonl(INADDR_ANY)) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -1181,12 +1199,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
 	} else
-		rdst0 = &f->remote;
+		rdst0 = remotes_head(f);
 
 	rc = NETDEV_TX_OK;
 
 	/* if there are multiple destinations, send copies */
-	for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
+	rdst = rdst0;
+	hlist_for_each_entry_continue_rcu(rdst, hlist) {
 		struct sk_buff *skb1;
 
 		skb1 = skb_clone(skb, GFP_ATOMIC);
-- 
1.8.1.5


--
Sincerely yours,
Mike.
