From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Thu, 5 Mar 2015 09:19:01 -0800
Message-ID: <CA+mtBx-2pjHmi4B0bo+oCQfMGWn7k26qvYUvNNwSLTZaK8YTwg@mail.gmail.com>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAF571E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"fw@strlen.de" <fw@strlen.de>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:43123 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbCERTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 12:19:03 -0500
Received: by igbhn18 with SMTP id hn18so47735053igb.2
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 09:19:02 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAF571E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 3:13 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Tom Herbert
> ...
>> - The probability that two different flows randomly match to the same
>>   hash from skb_get_hash is 1/2^32. If such a collision were to happen,
>>   then the flows potentially also map to the same qdisc queue in
>>   perpetuity despite perturbation being performed. Given the very low
>>   probability of this occurring, this may in practice only be an
>>   academic issue. If it is a real concern, rekeying of the underlying
>>   mechanisms of skb->hash could be done.
> ...
>
> The probability of a collision is much higher than that.
> With 10000 flows it is (if my 'ballpark maths' is right) nearer 1/100.
>

Probably a little closer to 1/50. But this is the best case scenario
that assumes a completely random input. In reality the input could be
heavily biased substantially increasing collisions. Consider if
we're in the forwarding path for two NVEs tunneling using VXLAN.
Encapsulated flows will differ in flow_keys only in source port with
14 bits of entropy. Now with 100 flows collision probability is 1/25,
at at 1000 flows you're pretty much guaranteed collisions. In such a
scenario, any amount of perturbation, re-keying of hashes, even
switching to more fancy hash algorithms doesn't help-- the root
problem is that the input domain does not contain sufficient entropy.

This is not just a performance issue, this is an obvious security
issue. It's fairly easy to DOS 5-tuples at will by spoofing packets
with different 5-tuples. This is absolutely trivial with IPv6. Given
we want to DOS a TCP connection with four tuple <S,D,s,d> and source
address is of form w::x:y, we can just change to the source address to
be w::x^J:y:^J and copy rest of the four-tuple. For any J this creates
same src value in flow_keys as w::x:y, hence always the same hash.
There are similar ways to spoof 4-tuple with IPv4 tunnels like the
VXLAN case above.

So if we want to fix this, we need to address the limited information
used in flow_keys. 1) flow_keys needs more information such as full
IPv6 address, VLAN, GRE keyid, and flow label. 2) We need a hash
function that can take more bits of flow_kesy as input to avoid the
aliasing problems like we see with the IPv6 case. This is where I am
going with these patches.

Tom
>         David
>
