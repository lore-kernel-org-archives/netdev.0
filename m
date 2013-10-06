From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Sun, 6 Oct 2013 20:18:15 +0100
Message-ID: <CABfLueGW34XnTEJWsb5FA=pWfwwKqTTj31xCZyr78CNtTZWx6Q@mail.gmail.com>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
	<20131005140636.GA25076@order.stressinduktion.org>
	<CABfLueFYZkzpEpDJ7YcHJaXfm-=QcgnL3-Es8gybea2cAacQQw@mail.gmail.com>
	<20131006151351.GB9295@order.stressinduktion.org>
	<CABfLueGefWM6m6h44yAMBo7=BMUcA=OvcFVYka06QvsxXUAJtw@mail.gmail.com>
	<20131006161910.GC9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Oussama Ghorbel <ou.ghorbel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131006161910.GC9295@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, to summarize, the idea of this patch was to fix the incoherence
in the condition of ip6gre_tunnel_change_mtu function

  if (new_mtu < 68 ||
   new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)

>From the ip6gre_tnl_link_config function we can see that:
The variable addend is equal the ipv6 header + gre header (including
the gre options)
On the other hand hard_header_len equal to the header of the lower
layer + addend.
So the quantity - (dev->hard_header_len + tunnel->hlen) equals - (eth
header + ipv6 header + gre header + ipv6 header + gre header) which by
no means this would represent anything!  (I've just taken ipv6 over
ethernet as example)

As we have seen there is another approach to fix this issue is to
re-factor the hlen to hold only the length of gre as it's done for
ipv4 gre, however the solution provided in the patch seems to be
regression risk-less.
Although the value hold by hlen is not coherent with the variable name
nor with ipv4, I think there is an advantage of the current approach
of ipv6 hlen over ipv4 hlen, because we save the calculation of ipv6
header each time. Ex:
In ipv4 gre and in the function ipgre_header:
iph = (struct iphdr *)skb_push(skb, t->hlen + sizeof(*iph));
In ipv6 and in the function ip6gre_header
ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);

Thanks,
Oussama

On Sun, Oct 6, 2013 at 5:19 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Sun, Oct 06, 2013 at 04:36:56PM +0100, Oussama Ghorbel wrote:
>> On Sun, Oct 6, 2013 at 4:13 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > On Sun, Oct 06, 2013 at 03:42:15PM +0100, Oussama Ghorbel wrote:
>> >> The initialization  in ip6gre_tnl_link_config is done as the following:
>> >> static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
>> >> {
>> >> ...
>> >> int addend = sizeof(struct ipv6hdr) + 4;
>> >> ...
>> >> /* Precalculate GRE options length */
>> >> if (t->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
>> >> if (t->parms.o_flags&GRE_CSUM)
>> >> addend += 4;
>> >> if (t->parms.o_flags&GRE_KEY)
>> >> addend += 4;
>> >> if (t->parms.o_flags&GRE_SEQ)
>> >> addend += 4;
>> >> }
>> >> ...
>> >> dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
>> >> ...
>> >> t->hlen = addend;
>> >> ..
>> >> }
>> >>
>> >> Unless they are other reasons, the hard_header_len is taken into
>> >> account the GRE_KEY, GRE_SEQ ..
>> >
>> > But only if a new route is found. The hard_header_len reinitialization is
>> > guarded by a (rt == NULL). We may have not found one on boot up.
>> >
>> In that case the function will make a return and hlen will be zero.
>> Subtracting hlen in  ip6gre_tunnel_change_mtu has no effect ...
>
> Oh yes, somehow I missed that.
>
> We depend on t->hlen when pushing the gre header onto the skb. t->hlen == 0
> should never be the case because we assume t->hlen > sizeof(struct ipv6_hdr).
>
