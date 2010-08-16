From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net/sched: add ACT_CSUM action to update packets
 checksums
Date: Mon, 16 Aug 2010 18:00:19 -0400
Message-ID: <1281996019.5765.6.camel@bigi>
References: <20100816211542.GA21083@n7mm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:35902 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab0HPWAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 18:00:23 -0400
Received: by qyk33 with SMTP id 33so50123qyk.19
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 15:00:23 -0700 (PDT)
In-Reply-To: <20100816211542.GA21083@n7mm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-16 at 23:15 +0200, Gr=C3=A9goire Baron wrote:
> net/sched: add ACT_CSUM action to update packets checksums
>=20
> ACT_CSUM can be called just after ACT_PEDIT in order to re-compute so=
me
> altered checksums in IPv4 and IPv6 packets. The following checksums a=
re
> supported by this patch:
>  - IPv4: IPv4 header, ICMP, IGMP, TCP, UDP & UDPLite
>  - IPv6: ICMPv6, TCP, UDP & UDPLite
> It's possible to request in the same action to update different kind =
of
> checksums, if the packets flow mix TCP, UDP and UDPLite, ...
>=20
> An example of usage is done in the associated iproute2 patch.
>=20
> Signed-off-by: Gregoire Baron <baronchon@n7mm.org>

Excellent work! Ive always wanted to do this albeit slightly
differently.

I think it would be nice to factor a lot of the code repeated
everywhere into some boilerplate function that gets invoked by all;
users. Example, code such as:

+       struct icmphdr *icmph;
+       int hl;
+       int ntkoff;
+
+       ntkoff =3D skb_network_offset(skb);
+
+       hl =3D ihl + sizeof(*icmph);
+
+       if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+           (skb_cloned(skb) &&
+            !skb_clone_writable(skb, hl + ntkoff) &&
+            pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+               goto fail;
+
+       icmph =3D (void *)(skb_network_header(skb) + ihl);
+
+       icmph->checksum =3D 0;


cheers,
jamal

