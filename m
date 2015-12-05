From: Konstantin Shemyak <konstantin@shemyak.com>
Subject: Re: IPv4 tunnels: why IP-IP and SIT enforce DF bit, but GRE does not?
Date: Sat, 5 Dec 2015 17:24:39 +0200
Message-ID: <566301B7.3050506@shemyak.com>
References: <1448964929.3305540.454487369.098BD535@webmail.messagingengine.com>
 <565D9EB6.1080102@shemyak.com>
 <1448976655.3349108.454655833.599EFE94@webmail.messagingengine.com>
 <20151201.120851.2159228528635979581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080205090603010708070202"
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: David Miller <davem@davemloft.net>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub3.mail.dreamhost.com ([69.163.253.7]:35688 "EHLO
	homiemail-a17.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752444AbbLEPYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 10:24:43 -0500
In-Reply-To: <20151201.120851.2159228528635979581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080205090603010708070202
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 01.12.2015 19:08, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 01 Dec 2015 14:30:55 +0100
>
>> On Tue, Dec 1, 2015, at 14:20, Konstantin Shemyak wrote:
>>> My point was not to question its feasibility, but to make it similar
>>> across GRE, IP-IP and SIT tunnels.
>>
>> I would send a patch to add it again if Parvin didn't have good reasons
>> to remove it.
>
> The tunnel code consolidation created a lot of regressions and subtle
> unintended changes in behavior between the different tunnel types.
>
> This DF bit issue is just yet another example of that.

The patch is rather trivial; attached.

Konstantin.

--------------080205090603010708070202
Content-Type: text/x-patch;
 name="0001-Set-DF-bit-to-GRE-tunnels-with-fixed-TTL-similarly-t.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Set-DF-bit-to-GRE-tunnels-with-fixed-TTL-similarly-t.pa";
 filename*1="tch"

>From b8a901a0d970907a2dc162744536b1ef07e5d45a Mon Sep 17 00:00:00 2001
From: Konstantin Shemyak <konstantin@shemyak.com>
Date: Sat, 5 Dec 2015 17:15:55 +0200
Subject: [PATCH] Set DF bit to GRE tunnels with fixed TTL, similarly to IP-IP
 and SIT

The DF bit on IPv4 tunnels with fixed TTL is enforced in order to
prevent networking loops. This was the original behavior of GRE
tunnels, lost in the refactoring.
---
 net/ipv4/ip_gre.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6145214..485bf27 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -679,6 +679,10 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
 		    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING)))
 			return -EINVAL;
 	}
+
+        if (p.iph.ttl)
+                p.iph.frag_off |= htons(IP_DF);
+
 	p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
 	p.o_flags = gre_flags_to_tnl_flags(p.o_flags);
 
-- 
1.9.1


--------------080205090603010708070202--
