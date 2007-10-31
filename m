From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC 2/2] [IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.
Date: Tue, 30 Oct 2007 17:12:55 -0700
Message-ID: <20071031001255.GI8285@linux.vnet.ibm.com>
References: <20071030.145254.120595012.yoshfuji@linux-ipv6.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37296 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbXJaAM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 20:12:57 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9V0CvRx025096
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 20:12:57 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9V0CuIk114190
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 18:12:56 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9V0CuxH013276
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 18:12:56 -0600
Content-Disposition: inline
In-Reply-To: <20071030.145254.120595012.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 02:52:54PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

Looks good from an RCU perspective.  A couple questions below about
hlist_for_each_entry_safe().

							Thanx, Paul

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/linux/if_addrlabel.h |   55 ++++
>  include/linux/rtnetlink.h    |    7 +
>  include/net/addrconf.h       |    8 +
>  net/ipv6/Makefile            |    1 +
>  net/ipv6/addrconf.c          |   40 +---
>  net/ipv6/addrlabel.c         |  566 ++++++++++++++++++++++++++++++++=
++++++++++
>  6 files changed, 646 insertions(+), 31 deletions(-)
>=20
> diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabe=
l.h
> new file mode 100644
> index 0000000..66978a5
> --- /dev/null
> +++ b/include/linux/if_addrlabel.h
> @@ -0,0 +1,55 @@
> +/*
> + * ifaddrlabel.h - netlink interface for address labels
> + *
> + * Copyright (C)2007 USAGI/WIDE Project,  All Rights Reserved.
> + *
> + * Redistribution and use in source and binary forms, with or withou=
t
> + * modification, are permitted provided that the following condition=
s
> + * are met:
> + *
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyri=
ght
> + *    notice, this list of conditions and the following disclaimer i=
n the
> + *    documentation and/or other materials provided with the distrib=
ution.
> + * 3. Neither the name of the project nor the names of its contribut=
ors
> + *    may be used to endorse or promote products derived from this s=
oftware
> + *    without specific prior written permission.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS=
'' AND
> + * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,=
 THE
> + * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULA=
R PURPOSE
> + * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE=
 LIABLE
> + * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONS=
EQUENTIAL
> + * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE=
 GOODS
> + * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPT=
ION)
> + * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRAC=
T, STRICT
> + * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN=
 ANY WAY
> + * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILI=
TY OF
> + * SUCH DAMAGE.
> + *
> + */
> +
> +#ifndef __LINUX_IF_ADDRLABEL_H
> +#define __LINUX_IF_ADDRLABEL_H
> +
> +struct ifaddrlblmsg
> +{
> +	__u8		ifal_family;		/* Address family */
> +	__u8		__ifal_reserved;	/* Reserved */
> +	__u8		ifal_prefixlen;		/* Prefix length */
> +	__u8		ifal_flags;		/* Flags */
> +	__u32		ifal_index;		/* Link index */
> +	__u32		ifal_seq;		/* sequence number */
> +};
> +
> +enum
> +{
> +	IFAL_ADDRESS =3D 1,
> +	IFAL_LABEL =3D 2,
> +	__IFAL_MAX
> +};
> +
> +#define IFAL_MAX	(__IFAL_MAX - 1)
> +
> +#endif
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 5bf6182..9a8bf01 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -100,6 +100,13 @@ enum {
>  	RTM_NEWNDUSEROPT =3D 68,
>  #define RTM_NEWNDUSEROPT RTM_NEWNDUSEROPT
>=20
> +	RTM_NEWADDRLABEL =3D 72,
> +#define RTM_NEWADDRLABEL RTM_NEWADDRLABEL
> +	RTM_DELADDRLABEL,
> +#define RTM_NEWADDRLABEL RTM_NEWADDRLABEL
> +	RTM_GETADDRLABEL,
> +#define RTM_GETADDRLABEL RTM_GETADDRLABEL
> +
>  	__RTM_MAX,
>  #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
>  };
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 33b593e..bccc2fe 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -84,6 +84,14 @@ extern void			addrconf_leave_solict(struct inet6_d=
ev *idev,
>  					struct in6_addr *addr);
>=20
>  /*
> + *	IPv6 Address Label subsystem (addrlabel.c)
> + */
> +extern int			ipv6_addr_label_init(void);
> +extern void			ipv6_addr_label_rtnl_register(void);
> +extern u32			ipv6_addr_label(const struct in6_addr *addr,
> +						int type, int ifindex);
> +
> +/*
>   *	multicast prototypes (mcast.c)
>   */
>  extern int ipv6_sock_mc_join(struct sock *sk, int ifindex,=20
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index 87c23a7..5ffa980 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile
> @@ -5,6 +5,7 @@
>  obj-$(CONFIG_IPV6) +=3D ipv6.o
>=20
>  ipv6-objs :=3D	af_inet6.o anycast.o ip6_output.o ip6_input.o addrcon=
f.o \
> +		addrlabel.o \
>  		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
>  		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
>  		exthdrs.o sysctl_net_ipv6.o datagram.o \
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8b408b7..5b6553f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -876,36 +876,6 @@ static inline int ipv6_saddr_preferred(int type)
>  	return 0;
>  }
>=20
> -/* static matching label */
> -static inline int ipv6_addr_label(const struct in6_addr *addr, int t=
ype,
> -				  int ifindex)
> -{
> - /*
> -  * 	prefix (longest match)	label
> -  * 	-----------------------------
> -  * 	::1/128			0
> -  * 	::/0			1
> -  * 	2002::/16		2
> -  * 	::/96			3
> -  * 	::ffff:0:0/96		4
> -  *	fc00::/7		5
> -  * 	2001::/32		6
> -  */
> -	if (type & IPV6_ADDR_LOOPBACK)
> -		return 0;
> -	else if (type & IPV6_ADDR_COMPATv4)
> -		return 3;
> -	else if (type & IPV6_ADDR_MAPPED)
> -		return 4;
> -	else if (addr->s6_addr32[0] =3D=3D htonl(0x20010000))
> -		return 6;
> -	else if (addr->s6_addr16[0] =3D=3D htons(0x2002))
> -		return 2;
> -	else if ((addr->s6_addr[0] & 0xfe) =3D=3D 0xfc)
> -		return 5;
> -	return 1;
> -}
> -
>  int ipv6_dev_get_saddr(struct net_device *daddr_dev,
>  		       struct in6_addr *daddr, struct in6_addr *saddr)
>  {
> @@ -4182,7 +4152,13 @@ EXPORT_SYMBOL(unregister_inet6addr_notifier);
>=20
>  int __init addrconf_init(void)
>  {
> -	int err =3D 0;
> +	int err;
> +
> +	if ((err =3D ipv6_addr_label_init()) < 0) {
> +		printk(KERN_CRIT "IPv6 Addrconf: cannot initialize default policy =
table: %d.\n",
> +			err);
> +		return err;
> +	}
>=20
>  	/* The addrconf netdev notifier requires that loopback_dev
>  	 * has it's ipv6 private information allocated and setup
> @@ -4233,6 +4209,8 @@ int __init addrconf_init(void)
>  	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL, inet6_dump_ifmcad=
dr);
>  	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL, inet6_dump_ifacaddr=
);
>=20
> +	ipv6_addr_label_rtnl_register();
> +
>  #ifdef CONFIG_SYSCTL
>  	addrconf_sysctl.sysctl_header =3D
>  		register_sysctl_table(addrconf_sysctl.addrconf_root_dir);
> diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
> new file mode 100644
> index 0000000..719e785
> --- /dev/null
> +++ b/net/ipv6/addrlabel.c
> @@ -0,0 +1,566 @@
> +/*
> + * IPv6 Address Label subsystem
> + * for the IPv6 "Default" Source Address Selection
> + *
> + * Copyright (C)2007 USAGI/WIDE Project
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1=
307  USA
> + *
> + */
> +/*
> + * Author:
> + * 	YOSHIFUJI Hideaki @ USAGI/WIDE Project <yoshfuji@linux-ipv6.org>
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/rcupdate.h>
> +#include <linux/in6.h>
> +#include <net/addrconf.h>
> +#include <linux/if_addrlabel.h>
> +#include <linux/netlink.h>
> +#include <linux/rtnetlink.h>
> +
> +#if 0
> +#define ADDRLABEL(x...) printk(x)
> +#else
> +#define ADDRLABEL(x...) do { ; } while(0)
> +#endif
> +
> +/*
> + * Policy Table
> + */
> +struct ip6addrlbl_entry
> +{
> +	struct in6_addr prefix;
> +	int prefixlen;
> +	int ifindex;
> +	int addrtype;
> +	u32 label;
> +	struct hlist_node list;
> +	atomic_t refcnt;
> +	struct rcu_head rcu;
> +};
> +
> +static struct ip6addrlbl_table
> +{
> +	struct hlist_head head;
> +	spinlock_t lock;
> +	u32 seq;
> +} ip6addrlbl_table;
> +
> +/*
> + * Default policy table (RFC3484 + extensions)
> + *
> + * prefix		addr_type	label
> + * -----------------------------------------------------------------=
--------
> + * ::1/128		LOOPBACK	0
> + * ::/0			N/A		1
> + * 2002::/16		N/A		2
> + * ::/96		COMPATv4	3
> + * ::ffff:0:0/96	V4MAPPED	4
> + * fc00::/7		N/A		5		ULA (RFC 4193)
> + * 2001::/32		N/A		6		Teredo (RFC 4380)
> + *
> + * Note: 0xffffffff is used if we do not have any policies.
> + */
> +
> +#define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
> +
> +static const __initdata struct ip6addrlbl_init_table
> +{
> +	const struct in6_addr *prefix;
> +	int prefixlen;
> +	u32 label;
> +} ip6addrlbl_init_table[] =3D {
> +	{	/* ::/0 */
> +		.prefix =3D &in6addr_any,
> +		.label =3D 1,
> +	},{	/* fc00::/7 */
> +		.prefix =3D &(struct in6_addr){{{ 0xfc }}},
> +		.prefixlen =3D 7,
> +		.label =3D 5,
> +	},{	/* 2002::/16 */
> +		.prefix =3D &(struct in6_addr){{{ 0x20, 0x02 }}},
> +		.prefixlen =3D 16,
> +		.label =3D 2,
> +	},{	/* 2001::/32 */
> +		.prefix =3D &(struct in6_addr){{{ 0x20, 0x01 }}},
> +		.prefixlen =3D 32,
> +		.label =3D 6,
> +	},{	/* ::ffff:0:0 */
> +		.prefix =3D &(struct in6_addr){{{ [10] =3D 0xff, [11] =3D 0xff }}}=
,
> +		.prefixlen =3D 96,
> +		.label =3D 4,
> +	},{	/* ::/96 */
> +		.prefix =3D &in6addr_any,
> +		.prefixlen =3D 96,
> +		.label =3D 3,
> +	},{	/* ::1/128 */
> +		.prefix =3D &in6addr_loopback,
> +		.prefixlen =3D 128,
> +		.label =3D 0,
> +	}
> +};
> +
> +/* Object management */
> +static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
> +{
> +	kfree(p);
> +}
> +
> +static inline int ip6addrlbl_hold(struct ip6addrlbl_entry *p)
> +{
> +	return atomic_inc_not_zero(&p->refcnt);
> +}
> +
> +static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
> +{
> +	if (atomic_dec_and_test(&p->refcnt))
> +		ip6addrlbl_free(p);
> +}
> +
> +static void ip6addrlbl_free_rcu(struct rcu_head *h)
> +{
> +	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
> +}
> +
> +/* Find label */
> +static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
> +			      const struct in6_addr *addr,
> +			      int addrtype, int ifindex)
> +{
> +	if (p->ifindex && p->ifindex !=3D ifindex)
> +		return 0;
> +	if (p->addrtype && p->addrtype !=3D addrtype)
> +		return 0;
> +	if (!ipv6_prefix_equal(addr, &p->prefix, p->prefixlen))
> +		return 0;
> +	return 1;
> +}
> +
> +static struct ip6addrlbl_entry *__ipv6_addr_label(const struct in6_a=
ddr *addr,
> +						  int type, int ifindex)
> +{
> +	struct hlist_node *pos;
> +	struct ip6addrlbl_entry *p;
> +	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
> +		if (__ip6addrlbl_match(p, addr, type, ifindex))
> +			return p;
> +	}
> +	return NULL;
> +}
> +
> +u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifind=
ex)
> +{
> +	u32 label;
> +	struct ip6addrlbl_entry *p;
> +
> +	type &=3D IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBAC=
K;
> +
> +	rcu_read_lock();
> +	p =3D __ipv6_addr_label(addr, type, ifindex);
> +	label =3D p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
> +	rcu_read_unlock();
> +
> +	ADDRLABEL(KERN_DEBUG "%s(addr=3D" NIP6_FMT ", type=3D%d, ifindex=3D=
%d) =3D> %08x\n",
> +			__FUNCTION__,
> +			NIP6(*addr), type, ifindex,
> +			label);
> +
> +	return label;
> +}
> +
> +/* allocate one entry */
> +struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *pre=
fix,
> +					  int prefixlen, int ifindex,
> +					  u32 label)
> +{
> +	struct ip6addrlbl_entry *newp;
> +	int addrtype;
> +
> +	ADDRLABEL(KERN_DEBUG "%s(prefix=3D" NIP6_FMT ", prefixlen=3D%d, ifi=
ndex=3D%d, label=3D%u)\n",
> +			__FUNCTION__,
> +			NIP6(*prefix), prefixlen,
> +			ifindex,
> +			(unsigned int)label);
> +
> +	addrtype =3D ipv6_addr_type(prefix) & (IPV6_ADDR_MAPPED | IPV6_ADDR=
_COMPATv4 | IPV6_ADDR_LOOPBACK);
> +
> +	switch (addrtype) {
> +	case IPV6_ADDR_MAPPED:
> +		if (prefixlen > 96)
> +			return ERR_PTR(-EINVAL);
> +		if (prefixlen < 96)
> +			addrtype =3D 0;
> +		break;
> +	case IPV6_ADDR_COMPATv4:
> +		if (prefixlen !=3D 96)
> +			addrtype =3D 0;
> +		break;
> +	case IPV6_ADDR_LOOPBACK:
> +		if (prefixlen !=3D 128)
> +			addrtype =3D 0;
> +		break;
> +	}
> +
> +	newp =3D kmalloc(sizeof(*newp), GFP_KERNEL);
> +	if (!newp)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ipv6_addr_prefix(&newp->prefix, prefix, prefixlen);
> +	newp->prefixlen =3D prefixlen;
> +	newp->ifindex =3D ifindex;
> +	newp->addrtype =3D addrtype;
> +	newp->label =3D label;
> +	INIT_HLIST_NODE(&newp->list);
> +	atomic_set(&newp->refcnt, 1);
> +	return newp;
> +}
> +
> +/* add a label */
> +int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
> +{
> +	int ret =3D 0;
> +
> +	ADDRLABEL(KERN_DEBUG "%s(newp=3D%p, replace=3D%d)\n",
> +			__FUNCTION__,
> +			newp, replace);
> +
> +	if (hlist_empty(&ip6addrlbl_table.head)) {
> +		hlist_add_head_rcu(&newp->list, &ip6addrlbl_table.head);
> +	} else {
> +		struct hlist_node *pos, *n;
> +		struct ip6addrlbl_entry *p =3D NULL;
> +		hlist_for_each_entry_safe(p, pos, n,

Why not list_for_each_entry(), given that you exit the look when you
do the replacement below?

> +					  &ip6addrlbl_table.head, list) {
> +			if (p->prefixlen =3D=3D newp->prefixlen &&
> +			    p->ifindex =3D=3D newp->ifindex &&
> +			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
> +				if (!replace) {
> +					ret =3D -EEXIST;
> +					goto out;
> +				}
> +				hlist_replace_rcu(&p->list, &newp->list);
> +				ip6addrlbl_put(p);
> +				call_rcu(&p->rcu, ip6addrlbl_free_rcu);

Side note:  if you didn't have a "goto out" here, then this would
be vulnerable to the following sequence of events in a CONFIG_PREEMPT_R=
T
kernel:

1.	Preemption occurs here (cannot happen in CONFIG_PREEMPT or
	vanilla kernel, but can happen in -rt).

2.	Grace period completes.

3.	ip6addrlbl_free_rcu() frees up the current element.

4.	This element is allocated and used for some entirely different
	structure.

5.	This task resumes execution, and the hlist_for_each_entry_safe()
	uses a pointer to the newly repurposed block of memory.  Oops!

> +				goto out;
> +			} else if ((p->prefixlen =3D=3D newp->prefixlen && !p->ifindex) |=
|
> +				   (p->prefixlen < newp->prefixlen)) {
> +				hlist_add_before_rcu(&newp->list, &p->list);
> +				goto out;
> +			}
> +		}
> +		hlist_add_after_rcu(&p->list, &newp->list);
> +	}
> +out:
> +	if (!ret)
> +		ip6addrlbl_table.seq++;
> +	return ret;
> +}
> +
> +/* add a label */
> +int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
> +		       int ifindex, u32 label, int replace)
> +{
> +	struct ip6addrlbl_entry *newp;
> +	int ret =3D 0;
> +
> +	ADDRLABEL(KERN_DEBUG "%s(prefix=3D" NIP6_FMT ", prefixlen=3D%d, ifi=
ndex=3D%d, label=3D%u, replace=3D%d)\n",
> +			__FUNCTION__,
> +			NIP6(*prefix), prefixlen,
> +			ifindex,
> +			(unsigned int)label,
> +			replace);
> +
> +	newp =3D ip6addrlbl_alloc(prefix, prefixlen, ifindex, label);
> +	if (IS_ERR(newp))
> +		return PTR_ERR(newp);
> +	spin_lock(&ip6addrlbl_table.lock);
> +	ret =3D __ip6addrlbl_add(newp, replace);
> +	spin_unlock(&ip6addrlbl_table.lock);
> +	if (ret)
> +		ip6addrlbl_free(newp);
> +	return ret;
> +}
> +
> +/* remove a label */
> +int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
> +			  int ifindex)
> +{
> +	struct ip6addrlbl_entry *p =3D NULL;
> +	struct hlist_node *pos, *n;
> +	int ret =3D -ESRCH;
> +
> +	ADDRLABEL(KERN_DEBUG "%s(prefix=3D" NIP6_FMT ", prefixlen=3D%d, ifi=
ndex=3D%d)\n",
> +			__FUNCTION__,
> +			NIP6(*prefix), prefixlen,
> +			ifindex);
> +
> +	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) =
{

Again, why not list_for_each_entry(), given that you exit the look when
you do the replacement below?

> +		if (p->prefixlen =3D=3D prefixlen &&
> +		    p->ifindex =3D=3D ifindex &&
> +		    ipv6_addr_equal(&p->prefix, prefix)) {
> +			hlist_del_rcu(&p->list);
> +			ip6addrlbl_put(p);
> +			call_rcu(&p->rcu, ip6addrlbl_free_rcu);
> +			ret =3D 0;
> +			break;
> +		}
> +	}
> +	return ret;
> +}
> +
> +int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
> +		       int ifindex)
> +{
> +	struct in6_addr prefix_buf;
> +	int ret;
> +
> +	ADDRLABEL(KERN_DEBUG "%s(prefix=3D" NIP6_FMT ", prefixlen=3D%d, ifi=
ndex=3D%d)\n",
> +			__FUNCTION__,
> +			NIP6(*prefix), prefixlen,
> +			ifindex);
> +
> +	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
> +	spin_lock(&ip6addrlbl_table.lock);
> +	ret =3D __ip6addrlbl_del(&prefix_buf, prefixlen, ifindex);
> +	spin_unlock(&ip6addrlbl_table.lock);
> +	return ret;
> +}
> +
> +/* add default label */
> +static __init int ip6addrlbl_init(void)
> +{
> +	int err =3D 0;
> +	int i;
> +
> +	ADDRLABEL(KERN_DEBUG "%s()\n", __FUNCTION__);
> +
> +	for (i =3D 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
> +		int ret =3D ip6addrlbl_add(ip6addrlbl_init_table[i].prefix,
> +					 ip6addrlbl_init_table[i].prefixlen,
> +					 0,
> +					 ip6addrlbl_init_table[i].label, 0);
> +		/* XXX: should we free all rules when we catch an error? */
> +		if (ret && (!err || err !=3D -ENOMEM))
> +			err =3D ret;
> +	}
> +	return err;
> +}
> +
> +int __init ipv6_addr_label_init(void)
> +{
> +	spin_lock_init(&ip6addrlbl_table.lock);
> +
> +	return ip6addrlbl_init();
> +}
> +
> +static const struct nla_policy ifal_policy[IFAL_MAX+1] =3D {
> +	[IFAL_ADDRESS]		=3D { .len =3D sizeof(struct in6_addr), },
> +	[IFAL_LABEL]		=3D { .len =3D sizeof(u32), },
> +};
> +
> +static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *n=
lh,
> +			     void *arg)
> +{
> +	struct ifaddrlblmsg *ifal;
> +	struct nlattr *tb[IFAL_MAX+1];
> +	struct in6_addr *pfx;
> +	u32 label;
> +	int err =3D 0;
> +
> +	err =3D nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
> +	if (err < 0)
> +		return err;
> +
> +	ifal =3D nlmsg_data(nlh);
> +
> +	if (ifal->ifal_family !=3D AF_INET6 ||
> +	    ifal->ifal_prefixlen > 128)
> +		return -EINVAL;
> +
> +	if (ifal->ifal_index &&
> +	    !__dev_get_by_index(&init_net, ifal->ifal_index))
> +		return -EINVAL;
> +
> +	if (!tb[IFAL_ADDRESS])
> +		return -EINVAL;
> +
> +	pfx =3D nla_data(tb[IFAL_ADDRESS]);
> +	if (!pfx)
> +		return -EINVAL;
> +
> +	if (!tb[IFAL_LABEL])
> +		return -EINVAL;
> +	label =3D nla_get_u32(tb[IFAL_LABEL]);
> +	if (label =3D=3D IPV6_ADDR_LABEL_DEFAULT)
> +		return -EINVAL;
> +
> +	switch(nlh->nlmsg_type) {
> +	case RTM_NEWADDRLABEL:
> +		err =3D ip6addrlbl_add(pfx, ifal->ifal_prefixlen,
> +				     ifal->ifal_index, label,
> +				     nlh->nlmsg_flags & NLM_F_REPLACE);
> +		break;
> +	case RTM_DELADDRLABEL:
> +		err =3D ip6addrlbl_del(pfx, ifal->ifal_prefixlen,
> +				     ifal->ifal_index);
> +		break;
> +	default:
> +		err =3D -EOPNOTSUPP;
> +	}
> +	return err;
> +}
> +
> +static inline void ip6addrlbl_putmsg(struct nlmsghdr *nlh,
> +				     int prefixlen, int ifindex, u32 lseq)
> +{
> +	struct ifaddrlblmsg *ifal =3D nlmsg_data(nlh);
> +	ifal->ifal_family =3D AF_INET6;
> +	ifal->ifal_prefixlen =3D prefixlen;
> +	ifal->ifal_flags =3D 0;
> +	ifal->ifal_index =3D ifindex;
> +	ifal->ifal_seq =3D lseq;
> +};
> +
> +static int ip6addrlbl_fill(struct sk_buff *skb,
> +			   struct ip6addrlbl_entry *p,
> +			   u32 lseq,
> +			   u32 pid, u32 seq, int event,
> +			   unsigned int flags)
> +{
> +	struct nlmsghdr *nlh =3D nlmsg_put(skb, pid, seq, event,
> +					 sizeof(struct ifaddrlblmsg), flags);
> +	if (!nlh)
> +		return -EMSGSIZE;
> +
> +	ip6addrlbl_putmsg(nlh, p->prefixlen, p->ifindex, lseq);
> +
> +	if (nla_put(skb, IFAL_ADDRESS, 16, &p->prefix) < 0 ||
> +	    nla_put_u32(skb, IFAL_LABEL, p->label) < 0) {
> +		nlmsg_cancel(skb, nlh);
> +		return -EMSGSIZE;
> +	}
> +
> +	return nlmsg_end(skb, nlh);
> +}
> +
> +static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callb=
ack *cb)
> +{
> +	struct ip6addrlbl_entry *p;
> +	struct hlist_node *pos;
> +	int idx =3D 0, s_idx =3D cb->args[0];
> +	int err;
> +
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
> +		if (idx >=3D s_idx) {
> +			if ((err =3D ip6addrlbl_fill(skb, p,
> +						   ip6addrlbl_table.seq,
> +						   NETLINK_CB(cb->skb).pid,
> +						   cb->nlh->nlmsg_seq,
> +						   RTM_NEWADDRLABEL,
> +						   NLM_F_MULTI)) <=3D 0)
> +				break;
> +		}
> +		idx++;
> +	}
> +	rcu_read_unlock();
> +	cb->args[0] =3D idx;
> +	return skb->len;
> +}
> +
> +static inline int ip6addrlbl_msgsize(void)
> +{
> +	return (NLMSG_ALIGN(sizeof(struct ifaddrlblmsg))
> +		+ nla_total_size(16)	/* IFAL_ADDRESS */
> +		+ nla_total_size(4)	/* IFAL_LABEL */
> +	);
> +}
> +
> +static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* n=
lh,
> +			  void *arg)
> +{
> +	struct ifaddrlblmsg *ifal;
> +	struct nlattr *tb[IFAL_MAX+1];
> +	struct in6_addr *addr;
> +	u32 lseq;
> +	int err =3D 0;
> +	struct ip6addrlbl_entry *p;
> +	struct sk_buff *skb;
> +
> +	err =3D nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
> +	if (err < 0)
> +		return err;
> +
> +	ifal =3D nlmsg_data(nlh);
> +
> +	if (ifal->ifal_family !=3D AF_INET6 ||
> +	    ifal->ifal_prefixlen !=3D 128)
> +		return -EINVAL;
> +
> +	if (ifal->ifal_index &&
> +	    !__dev_get_by_index(&init_net, ifal->ifal_index))
> +		return -EINVAL;
> +
> +	if (!tb[IFAL_ADDRESS])
> +		return -EINVAL;
> +
> +	addr =3D nla_data(tb[IFAL_ADDRESS]);
> +	if (!addr)
> +		return -EINVAL;
> +
> +	rcu_read_lock();
> +	p =3D __ipv6_addr_label(addr, ipv6_addr_type(addr), ifal->ifal_inde=
x);
> +	if (p && ip6addrlbl_hold(p))
> +		p =3D NULL;
> +	lseq =3D ip6addrlbl_table.seq;
> +	rcu_read_unlock();
> +
> +	if (!p) {
> +		err =3D -ESRCH;
> +		goto out;
> +	}
> +
> +	if (!(skb =3D nlmsg_new(ip6addrlbl_msgsize(), GFP_KERNEL))) {
> +		ip6addrlbl_put(p);
> +		return -ENOBUFS;
> +	}
> +
> +	err =3D ip6addrlbl_fill(skb, p, lseq,
> +			      NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
> +			      RTM_NEWADDRLABEL, 0);
> +
> +	ip6addrlbl_put(p);
> +
> +	if (err < 0) {
> +		WARN_ON(err =3D=3D -EMSGSIZE);
> +		kfree_skb(skb);
> +		goto out;
> +	}
> +
> +	err =3D rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
> +out:
> +	return err;
> +}
> +
> +void __init addrlabel_rtnl_register(void)
> +{
> +	__rtnl_register(PF_INET6, RTM_NEWADDRLABEL, ip6addrlbl_newdel, NULL=
);
> +	__rtnl_register(PF_INET6, RTM_DELADDRLABEL, ip6addrlbl_newdel, NULL=
);
> +	__rtnl_register(PF_INET6, RTM_GETADDRLABEL, ip6addrlbl_get, ip6addr=
lbl_dump);
> +}
> +
> --=20
> 1.4.4.4
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
