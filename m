From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Wed, 16 Mar 2011 08:01:29 +0200
Message-ID: <4D805239.6040905@iki.fi>
References: <553973.46912.qm@web39301.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Doug Kehn <rdkehn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37622 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab1CPGBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 02:01:32 -0400
Received: by wya21 with SMTP id 21so1298912wya.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 23:01:31 -0700 (PDT)
In-Reply-To: <553973.46912.qm@web39301.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/2011 11:35 PM, Doug Kehn wrote:
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
>> To: "Eric Dumazet" <eric.dumazet@gmail.com>
>> Cc: "Doug Kehn" <rdkehn@yahoo.com>, netdev@vger.kernel.org
>> Date: Tuesday, March 15, 2011, 12:36 PM
>> On 03/15/2011 05:34 PM, Eric Dumazet
>> wrote:
>>> Le lundi 14 mars 2011 =E0 16:34 -0700, Doug Kehn a
>> =E9crit :
>>>> I'm running kernel version 2.6.36 on ARM XSCALE
>> (big-endian) and multicast over a multipoint GRE tunnel
>> isn't working.  For my architecture, this worked on
>> 2.6.26.8.  For x86, multicast over a multipoint GRE
>> tunnel worked with kernel version 2.6.31 but failed with
>> version 2.6.35.  Multicast over a multipoint GRE tunnel
>> fails because ipgre_header() fails the 'if (iph->daddr)'
>> check and reutrns -t->hlen.  ipgre_header() is being
>> called, from neigh_connected_output(), with a non-null
>> daddr; the contents of daddr is zero.
>
> I wasn't sure if the above patch was in addition too or in lieu of th=
e partial revert of ipgre_header() suggested by Eric; both cases were a=
ttempted.

It was intended without the ipgre_header revert. The partial revert doe=
s
not differ from full revert related to my problem.

> The multicast scenario described does not work if only the arp_mc_map=
() patch is applied.

Uh. Right, the if test had wrong condition. The intention was to show
the idea that we create the multicast-to-multicast GRE NOARP mappings i=
n
arp code where it should've been done in the first place (IMHO).

Could you try the below patch? That should work better. And the
ipgre_header should not be touched.

- Timo

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7927589..8c24845 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -215,6 +215,13 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct
net_device *dev, int dir)
 	case ARPHRD_INFINIBAND:
 		ip_ib_mc_map(addr, dev->broadcast, haddr);
 		return 0;
+	case ARPHRD_IPGRE:
+		if (dev->addr_len =3D=3D 4 &&
+		    get_unaligned_be32(dev->broadcast) !=3D INADDR_ANY)
+			memcpy(haddr, dev->broadcast, dev->addr_len);
+		else
+			memcpy(haddr, &addr, sizeof(addr));
+		return 0;
 	default:
 		if (dir) {
 			memcpy(haddr, dev->broadcast, dev->addr_len);
