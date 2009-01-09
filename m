From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: address preservation on link down
Date: Fri, 9 Jan 2009 09:31:05 -0800
Message-ID: <20090109093105.742cf72e@extreme>
References: <20090108135614.23aed603@extreme>
	<20090108.140339.00980764.davem@davemloft.net>
	<20090108171415.1d282743@extreme>
	<200901091002.07224.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: "=?UTF-8?B?UsOpbWk=?= Denis-Courmont" <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59650 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926AbZAIRbI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 12:31:08 -0500
In-Reply-To: <200901091002.07224.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Jan 2009 10:02:06 +0200
"R=C3=A9mi Denis-Courmont" <remi.denis-courmont@nokia.com> wrote:

> On Friday 09 January 2009 03:14:15 ext Stephen Hemminger, you wrote:
> > When an interface goes down, IPV6 deletes all addresses unlike IPV4=
=2E This
> > is a problem since it can break routing protocols and other applica=
tions.
> > It looks like this was done to handle DAD, but is a big stick solut=
ion when
> > other code is possible.
> >
> > The following patch changes the behaviour to delete link local addr=
esses
> > but keep all configured addresses and restart DAD when interface co=
mes back
> > up.
>=20
> Let alone the backward compatibility problem for a minute. I have two=
 _other_=20
> problems with this:
>=20
> 1/ If DAD should fail when the interface is brought back up, wouldn't=
 all the=20
> EAU-64 autoconfigured address become invalid, rather than just the li=
nk-local=20
> one?
>=20
> 2/ In some case the link-local address is assigned by userland, no di=
fferent=20
> from the other ones. At least miredo is behaving this way.
>=20

1: The address DAD path is same as the initial setup. I.e. it is same a=
s if
   the address was added manually (after ifup)
2: New patch honors the permanent flag. Another alternative would be to=
 add a new
   IFA_F_DYNAMIC flag

Updated patch that combines earlier efforts..
---

By default, IPV6 deletes all addresses when an interface is deconfigure=
d.
This behaviour is different the IPV4 and confusing, so make it optional=
=2E
Add a new sysctl /proc/sys/net/ipv6/conf/ethX/address_flush that contro=
ls this.

The new behaviour that happens only if address_flush is set to zero is:
  * all addresses are flushed on device deletion
  * linklocal addresses are flushed unless the permanent flag is set
  * other addresses are saved but duplicate address detection is restar=
ted
    unless nodad flag has been set.



---
 Documentation/networking/ip-sysctl.txt |    9 +++++
 include/linux/ipv6.h                   |    2 +
 net/ipv6/addrconf.c                    |   50 ++++++++++++++++++++++++=
++-------
 3 files changed, 51 insertions(+), 10 deletions(-)

--- a/Documentation/networking/ip-sysctl.txt	2009-01-09 08:48:56.701039=
688 -0800
+++ b/Documentation/networking/ip-sysctl.txt	2009-01-09 09:23:13.208788=
522 -0800
@@ -925,6 +925,15 @@ accept_source_route - INTEGER
=20
 	Default: 0
=20
+address_flush - BOOLEAN
+	Flush all addresses when link goes down
+	Default: TRUE
+
+	When network device is set to admin down:
+	  TRUE  - Delete all addresses
+	  FALSE - Only addresses that are temporary or linklocal and not perm=
anent
+	          are deleted. Other addresses restart DAD (if configured).
+
 autoconf - BOOLEAN
 	Autoconfigure addresses using Prefix Information in Router=20
 	Advertisements.
--- a/include/linux/ipv6.h	2009-01-09 08:49:14.170039111 -0800
+++ b/include/linux/ipv6.h	2009-01-09 08:57:33.592912530 -0800
@@ -166,6 +166,7 @@ struct ipv6_devconf {
 #endif
 	__s32		disable_ipv6;
 	__s32		accept_dad;
+	__s32		address_flush;
 	void		*sysctl;
 };
 #endif
@@ -200,6 +201,7 @@ enum {
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
+	DEVCONF_ADDRESS_FLUSH,
 	DEVCONF_MAX
 };
=20
--- a/net/ipv6/addrconf.c	2009-01-09 08:48:48.184789198 -0800
+++ b/net/ipv6/addrconf.c	2009-01-09 09:15:53.288788798 -0800
@@ -186,6 +186,7 @@ static struct ipv6_devconf ipv6_devconf=20
 	.accept_source_route	=3D 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		=3D 0,
 	.accept_dad		=3D 1,
+	.address_flush  =3D 1,
 };
=20
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly =3D {
@@ -220,6 +221,7 @@ static struct ipv6_devconf ipv6_devconf_
 	.accept_source_route	=3D 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		=3D 0,
 	.accept_dad		=3D 1,
+	.address_flush  =3D 1,
 };
=20
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -2678,18 +2680,37 @@ static int addrconf_ifdown(struct net_de
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	while ((ifa =3D idev->addr_list) !=3D NULL) {
-		idev->addr_list =3D ifa->if_next;
-		ifa->if_next =3D NULL;
-		ifa->dead =3D 1;
-		addrconf_del_timer(ifa);
-		write_unlock_bh(&idev->lock);
+	/* clear regular address list on removal */
+	bifa =3D &idev->addr_list;
+	while ((ifa =3D *bifa) !=3D NULL) {
+		if (how || idev->cnf.address_flush ||
+		    ((ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)
+		     && !(ifa->flags & IFA_F_PERMANENT))) {
+			*bifa =3D ifa->if_next;
+			ifa->if_next =3D NULL;
+			ifa->dead =3D 1;
+			addrconf_del_timer(ifa);
+			write_unlock_bh(&idev->lock);
+
+			__ipv6_ifa_notify(RTM_DELADDR, ifa);
+			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+			in6_ifa_put(ifa);
=20
-		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
-		in6_ifa_put(ifa);
+			write_lock_bh(&idev->lock);
+			continue;
+		}
=20
-		write_lock_bh(&idev->lock);
+		bifa =3D &ifa->if_next;
+		if (ifa->flags & IFA_F_NODAD)
+			continue;
+
+		/* Retain address but force DAD */
+		ifa->flags |=3D IFA_F_TENTATIVE;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+		if (idev->cnf.optimistic_dad &&
+		    !dev_net(idev->dev)->ipv6.devconf_all->forwarding)
+			ifa->flags |=3D IFA_F_OPTIMISTIC;
+#endif
 	}
 	write_unlock_bh(&idev->lock);
=20
@@ -3697,6 +3718,7 @@ static inline void ipv6_store_devconf(st
 #endif
 	array[DEVCONF_DISABLE_IPV6] =3D cnf->disable_ipv6;
 	array[DEVCONF_ACCEPT_DAD] =3D cnf->accept_dad;
+	array[DEVCONF_ADDRESS_FLUSH] =3D cnf->address_flush;
 }
=20
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4271,6 +4293,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	=3D	proc_dointvec,
 		},
 		{
+			.ctl_name	=3D	CTL_UNNUMBERED,
+			.procname	=3D	"address_flush",
+			.data		=3D	&ipv6_devconf.address_flush,
+			.maxlen		=3D	sizeof(int),
+			.mode		=3D	0644,
+			.proc_handler	=3D	&proc_dointvec,
+		},
+		{
 			.ctl_name	=3D	0,	/* sentinel */
 		}
 	},
