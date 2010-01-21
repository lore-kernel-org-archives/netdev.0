From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Thu, 21 Jan 2010 15:04:13 +0800
Message-ID: <412e6f7f1001202304n5e34aaebu6c052687ce355582@mail.gmail.com>
References: <4B5011F4.8010204@gmail.com>
	 <20100115.004915.64525965.davem@davemloft.net>
	 <412e6f7f1001150120r622450eem2d9f54da27c42fba@mail.gmail.com>
	 <20100115.012613.223485835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100115.012613.223485835.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2010 at 5:26 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Fri, 15 Jan 2010 17:20:43 +0800
>
> Calling a function is expensive.
>
> What was now a leaf function deep in the call chain, will no longer
> be, so GCC will need to push all live registers onto the stack,
> then reload them back into registers when ipv6_skip_exthdr() returns.
>
> And that function is expensive, it's a lot of code that %99 of the
> time serves no purpose at all.
>
> This will be executed for every single packet we process, and Linux
> can process millions of packets per second, so every cycle and every
> memory reference matters.
>

We can write a new inline function like this:

static inline int ipv6_get_ports(const struct sk_buff *skb, u16 *port1,
                u16 *port2)
{
        u8 nexthdr;
        int hdrlen;

        nexthdr =3D ipv6_hdr(skb)->nexthdr;
        hdrlen =3D sizeof(struct ipv6hdr);
        while (1) {
                switch (nexthdr) {
                case IPPROTO_TCP:
                case IPPROTO_UDP:
                case IPPROTO_DCCP:
                case IPPROTO_ESP:
                case IPPROTO_AH:
                case IPPROTO_SCTP:
                case IPPROTO_UDPLITE:
                        skb_copy_bits(skb, hdrlen, port1, 2);
                        skb_copy_bits(skb, hdrlen + 2, port2, 2);
                        return 0;
                case NEXTHDR_HOP:
                case NEXTHDR_ROUTING:
                case NEXTHDR_FRAGMENT:
                case NEXTHDR_AUTH:
                case NEXTHDR_DEST:
                        // some code like ipv6_skip_exthdr()
                        ....
                        break;
                case NEXTHDR_NONE:
                        return -1;
                default:
                        return -1;
                }
        }
}

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
