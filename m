From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 09/24] net: rbridge: Get Rbridge nickname from daemon
Date: Wed, 24 Sep 2014 17:52:05 +0200
Message-ID: <1411573940-14079-10-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:55205 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbaIXP6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:12 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

added get and set nickname functions that allows daemon to check if
RBridge aleady have a nickname (daemon crash scenario)
if yes and nickname uniqueness is verified on toplogy no set nickname i=
s provided by the daemon
if nickname is not unique or not existant daemon will set the automatic=
ally generated nickanme

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr_netlink.c | 92 ++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 92 insertions(+)

diff --git a/net/bridge/rbridge/rbr_netlink.c b/net/bridge/rbridge/rbr_=
netlink.c
index eb7c902..ccba5ae 100644
--- a/net/bridge/rbridge/rbr_netlink.c
+++ b/net/bridge/rbridge/rbr_netlink.c
@@ -59,14 +59,106 @@ static int trill_cmd_set_treeroot_id(struct sk_buf=
f *skb,
 	return 0;
 }
=20
+/* trill_cmd_get_rbridge when started daemon inquire for already
+ * existant nickname
+ * bridge with TRILL capability may already have a nickname
+ * is daemon have crashed
+ */
 static int trill_cmd_get_rbridge(struct sk_buff *skb, struct genl_info=
 *info)
 {
+	struct trill_nl_header *trnlhdr;
+	struct sk_buff *msg;
+	struct net_bridge_port *p;
+	struct net_device *source_port =3D NULL;
+	struct net *net =3D sock_net(skb->sk);
+	u16 nickname;
+	int err =3D -EINVAL;
+	int trill_genlseqnb =3D info->snd_seq;
+
+	trnlhdr =3D info->userhdr;
+	if (trnlhdr->ifindex)
+		source_port =3D __dev_get_by_index(net, trnlhdr->ifindex);
+
+	if (!source_port)
+		goto fail;
+
+	p =3D br_port_get_rcu(source_port);
+	if (!p || !(p->br))
+		goto fail;
+
+	if (p->br->rbr)
+		nickname =3D ntohs(p->br->rbr->nick);
+	else
+		nickname =3D RBRIDGE_NICKNAME_NONE;
+
+	err =3D -ENOMEM;
+	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		goto fail;
+
+	trnlhdr =3D genlmsg_put(msg, info->snd_portid, trill_genlseqnb,
+			      &trill_genl_family, sizeof(*trnlhdr),
+			      TRILL_CMD_GET_RBRIDGE);
+	if (!trnlhdr)
+		goto fail_free;
+
+	trnlhdr->ifindex =3D KERNL_RESPONSE_INTERFACE;
+	nla_put_u16(msg, TRILL_ATTR_U16, nickname);
+	genlmsg_end(msg, trnlhdr);
+
+	err =3D genlmsg_reply(msg, info);
+	if (err)
+		goto fail;
+
 	return 0;
+
+ fail_free:
+	nlmsg_free(msg);
+ fail:
+	printk(KERN_WARNING "trill_cmd_get_rbridge FAILED\n");
+	return err;
 }
=20
 static int trill_cmd_set_rbridge(struct sk_buff *skb, struct genl_info=
 *info)
 {
+	struct trill_nl_header *trnlhdr;
+	struct net_device *source_port =3D NULL;
+	struct net_bridge_port *p =3D NULL;
+	struct net_bridge *br =3D NULL;
+	struct net *net =3D sock_net(skb->sk);
+	u16 nickname =3D nla_get_u16(info->attrs[TRILL_ATTR_U16]);
+
+	trnlhdr =3D info->userhdr;
+	if (trnlhdr->ifindex)
+		source_port =3D __dev_get_by_index(net, trnlhdr->ifindex);
+
+	if (!source_port)
+		goto fail;
+
+	p =3D br_port_get_rcu(source_port);
+	if (!p || !(p->br))
+		goto fail;
+
+	br =3D p->br;
+
+	/* if daemon has started and bridge TRILL capability
+	 * is not enabled then start it
+	 */
+	if (br->trill_enabled =3D=3D BR_NO_TRILL)
+		br_trill_set_enabled(br, 1);
+
+	if (!(br->rbr))
+		goto fail;
+
+	spin_lock_bh(&br->lock);
+	br->rbr->nick =3D htons(nickname);
+	spin_unlock_bh(&br->lock);
+
 	return 0;
+
+ fail:
+	printk(KERN_WARNING "trill_cmd_set_bridge FAILED\n");
+	return -EINVAL;
 }
=20
 static int trill_cmd_port_flush(struct sk_buff *skb, struct genl_info =
*info)
--=20
1.9.1
