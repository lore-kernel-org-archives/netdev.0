From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Sat, 19 Nov 2011 09:36:57 +0200
Message-ID: <4EC75C99.4000304@iki.fi>
References: <20111117190925.GA23214@elliptictech.com> <20111118162709.GA8342@elliptictech.com> <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4EC6A38E.6060404@iki.fi> <20111118192639.GA10531@elliptictech.com> <4EC6BAD7.3010200@iki.fi> <20111118212129.GA22495@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50623 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab1KSHhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2011 02:37:05 -0500
Received: by bke11 with SMTP id 11so4315324bke.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 23:37:04 -0800 (PST)
In-Reply-To: <20111118212129.GA22495@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 11:21 PM, Nick Bowler wrote:
> On 2011-11-18 22:06 +0200, Timo Ter=E4s wrote:
>> It's still headroom underrun.
>>
>> I'm not too familiar with the relevant IPv6 code, but it seems to be
>> mostly modelled after the IPv4 side. Looking at the back trace offse=
t
>> inside ipv6_fragment, I'd say it was taking the "fast path" for
>> constructing the fragments. So first guess is that the headroom chec=
k
>> for allowing fast path to happen is not right.
>>
>> Since the code seems to be treating separately hlen and struct frag_=
hdr,
>> I'm wondering if the following patch would be in place?
>>
>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>> index 1c9bf8b..c35d9fc 100644
>> --- a/net/ipv6/ip6_output.c
>> +++ b/net/ipv6/ip6_output.c
>> @@ -675,7 +675,7 @@ int ip6_fragment(struct sk_buff *skb, int
>> (*output)(struct sk_buff *))
>>  			/* Correct geometry. */
>>  			if (frag->len > mtu ||
>>  			    ((frag->len & 7) && frag->next) ||
>> -			    skb_headroom(frag) < hlen)
>> +			    skb_headroom(frag) < hlen + sizeof(struct frag_hdr))
>>  				goto slow_path_clean;
>>
>>  			/* Partially cloned skb? */
>>
>>
>> Alternatively, we could just run the "slow path" unconditionally wit=
h
>> the test load to see if it fixes the issue. At least that'd be prett=
y
>> good test if it's a problem in the ipv6 fragmentation code or someth=
ing
>> else.
>=20
> Good call.  I replaced the "correct geometry" check with an
> unconditional "goto slow_path_clean;", and I can no longer reproduce =
the
> crash.  So at the very least, I have a workaround now.  (I still have
> Herbert Xu's six patches applied on top of Linus' master).

Ok, so it's most likely ipv6 code issue then. My change just happened t=
o
trigger it.

> I then tried the smaller change above, but this does not correct the
> issue.

That's not it then (likely).

I did notice that the headroom of the main skb is never checked. So my
other suggestion is to try something like:

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1c9bf8b..735c4dc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -668,7 +668,8 @@ int ip6_fragment(struct sk_buff *skb, int
(*output)(struct sk_buff *))

 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
-		    skb_cloned(skb))
+		    skb_cloned(skb) ||
+		    skb_headroom(skb) < sizeof(struct frag_hdr))
 			goto slow_path;

 		skb_walk_frags(skb, frag) {

Other than that, I hope some of the ipv6 people could take a look at it=
=2E
But the problem is that somewhere some headroom check isn't taking
place, or is checking for too little of headroom.

- Timo
