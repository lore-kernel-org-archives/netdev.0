From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH V2] Add flow control to the portmapper
Date: Thu, 21 Jul 2016 12:42:42 -0500
Message-ID: <04ea01d1e377$4824a6f0$d86df4d0$@opengridcomputing.com>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com> <20160719054006.GF20674@leon.nu> <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com> <20160719173253.GL20674@leon.nu> <20160721024750.GA52712@ssaleem-MOBL4.amr.corp.intel.com> <20160721172942.GW20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"'Mustafa Ismail'" <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "'Leon Romanovsky'" <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"'Shiraz Saleem'" <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160721172942.GW20674-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>=20
> On Wed, Jul 20, 2016 at 09:47:50PM -0500, Shiraz Saleem wrote:
> > On Tue, Jul 19, 2016 at 08:32:53PM +0300, Leon Romanovsky wrote:
> > > On Tue, Jul 19, 2016 at 09:50:24AM -0500, Shiraz Saleem wrote:
> > > > On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote=
:
> > > > >
> > > > > You are the one user of this new inline function.
> > > > > Why don't you directly call to netlink_unicast() in your ibnl=
_unicast()
> > > > > without messing with widely visible header file?
> > > >
> > > > Since there is a non-blocking version of nlmsg_unicast(), the i=
dea is
> > > > to make a blocking version available to others as well as maint=
ain
> > > > consistency of existing code.
> > > >
> > >
> > > In such way, please provide patch series which will convert all o=
ther
> > > users to this new call.
> > >
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
> >
> > These usages of netlink_unicast() with blocking are not the same as=
 the new
> > nlmsg_unicast_block() function.
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
>

The key is to ensure that places calling a blocking service are never c=
alled in a non-blocking context.   Leon, do you know if the new sites a=
re always safe to block? =20

In general, I think blocking due to sockbuf flow control vs dropping or=
 retrying is a good thing for all the users in the rdam core, assuming =
they are safe to block.

=20
> +static inline int nlmsg_unicast_block(struct sock *sk, struct sk_buf=
f *skb, u32
> portid)
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
> > You can't drop in nlmsg_unicast_block() in
> > place of netlink_unicast() in these places. I'm not going to introd=
uce code
> > which modifies old behavior.
>=20
> Again, you aren't changing any behaviour.

Potential block/sleep is a change.  But if we can conclude that these a=
dditional sites are safe to block, then probably its ok to just go ahea=
d and use the blocking service everywhere.



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
