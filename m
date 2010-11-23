From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: use gre key as flow upper protocol info
Date: Tue, 23 Nov 2010 16:03:45 +0200
Message-ID: <4CEBC9C1.8080101@iki.fi>
References: <1288795298-323-1-git-send-email-timo.teras@iki.fi> <20101115.104322.212675424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33450 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab0KWODs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 09:03:48 -0500
Received: by ewy5 with SMTP id 5so2435191ewy.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 06:03:47 -0800 (PST)
In-Reply-To: <20101115.104322.212675424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 08:43 PM, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Wed,  3 Nov 2010 16:41:38 +0200
>=20
>> The GRE Key field is intended to be used for identifying an individu=
al
>> traffic flow within a tunnel. It is useful to be able to have XFRM
>> policy selector matches to have different policies for different
>> GRE tunnels.
>>
>> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> I'll apply this to net-next-2.6, thanks.

Hmm.. I tested this with using the "ip xfrm" sport and dport manually
(without doing the actual userland support for this), and checking it i=
n
kernel with printk's in various places that the stuff matches. In these
tests I checked the sport/dport by hand and apparently messed up the
byte order.

Now that I'm writing the GRE support for "ip xfrm" I think that missed
two htons() calls.

I was confused if xfrm_flowi_{s|d}port was supposed to return host or
net byte order for non-TCP/UDP packets.

I was under the assumption that host byte order since case IPPROTO_ICMP
swaps the byte order. But it would appear that the fl->fl_icmp_* is
actually host order and it's turned to network order; this is also
implied by using htons instead of ntohs. Since I decided to keep
fl_gre_key in network order, the return value would now be inconsistent=
,
and make userland abi endianess dependent.

I'll follow up with iproute2 patch soon.

So we probably would need to do:

xfrm: fix gre key endianess

fl->fl_gre_key is network byte order contrary to fl->fl_icmp_*.
Make xfrm_flowi_{s|d}port return network byte order values for gre
key too.

Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1a57ff9..916ac47 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -806,7 +806,7 @@ __be16 xfrm_flowi_sport(struct flowi *fl)
 		port =3D htons(fl->fl_mh_type);
 		break;
 	case IPPROTO_GRE:
-		port =3D htonl(fl->fl_gre_key) >> 16;
+		port =3D htons(ntohl(fl->fl_gre_key) >> 16);
 		break;
 	default:
 		port =3D 0;	/*XXX*/
@@ -830,7 +830,7 @@ __be16 xfrm_flowi_dport(struct flowi *fl)
 		port =3D htons(fl->fl_icmp_code);
 		break;
 	case IPPROTO_GRE:
-		port =3D htonl(fl->fl_gre_key) & 0xffff;
+		port =3D htons(ntohl(fl->fl_gre_key) & 0xffff);
 		break;
 	default:
 		port =3D 0;	/*XXX*/
