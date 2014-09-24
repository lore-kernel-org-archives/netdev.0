From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 14/24] net: rbridge: Add get_node function
Date: Wed, 24 Sep 2014 17:52:10 +0200
Message-ID: <1411573940-14079-15-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:37848 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020AbaIXP6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:11 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allow daemon to get any node information
daemon has to provide a netlink message containing the nickname of
requested node.
This function is provided but not used by the daemon for the moment
it can be used to check information accuracy in futur version

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr_netlink.c | 61 ++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 61 insertions(+)

diff --git a/net/bridge/rbridge/rbr_netlink.c b/net/bridge/rbridge/rbr_=
netlink.c
index bb893f0..983d647 100644
--- a/net/bridge/rbridge/rbr_netlink.c
+++ b/net/bridge/rbridge/rbr_netlink.c
@@ -123,7 +123,68 @@ static int trill_cmd_set_nicks_info(struct sk_buff=
 *skb, struct genl_info *info)
=20
 static int trill_cmd_get_nicks_info(struct sk_buff *skb, struct genl_i=
nfo *info)
 {
+	struct sk_buff *msg;
+	struct nlattr *attr;
+	struct rbr_nickinfo rbr_ni;
+	void *data;
+	struct trill_nl_header *trnlhdr;
+	struct net_device *source_port =3D NULL;
+	struct net *net =3D sock_net(skb->sk);
+	struct net_bridge_port *p =3D NULL;
+	struct rbr_node *rbr_node;
+	int err =3D -EINVAL;
+
+	nla_memcpy(&rbr_ni, info->attrs[TRILL_ATTR_BIN], sizeof(rbr_ni));
+	trnlhdr =3D info->userhdr;
+	if (trnlhdr->ifindex)
+		source_port =3D __dev_get_by_index(net, trnlhdr->ifindex);
+
+	if (!source_port)
+		goto fail;
+
+	p =3D br_port_get_rcu(source_port);
+	if (!p || !(p->br) || !(p->br->rbr))
+		goto fail;
+
+	rbr_node =3D rbr_find_node(p->br->rbr, rbr_ni.nick);
+	if (!rbr_node)
+		goto fail;
+
+	err =3D -ENOMEM;
+	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		goto fail_put;
+
+	trnlhdr =3D genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			      &trill_genl_family, sizeof(*trnlhdr),
+			      TRILL_CMD_GET_NICKS_INFO);
+	if (!trnlhdr)
+		goto fail_free;
+
+	attr =3D nla_reserve(msg, TRILL_ATTR_BIN,
+			   RBR_NI_TOTALSIZE(rbr_node->rbr_ni));
+	if (!attr)
+		goto fail_free;
+
+	data =3D nla_data(attr);
+	trnlhdr->ifindex =3D KERNL_RESPONSE_INTERFACE;
+	memcpy(data, rbr_node->rbr_ni, RBR_NI_TOTALSIZE(rbr_node->rbr_ni));
+	genlmsg_end(msg, trnlhdr);
+	rbr_node_put(rbr_node);
+
+	err =3D genlmsg_reply(msg, info);
+	if (err)
+		goto fail_put;
+
 	return 0;
+
+ fail_free:
+	nlmsg_free(msg);
+ fail_put:
+	rbr_node_put(rbr_node);
+ fail:
+	printk(KERN_WARNING "trill_cmd_get_nicks_info FAILED\n");
+	return err;
 }
=20
 static int trill_cmd_add_nicks_info(struct sk_buff *skb, struct genl_i=
nfo *info)
--=20
1.9.1
