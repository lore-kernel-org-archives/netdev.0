From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 10/24] net: rbridge: Add elected dtroot
Date: Wed, 24 Sep 2014 17:52:06 +0200
Message-ID: <1411573940-14079-11-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:47587 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbaIXP6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:11 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

provide function to get the locally elected distributed tree root from =
the daemon
in TRILL RFC multiple tree root can be elected but this is not mendator=
y
for this first version we use a unique distributed tree root

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_private.h          |  1 +
 net/bridge/rbridge/rbr.c         | 17 +++++++++++++++++
 net/bridge/rbridge/rbr_netlink.c | 21 +++++++++++++++++++++
 3 files changed, 39 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6952db8..2d15b35 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -815,6 +815,7 @@ ssize_t br_show_bridge_id(char *buf, const struct b=
ridge_id *id);
 /* rbridge/rbr.c */
 #ifdef CONFIG_TRILL
 void br_trill_set_enabled(struct net_bridge *br, unsigned long val);
+extern int set_treeroot(struct rbr *rbr, uint16_t treeroot);
 #endif
=20
 /* br_stp_bpdu.c */
diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 41d47db..8d6d37e 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -76,3 +76,20 @@ void br_trill_set_enabled(struct net_bridge *br, uns=
igned long val)
 			br_trill_stop(br);
 	}
 }
+
+int set_treeroot(struct rbr *rbr, uint16_t treeroot)
+{
+	if (unlikely(!VALID_NICK(treeroot))) {
+		pr_warn_ratelimited
+		    ("rbr_set_treeroot: given tree root not valid\n");
+		goto set_tree_root_fail;
+	}
+	if (rbr->treeroot !=3D treeroot) {
+		spin_lock_bh(&rbr->br->lock);
+		rbr->treeroot =3D treeroot;
+		spin_unlock_bh(&rbr->br->lock);
+	}
+	return 0;
+ set_tree_root_fail:
+	return ENOENT;
+}
diff --git a/net/bridge/rbridge/rbr_netlink.c b/net/bridge/rbridge/rbr_=
netlink.c
index ccba5ae..889e6c8 100644
--- a/net/bridge/rbridge/rbr_netlink.c
+++ b/net/bridge/rbridge/rbr_netlink.c
@@ -56,7 +56,28 @@ static int trill_cmd_add_nicks_info(struct sk_buff *=
skb, struct genl_info *info)
 static int trill_cmd_set_treeroot_id(struct sk_buff *skb,
 				     struct genl_info *info)
 {
+	int err =3D -EINVAL;
+	u16 nickname;
+	struct trill_nl_header *trnlhdr;
+	struct net_device *source_port =3D NULL;
+	struct net *net =3D sock_net(skb->sk);
+	struct net_bridge_port *p =3D NULL;
+	nickname =3D nla_get_u16(info->attrs[TRILL_ATTR_U16]);
+	trnlhdr =3D info->userhdr;
+	if (trnlhdr->ifindex)
+		source_port =3D __dev_get_by_index(net, trnlhdr->ifindex);
+	if (!source_port)
+		goto fail;
+	p =3D br_port_get_rcu(source_port);
+	if (!p || !(p->br) || !(p->br->rbr))
+		goto fail;
+	err =3D set_treeroot(p->br->rbr, htons(nickname));
+	if (err)
+		goto fail;
 	return 0;
+ fail:
+	printk(KERN_WARNING "trill_cmd_set_treeroot_id FAILED\n");
+	return err;
 }
=20
 /* trill_cmd_get_rbridge when started daemon inquire for already
--=20
1.9.1
