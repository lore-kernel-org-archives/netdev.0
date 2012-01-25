From: Tony Zelenoff <antonz@parallels.com>
Subject: [RFC] Allow ipv6 proxies and arp proxies be shown with ip
Date: Wed, 25 Jan 2012 13:44:58 +0400
Message-ID: <1327484698-344265-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tony Zelenoff <antonz@parallels.com>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <netdev@vger.kernel.org>,
	<xemul@parallels.com>
To: <ynot@mohnatka.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:49407 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab2AYJuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 04:50:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When i trying to add neighbour proxy with ip and then show it -
nothing happens but the proxy really added and work inside kernel.
$ ip neigh add proxy 2001::1 dev eth0
$ ip -6 neigh show
$

This is intended, as was written here
http://www.uwsg.iu.edu/hypermail/linux/kernel/0110.2/index.html#523
But, ~11 years were passed and this command is still alive and useful.
Also ipv6 protocol bring new feature: ND proxy which i want to use.
It described in RFC 4389 Neighbor Discovery Proxies. So, from my
point of view, the ip utility must show all neighbour proxies added to it.
Arp proxies is discussable, but better to show them too.

To do it - the additional storage of neighbour proxies should be processed
and dumped to requestor same way as neighbour tables.

Unfortunately proper filling of proxy neighbour info is not possible in
case of compatibility with ip itself. Returning structure field which
store state of record is reached its 8 bits limit and new flag showing
proxy can't be added. And at this point i'm stucked a bit. The ip utility
must show that exact address is not just neighbour, but is a proxy. Can
somebody advice me how to do it? Or maybe the whole idea is not good at all,
if so - please tell me why.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
CC: davem@davemloft.net
CC: kuznet@ms2.inr.ac.ru
CC: netdev@vger.kernel.org
CC: xemul@parallels.com

---
 net/core/neighbour.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5ac07d3..73ea97e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2134,6 +2134,38 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static int pneigh_fill_info(struct sk_buff *skb, struct pneigh_entry *pn,
+			    u32 pid, u32 seq, int type, unsigned int flags,
+			    struct neigh_table *tbl)
+{
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family	 = tbl->family;
+	ndm->ndm_pad1    = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags	 = pn->flags;
+	ndm->ndm_type	 = NDA_DST;
+	ndm->ndm_ifindex = pn->dev->ifindex;
+	/* Let proxy neighbour be disaplayed as permanent entry.
+	 * The problem: there is no space in u8 struct member
+	 * to create and set new flag like NUD_PROXY. */
+	ndm->ndm_state	 = NUD_PERMANENT;
+
+	NLA_PUT(skb, NDA_DST, tbl->key_len, pn->key);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
 static void neigh_update_notify(struct neighbour *neigh)
 {
 	call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
@@ -2183,6 +2215,50 @@ out:
 	return rc;
 }
 
+static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
+			     struct netlink_callback *cb)
+{
+	struct pneigh_entry *n;
+	struct net *net = sock_net(skb->sk);
+	int rc, h, s_h = cb->args[3];
+	int idx, s_idx = idx = cb->args[4];
+
+	read_lock_bh(&tbl->lock);
+
+	for (h = 0; h <= PNEIGH_HASHMASK; h++) {
+		if (h < s_h)
+			continue;
+		if (h > s_h)
+			s_idx = 0;
+		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
+			if (dev_net(n->dev) != net)
+				continue;
+			if (idx < s_idx)
+				goto next;
+
+			if (pneigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
+					    cb->nlh->nlmsg_seq,
+					    RTM_NEWNEIGH,
+					    NLM_F_MULTI, tbl) <= 0) {
+				read_unlock_bh(&tbl->lock);
+				rc = -1;
+				goto out;
+			}
+
+		next:
+			idx++;
+		}
+	}
+
+	read_unlock_bh(&tbl->lock);
+	rc = skb->len;
+out:
+	cb->args[3] = h;
+	cb->args[4] = idx;
+	return rc;
+
+}
+
 static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct neigh_table *tbl;
@@ -2200,6 +2276,9 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 						sizeof(cb->args[0]));
 		if (neigh_dump_table(tbl, skb, cb) < 0)
 			break;
+
+		if (pneigh_dump_table(tbl, skb, cb) < 0)
+			break;
 	}
 	read_unlock(&neigh_tbl_lock);
 
-- 
1.7.1
