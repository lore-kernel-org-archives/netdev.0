From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [RESEND] [PATCH stable-2.6.32] Phonet: disable network namespace support
Date: Thu,  7 Oct 2010 15:17:01 +0300
Message-ID: <1286453821-27741-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:41835 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab0JGMRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 08:17:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Network namespace in the Phonet socket stack causes an OOPS when a
namespace is destroyed. This occurs as the loopback exit_net handler is
called after the Phonet exit_net handler, and re-enters the Phonet
stack. I cannot think of any nice way to fix this in kernel <=3D 2.6.32=
=2E

=46or lack of a better solution, disable namespace support completely.
If you need that, upgrade to a newer kernel.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Acked-by: David S. Miller <davem@davemloft>
Cc: Ben Hutchings <ben@decadent.org.uk>
---
 net/phonet/af_phonet.c  |    4 ++++
 net/phonet/pn_dev.c     |   12 ++++++++++--
 net/phonet/pn_netlink.c |    9 ++++++++-
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index f60c0c2..519ff9d 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -67,6 +67,8 @@ static int pn_socket_create(struct net *net, struct s=
ocket *sock, int protocol)
 	struct phonet_protocol *pnp;
 	int err;
=20
+	if (!net_eq(net, &init_net))
+		return -EAFNOSUPPORT;
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
=20
@@ -353,6 +355,8 @@ static int phonet_rcv(struct sk_buff *skb, struct n=
et_device *dev,
 	struct sockaddr_pn sa;
 	u16 len;
=20
+	if (!net_eq(net, &init_net))
+		goto out;
 	/* check we have at least a full Phonet header */
 	if (!pskb_pull(skb, sizeof(struct phonethdr)))
 		goto out;
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 5f42f30..5a2275c 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -246,7 +246,11 @@ static struct notifier_block phonet_device_notifie=
r =3D {
 /* Per-namespace Phonet devices handling */
 static int phonet_init_net(struct net *net)
 {
-	struct phonet_net *pnn =3D kmalloc(sizeof(*pnn), GFP_KERNEL);
+	struct phonet_net *pnn;
+
+	if (!net_eq(net, &init_net))
+		return 0;
+	pnn =3D kmalloc(sizeof(*pnn), GFP_KERNEL);
 	if (!pnn)
 		return -ENOMEM;
=20
@@ -263,9 +267,13 @@ static int phonet_init_net(struct net *net)
=20
 static void phonet_exit_net(struct net *net)
 {
-	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
+	struct phonet_net *pnn;
 	struct net_device *dev;
=20
+	if (!net_eq(net, &init_net))
+		return;
+	pnn =3D net_generic(net, phonet_net_id);
+
 	rtnl_lock();
 	for_each_netdev(net, dev)
 		phonet_device_destroy(dev);
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index d21fd35..7acab1e 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -68,6 +68,8 @@ static int addr_doit(struct sk_buff *skb, struct nlms=
ghdr *nlh, void *attr)
 	int err;
 	u8 pnaddr;
=20
+	if (!net_eq(net, &init_net))
+		return -EOPNOTSUPP;
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
=20
@@ -124,12 +126,16 @@ nla_put_failure:
=20
 static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callback=
 *cb)
 {
+	struct net *net =3D sock_net(skb->sk);
 	struct phonet_device_list *pndevs;
 	struct phonet_device *pnd;
 	int dev_idx =3D 0, dev_start_idx =3D cb->args[0];
 	int addr_idx =3D 0, addr_start_idx =3D cb->args[1];
=20
-	pndevs =3D phonet_device_list(sock_net(skb->sk));
+	if (!net_eq(net, &init_net))
+		goto skip;
+
+	pndevs =3D phonet_device_list(net);
 	spin_lock_bh(&pndevs->lock);
 	list_for_each_entry(pnd, &pndevs->list, list) {
 		u8 addr;
@@ -154,6 +160,7 @@ static int getaddr_dumpit(struct sk_buff *skb, stru=
ct netlink_callback *cb)
=20
 out:
 	spin_unlock_bh(&pndevs->lock);
+skip:
 	cb->args[0] =3D dev_idx;
 	cb->args[1] =3D addr_idx;
=20
--=20
1.7.0.4

