From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: TCP checksum problem
Date: Mon, 14 Apr 2014 18:34:32 +0200
Message-ID: <534C0E18.5050702@alten.se>
References: <53488811.2080602@alten.se> <1397263768.4222.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:54959 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753222AbaDNQkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 12:40:23 -0400
In-Reply-To: <1397263768.4222.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-04-12 02:49, Eric Dumazet wrote:
> On Sat, 2014-04-12 at 02:25 +0200, Arvid Brodin wrote:
>> Hi,
>>
>> I'm trying to insert a 6-byte HSR header into a newly copied skb,
>> between the ethernet header and the IP header. The skb comes from my
>> virtual device's ndo_start_xmit() function and is to be sent on to a
>> physical interface after modification. Essentially, this is what I'm
>> doing:
>>
>> 	skb =3D skb_copy_expand(skb, skb_headroom(skb) + HSR_HLEN, 0,
>> GFP_ATOMIC);
>>
>> 	/* Move ethernet header to make room for the HSR header */
>> 	src =3D skb_mac_header(skb);
>> 	WARN_ON_ONCE(src !=3D skb->data);
>> 	dst =3D skb_push(skb, HSR_HLEN);
>> 	memmove(dst, src, ETH_HLEN);
>> 	skb_reset_mac_header(skb);
>>
>> 	/* Fill in the 6-byte header */
>> 	hsr_fill_tag(skb, frame, port);
>>
>> 	/* Point the skb to the physical interface */
>> 	skb->dev =3D port->dev;=20
>>
>> 	dev_queue_xmit(skb);
>>
>> But something goes wrong with the TCP checksum on the way out. Arp,
>> ping etc works fine, but anything using TCP is discarded by the
>> receiver due to incorrect TCP checksums.
>>
>> Using wireshark and some printks, I've managed to decide that the
>> updated TCP checksum is written offset by -6 bytes from where it
>> should be (into what wireshark calls the TCP header "acknowledgement
>> number" field).
>>
>> Any idea why this happens? I've spent a few days on this now and I'm
>> running out of ideas...
>>
>> This is run on the cadence/macb ethernet device. Before the call to
>> skb_copy_expand(), skb->ip_summed is CHECKSUM_PARTIAL, skb->csum_sta=
rt
>> is 120, and skb->csum_offset is 16. The total frame length is 80 byt=
es
>> (on the wire as reported by wireshark - I think this is excluding th=
e
>> FCS).
>>
>>
>=20
> You need to set skb->csum_start to the new offset.
>=20
> ( skb_transport_header(skb) - skb->head )
>=20
> Check how __tcp_v4_send_check() sets csum_start & csum_offset
>=20
> (csum_offset you can leave it as is)
>=20

I recompiled my code today and ran it again, and it worked. I have no=20
idea what change I made, althought I know I first used=20

skb =3D __pskb_copy(skb, skb_headroom(skb) + HSR_HLEN, GFP_ATOMIC);

instead of=20

skb =3D skb_copy_expand(skb, skb_headroom(skb) + HSR_HLEN, 0, GFP_ATOMI=
C);

for the allocation of the new skb. The latter adjusts csum_start, the=20
former doesn't. I may have changed to the latter and simultaneously=20
added a manual adjustment to csum_start, because I know I was surprised=
=20
that the checksum moved 2*HSR_HLEN bytes when I did the adjustment. :)

Anyway, it seems to work now. Thanks for the help!


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
