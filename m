From: Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Fri, 22 Jul 2016 10:26:01 -0500
Message-ID: <20160722152601.GA77728@ssaleem-MOBL4.amr.corp.intel.com>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
 <20160719054006.GF20674@leon.nu>
 <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com>
 <20160719173253.GL20674@leon.nu>
 <20160721024750.GA52712@ssaleem-MOBL4.amr.corp.intel.com>
 <20160721172942.GW20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160721172942.GW20674-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 21, 2016 at 08:29:42PM +0300, Leon Romanovsky wrote:
> On Wed, Jul 20, 2016 at 09:47:50PM -0500, Shiraz Saleem wrote:
> > On Tue, Jul 19, 2016 at 08:32:53PM +0300, Leon Romanovsky wrote:
> > > On Tue, Jul 19, 2016 at 09:50:24AM -0500, Shiraz Saleem wrote:
> > > > On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote=
:
> > > > >=20
> > > > > You are the one user of this new inline function.
> > > > > Why don't you directly call to netlink_unicast() in your ibnl=
_unicast()
> > > > > without messing with widely visible header file?
> > > >=20
> > > > Since there is a non-blocking version of nlmsg_unicast(), the i=
dea is=20
> > > > to make a blocking version available to others as well as maint=
ain=20
> > > > consistency of existing code.
> > > >=20
> > >=20
> > > In such way, please provide patch series which will convert all o=
ther
> > > users to this new call.
> > >=20
> > > =E2=9E=9C  linux-rdma git:(master) grep -rI netlink_unicast * | g=
rep -I 0
> > > kernel/audit.c: err =3D netlink_unicast(audit_sock, skb, audit_nl=
k_portid, 0);
> > > kernel/audit.c:         netlink_unicast(aunet->nlsk, skb, dest->p=
ortid, 0);
> > > kernel/audit.c: netlink_unicast(aunet->nlsk , reply->skb, reply->=
portid, 0);
> > > kernel/audit.c: return netlink_unicast(audit_sock, skb, audit_nlk=
_portid, 0);
> > > samples/connector/cn_test.c:    netlink_unicast(nls, skb, 0, 0);
> >=20
> > These usages of netlink_unicast() with blocking are not the same as=
 the new
> > nlmsg_unicast_block() function.=20
>=20
> Really?
> Did you look in the code?
> Let's take first function from that grep output
>=20
> 414         err =3D netlink_unicast(audit_sock, skb, audit_nlk_portid=
, 0);
> 415         if (err < 0) {
> 			... do something ...
> 437         } else
> 			... do something else ...
>=20
> which fits nicely with your proposal.
>=20
> +static inline int nlmsg_unicast_block(struct sock *sk, struct sk_buf=
f *skb, u32 portid)
> +{
> +       int err;
> +
> +       err =3D netlink_unicast(sk, skb, portid, 0);
> +       if (err > 0)
> +               err =3D 0;
> +
> +       return err;
> +}
>=20
>=20
> > You can't drop in nlmsg_unicast_block() in=20
> > place of netlink_unicast() in these places. I'm not going to introd=
uce code=20
> > which modifies old behavior.
>=20
> Again, you aren't changing any behaviour.
> Anyway we are not adding general function to common include file just
> because one caller wants it.
>=20

We assumed the nlmsg_ API in linux/include/net/netlink.h is there for a=
 purpose.=20
That purpose is to normalize the return code. That API is used in place=
s where=20
the return code needs to be normalized, and when normalization is not n=
eeded,=20
then the direct calls are used.=20

Now since the nlm_ API in netlink.h is missing a blocking version of th=
e=20
nlmsg_unicast function, it would seem reasonable to add it there.

Changing all the direct calls as you suggest would at the very least be=
=20
less efficient since it would normalize return codes when not needed.=20

However, if there is a strict rule against adding an API unless you imm=
ediately=20
have at least 2 callers, then I guess, we will make the direct call. Th=
e amount=20
of code added will be the same, except that the next person who wants a=
 normalized=20
return code will have to duplicate the same code.

Changing other code to be less efficient so that we can meet the 2 call=
er criteria=20
doesn't seem reasonable.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
