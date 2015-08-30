From: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] ipv4: Hash-based multipath routing
Date: Sun, 30 Aug 2015 15:29:06 -0700
Message-ID: <CALx6S36wZ36jS9fmrFJZ3BddnpGpBJXph5HtOBYQ=ekatSKDNw@mail.gmail.com>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
	<20150829.131429.360433621593751136.davem@davemloft.net>
	<20150829223115.523553db@tyr>
	<20150829.134628.1013990034021542524.davem@davemloft.net>
	<CALx6S35AUXFKfazU4bbpNL90r7P8i3wSFTB_0YDDRUgKg-3vqw@mail.gmail.com>
	<20150830232829.7e598151@tyr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
	sfeldma <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: =?UTF-8?Q?Peter_N=C3=B8rlund?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150830232829.7e598151@tyr>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 30, 2015 at 2:28 PM, Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org> =
wrote:
> On Sat, 29 Aug 2015 13:59:08 -0700
> Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
>
>> On Sat, Aug 29, 2015 at 1:46 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> wrote:
>> > From: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
>> > Date: Sat, 29 Aug 2015 22:31:15 +0200
>> >
>> >> On Sat, 29 Aug 2015 13:14:29 -0700 (PDT)
>> >> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> >>
>> >>> From: pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org
>> >>> Date: Fri, 28 Aug 2015 22:00:47 +0200
>> >>>
>> >>> > When the routing cache was removed in 3.6, the IPv4 multipath
>> >>> > algorithm changed from more or less being destination-based in=
to
>> >>> > being quasi-random per-packet scheduling. This increases the
>> >>> > risk of out-of-order packets and makes it impossible to use
>> >>> > multipath together with anycast services.
>> >>>
>> >>> Don't even try to be fancy.
>> >>>
>> >>> Simply kill the round-robin stuff off completely, and make hash
>> >>> based routing the one and only mode, no special configuration
>> >>> stuff necessary.
>> >>
>> >> I like the sound of that! Just to be clear - are you telling me t=
o
>> >> stick with L3 and skip the L4 part?
>> >
>> > For now it seems best to just do L3 and make ipv4 and ipv6 behave
>> > the same.
>>
>> This might be simpler if we just go directly to L4 which should be
>> better load balancing and what most switches are doing anyway. The
>> hash comes from:
>>
>> 1) If a lookup includes an skb, we just need to call skb_get_hash.
>> 2) If we have a socket and sk->sk_txhash is nonzero then use that.
>> 3) Else compute a hash frome flowi. We don't have the exact function=
s
>> for this, but they can be easily derived from __skb_get_hash_flowi4
>> and __skb_get_hash_flowi6 (i.e. create general get_hash_flowi4 and
>> get_hash_flowi6 and then call these from skb functions and multipath
>> lookup).
>
> It would definitely be simpler, and it would be nice to just fetch th=
e
> hash directly from the NIC - and for link aggregation it would probab=
ly
> be fine. But with L4, we always need to consider fragmented packets,
> which might cause some packets of a flow to be routed differently - a=
nd
> with ECMP, the ramifications of suddenly choosing another path for a
> flow are worse than for link aggregation. The latency through the
> different paths may differ enough to cause out-or-order packets and b=
ad
> TCP performance as a consequence. Both Cisco and Juniper routers
> defaults to L3 for ECMP - exactly for that reason, I believe. RFC 299=
1
> also points out that ports probably shouldn't be used as part of the
> flow key with ECMP.
>
That's more reason why we need vendors to use IPv6 flow label instead
of ports to do ECMP :-). In any case, if we're fragmenting TCP packets
then we're already in a bad place performance-wise-- we really don't
need to optimize for that case. Albeit, it would be nice if fragments
of packet  followed same path, but the would require devices to not do
L4 hash over ports when MF is set-- I don't know if anyone does that
(I have been meaning to add that to stack).

> With anycast it is even worse. Depending on how anycast is used,
> changing path may destroy a TCP connection. And without special
> treatment of ICMP, ICMP packets may hit another anycast node, causing
> PMTU to fail. Cloudflare recognized this and solved it by letting a
> user space daemon (pmtud) route ICMP packets through all paths, ensur=
ing
> that the anycast node receives the ICMP. But a more efficient solutio=
n
> is to handle the issue within the kernel.
>
> It might be possible to do L4 on flows using PMTU, and while it
> is possible to extract addresses and ports from the ICMP payload, you
> can't rely the DF-bit in the ICMP payload, since it comes from the
> opposite flow (Flow A->B use PMTU while B->A doesn't). I guess you
> can technically reduce the number of possible paths to two, though.
>
> I obviously prefer the default to be L3 with ICMP handling, since I
> specifically plan to use ECMP together with anycast (albeit anycasted
> load balancers which synchronizes states, although delayed), but I al=
so
> recognizes that anycast is a special case. Question is, it is so much=
 a
> special case that it belongs outside the vanilla kernel?
>
OTOH, if the hash is always dependent on fixed fields of a connection
(L3 or L4) then the path can never change during the lifetime of a
connection, this is a bad thing if we want to try a different path
when a connection is failing (via ipv4_negative_advice). This is why
there is value is using sk->sk_txhash as a route selector.

It is stunning that anycast works at all given it's dependency on the
network path being stack, but I suppose it is functionality we'll need
to preserve.

Tom

> Regards,
>  Peter N=C3=B8rlund
>
>>
>> Tom
>>
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
