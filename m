From: Arvid Brodin <arvid.brodin@alten.se>
Subject: TCP checksum problem
Date: Sat, 12 Apr 2014 02:25:53 +0200
Message-ID: <53488811.2080602@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:51940 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755521AbaDLAfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 20:35:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to insert a 6-byte HSR header into a newly copied skb, betwe=
en the ethernet header and the IP header. The skb comes from my virtual=
 device's ndo_start_xmit() function and is to be sent on to a physical =
interface after modification. Essentially, this is what I'm doing:

	skb =3D skb_copy_expand(skb, skb_headroom(skb) + HSR_HLEN, 0, GFP_ATOM=
IC);

	/* Move ethernet header to make room for the HSR header */
	src =3D skb_mac_header(skb);
	WARN_ON_ONCE(src !=3D skb->data);
	dst =3D skb_push(skb, HSR_HLEN);
	memmove(dst, src, ETH_HLEN);
	skb_reset_mac_header(skb);

	/* Fill in the 6-byte header */
	hsr_fill_tag(skb, frame, port);

	/* Point the skb to the physical interface */
	skb->dev =3D port->dev;=20

	dev_queue_xmit(skb);

But something goes wrong with the TCP checksum on the way out. Arp, pin=
g etc works fine, but anything using TCP is discarded by the receiver d=
ue to incorrect TCP checksums.

Using wireshark and some printks, I've managed to decide that the updat=
ed TCP checksum is written offset by -6 bytes from where it should be (=
into what wireshark calls the TCP header "acknowledgement number" field=
).

Any idea why this happens? I've spent a few days on this now and I'm ru=
nning out of ideas...

This is run on the cadence/macb ethernet device. Before the call to skb=
_copy_expand(), skb->ip_summed is CHECKSUM_PARTIAL, skb->csum_start is =
120, and skb->csum_offset is 16. The total frame length is 80 bytes (on=
 the wire as reported by wireshark - I think this is excluding the FCS)=
=2E


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
