From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: Re: [PATCH 1/5] sit: Fail to create tunnel, if it already exists
Date: Tue, 19 May 2009 11:06:14 +0200
Message-ID: <200905191106.15044.contact@saschahlusiak.de>
References: <1242396760-30568-1-git-send-email-contact@saschahlusiak.de> <20090518.154806.174728278.davem@davemloft.net> <20090518.193145.257080801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_HanEK/1uBEjYuSe"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:57947 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbZESJFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 05:05:08 -0400
In-Reply-To: <20090518.193145.257080801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_HanEK/1uBEjYuSe
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Dienstag 19 Mai 2009 04:31:45 schrieb David Miller:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 18 May 2009 15:48:06 -0700 (PDT)
>
> > All 5 patches applied to net-next-2.6, thanks.
>
> Actually, no, I reverted all of this garbage.
>
> Let me know when you have a version of your changes that
> actually compile.
>
>   CC [M]  net/ipv6/sit.o
> net/ipv6/sit.c: In function =E2=80=98ipip6_tunnel_rs_timer=E2=80=99:
> net/ipv6/sit.c:235: error: incompatible type for argument 1 of =E2=80=98_=
spin_lock=E2=80=99
> net/ipv6/sit.c:256: error: invalid type argument of =E2=80=98->=E2=80=99
Thanks, fixed the offending patch. Compiled for me though so apology for th=
e=20
inconvenience.


--Boundary-00=_HanEK/1uBEjYuSe
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0005-sit-stateless-autoconf-for-isatap.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0005-sit-stateless-autoconf-for-isatap.patch"

=46rom 710a2df59c785c93d92a6f85fc0a5b3cc79c2f97 Mon Sep 17 00:00:00 2001
=46rom: Sascha Hlusiak <contact@saschahlusiak.de>
Date: Tue, 19 May 2009 11:00:27 +0200
Subject: [PATCH 5/5] sit: stateless autoconf for isatap

=46rom each potential router in the PRL, a router solicitation will
be sent periodically. The rs_delay can be speficied when adding the
PRL entry and defaults to 15 minutes.

The RS is sent from every link local adress that's assigned to the
tunnel interface. It's directed to the (guessed) linklocal address
of the router and is sent through the tunnel.

Better: send to ff02::2 encapsuled in unicast directed to router-v4.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
=2D--
 include/linux/if_tunnel.h |    2 +-
 include/net/ipip.h        |    7 +++++
 net/ipv6/ndisc.c          |    1 +
 net/ipv6/sit.c            |   58 +++++++++++++++++++++++++++++++++++++++++=
++++
 4 files changed, 67 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 5a9aae4..5eb9b0f 100644
=2D-- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -44,7 +44,7 @@ struct ip_tunnel_prl {
 	__u16			flags;
 	__u16			__reserved;
 	__u32			datalen;
=2D	__u32			__reserved2;
+	__u32			rs_delay;
 	/* data follows */
 };
=20
diff --git a/include/net/ipip.h b/include/net/ipip.h
index fdf9bd7..5d3036f 100644
=2D-- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -28,11 +28,18 @@ struct ip_tunnel
 	unsigned int			prl_count;	/* # of entries in PRL */
 };
=20
+/* ISATAP: default interval between RS in secondy */
+#define IPTUNNEL_RS_DEFAULT_DELAY	(900)
+
 struct ip_tunnel_prl_entry
 {
 	struct ip_tunnel_prl_entry	*next;
 	__be32				addr;
 	u16				flags;
+	unsigned long			rs_delay;
+	struct timer_list		rs_timer;
+	struct ip_tunnel		*tunnel;
+	spinlock_t			lock;
 };
=20
 #define IPTUNNEL_XMIT() do {						\
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9f061d1..f787ac4 100644
=2D-- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -658,6 +658,7 @@ void ndisc_send_rs(struct net_device *dev, const struct=
 in6_addr *saddr,
 		     &icmp6h, NULL,
 		     send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
+EXPORT_SYMBOL(ndisc_send_rs);
=20
=20
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *sk=
b)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3fd0600..0535809 100644
=2D-- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -15,6 +15,7 @@
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
  * Fred Templin <fred.l.templin@boeing.com>:	isatap support
+ * Sascha Hlusiak <mail@saschahlusiak.de>:	stateless autoconf for isatap
  */
=20
 #include <linux/module.h>
@@ -222,6 +223,44 @@ failed:
 	return NULL;
 }
=20
+static void ipip6_tunnel_rs_timer(unsigned long data)
+{
+	struct ip_tunnel_prl_entry *p =3D (struct ip_tunnel_prl_entry *) data;
+	struct inet6_dev *ifp;
+	struct inet6_ifaddr *addr;
+
+	spin_lock(&p->lock);
+	ifp =3D __in6_dev_get(p->tunnel->dev);
+
+	spin_lock(&ifp->lock);
+	for (addr =3D ifp->addr_list; addr; addr =3D addr->if_next) {
+		struct in6_addr rtr;
+
+		if (!(ipv6_addr_type(&addr->addr) & IPV6_ADDR_LINKLOCAL))
+			continue;
+
+		/* Send RS to guessed linklocal address of router
+		 *
+		 * Better: send to ff02::2 encapsuled in unicast directly
+		 * to router-v4 instead of guessing the v6 address.
+		 *
+		 * Cisco/Windows seem to not set the u/l bit correctly,
+		 * so we won't guess right.
+		 */
+		ipv6_addr_set(&rtr,  htonl(0xFE800000), 0, 0, 0);
+		if (!__ipv6_isatap_ifid(rtr.s6_addr + 8,
+					p->addr)) {
+			ndisc_send_rs(p->tunnel->dev, &addr->addr, &rtr);
+		}
+	}
+	spin_unlock(&ifp->lock);
+
+	mod_timer(&p->rs_timer, jiffies + HZ * p->rs_delay);
+	spin_unlock(&p->lock);
+
+	return;
+}
+
 static struct ip_tunnel_prl_entry *
 __ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
 {
@@ -280,6 +319,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 			continue;
 		kp[c].addr =3D prl->addr;
 		kp[c].flags =3D prl->flags;
+		kp[c].rs_delay =3D prl->rs_delay;
 		c++;
 		if (kprl.addr !=3D htonl(INADDR_ANY))
 			break;
@@ -329,11 +369,23 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_t=
unnel_prl *a, int chg)
 	}
=20
 	p->next =3D t->prl;
+	p->tunnel =3D t;
 	t->prl =3D p;
 	t->prl_count++;
+
+	spin_lock_init(&p->lock);
+	setup_timer(&p->rs_timer, ipip6_tunnel_rs_timer, (unsigned long) p);
 update:
 	p->addr =3D a->addr;
 	p->flags =3D a->flags;
+	p->rs_delay =3D a->rs_delay;
+	if (p->rs_delay =3D=3D 0)
+		p->rs_delay =3D IPTUNNEL_RS_DEFAULT_DELAY;
+	spin_lock(&p->lock);
+	del_timer(&p->rs_timer);
+	if (p->flags & PRL_DEFAULT)
+		mod_timer(&p->rs_timer, jiffies + 1);
+	spin_unlock(&p->lock);
 out:
 	write_unlock(&ipip6_lock);
 	return err;
@@ -352,6 +404,9 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tun=
nel_prl *a)
 			if ((*p)->addr =3D=3D a->addr) {
 				x =3D *p;
 				*p =3D x->next;
+				spin_lock(&x->lock);
+				del_timer(&x->rs_timer);
+				spin_unlock(&x->lock);
 				kfree(x);
 				t->prl_count--;
 				goto out;
@@ -362,6 +417,9 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tun=
nel_prl *a)
 		while (t->prl) {
 			x =3D t->prl;
 			t->prl =3D t->prl->next;
+			spin_lock(&x->lock);
+			del_timer(&x->rs_timer);
+			spin_unlock(&x->lock);
 			kfree(x);
 			t->prl_count--;
 		}
=2D-=20
1.6.3


--Boundary-00=_HanEK/1uBEjYuSe--
