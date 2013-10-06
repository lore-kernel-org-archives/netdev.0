From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Sun, 6 Oct 2013 18:19:10 +0200
Message-ID: <20131006161910.GC9295@order.stressinduktion.org>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com> <20131005140636.GA25076@order.stressinduktion.org> <CABfLueFYZkzpEpDJ7YcHJaXfm-=QcgnL3-Es8gybea2cAacQQw@mail.gmail.com> <20131006151351.GB9295@order.stressinduktion.org> <CABfLueGefWM6m6h44yAMBo7=BMUcA=OvcFVYka06QvsxXUAJtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oussama Ghorbel <ou.ghorbel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABfLueGefWM6m6h44yAMBo7=BMUcA=OvcFVYka06QvsxXUAJtw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 06, 2013 at 04:36:56PM +0100, Oussama Ghorbel wrote:
> On Sun, Oct 6, 2013 at 4:13 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Sun, Oct 06, 2013 at 03:42:15PM +0100, Oussama Ghorbel wrote:
> >> The initialization  in ip6gre_tnl_link_config is done as the following:
> >> static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
> >> {
> >> ...
> >> int addend = sizeof(struct ipv6hdr) + 4;
> >> ...
> >> /* Precalculate GRE options length */
> >> if (t->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
> >> if (t->parms.o_flags&GRE_CSUM)
> >> addend += 4;
> >> if (t->parms.o_flags&GRE_KEY)
> >> addend += 4;
> >> if (t->parms.o_flags&GRE_SEQ)
> >> addend += 4;
> >> }
> >> ...
> >> dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
> >> ...
> >> t->hlen = addend;
> >> ..
> >> }
> >>
> >> Unless they are other reasons, the hard_header_len is taken into
> >> account the GRE_KEY, GRE_SEQ ..
> >
> > But only if a new route is found. The hard_header_len reinitialization is
> > guarded by a (rt == NULL). We may have not found one on boot up.
> >
> In that case the function will make a return and hlen will be zero.
> Subtracting hlen in  ip6gre_tunnel_change_mtu has no effect ...

Oh yes, somehow I missed that.

We depend on t->hlen when pushing the gre header onto the skb. t->hlen == 0
should never be the case because we assume t->hlen > sizeof(struct ipv6_hdr).
