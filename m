From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Thu, 07 Feb 2013 01:49:09 +0900
Message-ID: <51128985.2010701@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se> <20130206134950.GD10290@order.stressinduktion.org> <51127781.2000504@linux-ipv6.org> <20130206160409.GB18040@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40297 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756532Ab3BFQtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:49:10 -0500
In-Reply-To: <20130206160409.GB18040@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013=E5=B9=B402=E6=9C=8807=E6=97=A5 01:04), Hannes Frederic Sowa wrote=
:
> On Thu, Feb 07, 2013 at 12:32:17AM +0900, YOSHIFUJI Hideaki wrote:
>> Hannes Frederic Sowa wrote:
>>> On Wed, Feb 06, 2013 at 02:07:39PM +0100, Erik Hugne wrote:
>>>> On Wed, Feb 06, 2013 at 01:12:48PM +0100, Hannes Frederic Sowa wro=
te:
>>>>> Fixing the output path should be relatively straightforward, plea=
se test
>>>>> the following patch.
>>>>
>>>> Tested OK.
>>>>
>>>>> Looking at the input path, I think there is also no input protect=
ion
>>>>> for ff01::/16 addresses from the wire if you bind such an address=
=2E
>>>>
>>>> Yes, this needs to be filtered on the input side aswell.
>>>
>>> This patch should do the trick. Perhaps you could also take it for =
a test
>>> drive? Thanks!
>>>
>>> [PATCH net-next] ipv6: don't accept node local multicast traffic fr=
om the wire
>>>
>>> Cc: Erik Hugne <erik.hugne@ericsson.com>
>>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> ---
>>>  net/ipv6/ip6_input.c | 10 ++++++++++
>>>  1 file changed, 10 insertions(+)
>>>
>>> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
>>> index 4ac5bf3..a2f71d2 100644
>>> --- a/net/ipv6/ip6_input.c
>>> +++ b/net/ipv6/ip6_input.c
>>> @@ -126,6 +126,16 @@ int ipv6_rcv(struct sk_buff *skb, struct net_d=
evice *dev, struct packet_type *pt
>>>  	if (ipv6_addr_is_multicast(&hdr->saddr))
>>>  		goto err;
>>> =20
>>> +	/*
>>> +	 * RFC4291 2.7
>>> +	 * Interface-Local scope spans only a single interface on a node
>>> +         * and is useful only for loopback transmission of multica=
st.
>>> +	 */
>>> +	if (ipv6_addr_is_multicast(&hdr->daddr) &&
>>> +	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) <=3D IPV6_ADDR_SCOPE_NODELOCA=
L &&
>>> +	    skb->pkt_type !=3D PACKET_LOOPBACK)
>>> +		goto err;
>>> +
>>>  	skb->transport_header =3D skb->network_header + sizeof(*hdr);
>>>  	IP6CB(skb)->nhoff =3D offsetof(struct ipv6hdr, nexthdr);
>>
>> NAK.
>>
>> Well, do you have relevant RFC?
>> RFC4291 says that we should drop ff00::/16, but not ff01::/16.
>=20
> I know what you mean, the RFC does not state it directly. Hm, the BSD=
s seem to
> drop such destination addresses, too, if they don't originate from a =
loopback
> interface. Or did you mean that there is a flaw in the skb->pkt_type =
!=3D
> PACKET_LOOPBACK condition?

We do not drop ff01::/16, because RFC is silent about it.

--yoshfuji
