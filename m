From: Wolfgang Walter <linux@stwm.de>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Tue, 19 Nov 2013 12:11:24 +0100
Message-ID: <19807032.ebUJct12DE@h2o.as.studentenwerk.mhn.de>
References: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com> <20131101084529.GL31491@secunet.com> <20131101092536.GA17499@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Tomas Hlavacek <tmshlvck@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:40126 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752114Ab3KSLL1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 06:11:27 -0500
In-Reply-To: <20131101092536.GA17499@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 1. November 2013, 09:25:37 schrieb Patrick McHardy:
> On Fri, Nov 01, 2013 at 09:45:29AM +0100, Steffen Klassert wrote:
> > On Wed, Oct 30, 2013 at 12:07:11AM +0000, Patrick McHardy wrote:
> > > The problem is that the reassembled packet is referenced by the
> > > individual
> > > fragments, so we trigger the BUG_ON in pskb_expand_head(). In thi=
s
> > > particular case the case we BUG() on is actually OK, but I'm look=
ing at
> > > a way we can fix this without special casing. Hope to have a patc=
h for
> > > testing in the next hours.
> >=20
> > Just for the record. I'm observing similar, quite reproducable cras=
hes
> > when
> > receiving fragmented icmp echo request packets on an IPsec gateway =
with
> > nf_conntrack_ipv6.
> >=20
> > Since git commit 58a317f10 ("netfilter: ipv6: add IPv6 NAT support"=
)
> > netfilter might insert a reassembled ipv6 packet with a shared skb =
and
> > local_df =3D 1 to the ok function. In case of xfrm, __xfrm6_output(=
)
> > fragments the packet again and when adjusting the headroom later, w=
e
> > crash because of a shared skb.
> >=20
> > I can fix it by checking for a shared skb in ip6_fragment() and do
> > slow path fragmentation then. But we never needed such a check in
> > ip6_fragment(), so it's maybe better to fix it in netfilter.
>=20
> So what seems to be happening is that this case in __ipv6_conntrack_i=
n()
> triggers:
>=20
>         /* Conntrack helpers need the entire reassembled packet in th=
e
>          * POST_ROUTING hook. In case of unconfirmed connections NAT
>          * might reassign a helper, so the entire packet is also
>          * required.
>          */
>         ct =3D nf_ct_get(reasm, &ctinfo);
>         if (ct !=3D NULL && !nf_ct_is_untracked(ct)) {
>                 help =3D nfct_help(ct);
>                 if ((help && help->helper) || !nf_ct_is_confirmed(ct)=
) {
>                         nf_conntrack_get_reasm(reasm);
>                         NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
>                                        (struct net_device *)in,
>                                        (struct net_device *)out,
>                                        okfn, NF_IP6_PRI_CONNTRACK + 1=
);
>=20
> Since this code is called while walking through the fragment chain, w=
e have
> extra references to the reassembled skb. So I think what we need to d=
o is
> to release the fragment chain before calling NF_HOOK_THRESH() and ind=
icate
> this to nf_ct_frag6_output() so it will stop processing the chain
> immediately.
>=20
> I'll give it a try, will let you know when I have a patch for testing=
=2E
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Are there patches available? I can crash my 3.12 kernel easily doing

	fping -p 20 -l -b 4000 bla

3.11.x does not expose this problem.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
