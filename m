From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Tue, 11 Oct 2011 20:30:02 -0700
Message-ID: <CAN17JHXrkSSYxwRkb_3c3W1yYNrNb3FWH+VR22YK_o4mmQMoGQ@mail.gmail.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
	<20111011143348.GA20605@gospo.rdu.redhat.com>
	<23119.1318348739@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59574 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab1JLDaD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 23:30:03 -0400
Received: by bkbzt4 with SMTP id zt4so355351bkb.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 20:30:02 -0700 (PDT)
In-Reply-To: <23119.1318348739@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2011 at 8:58 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
>
>>On Fri, Oct 07, 2011 at 10:36:45PM -0700, Yinglin Sun wrote:
>>> Add IPv6 support in L2L3 xmit policy.
>>> L3L4 doesn't support IPv6 either, and I'll try to fix that later.
>>>
>>> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
>>> ---
>>> =C2=A0drivers/net/bonding/bond_main.c | =C2=A0 =C2=A07 +++++++
>>> =C2=A01 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index 6d79b78..d6fd282 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -41,8 +41,10 @@
>>> =C2=A0#include <linux/ptrace.h>
>>> =C2=A0#include <linux/ioport.h>
>>> =C2=A0#include <linux/in.h>
>>> +#include <linux/in6.h>
>>> =C2=A0#include <net/ip.h>
>>> =C2=A0#include <linux/ip.h>
>>> +#include <linux/ipv6.h>
>>> =C2=A0#include <linux/tcp.h>
>>> =C2=A0#include <linux/udp.h>
>>> =C2=A0#include <linux/slab.h>
>>> @@ -3372,10 +3374,15 @@ static int bond_xmit_hash_policy_l23(struct=
 sk_buff *skb, int count)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0struct ethhdr *data =3D (struct ethhdr *)skb->d=
ata;
>>> =C2=A0 =C2=A0 =C2=A0struct iphdr *iph =3D ip_hdr(skb);
>>> + =C2=A0 =C2=A0struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
>>>
>>> =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_IP)) {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ((ntohl(iph-=
>saddr ^ iph->daddr) & 0xffff) ^
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0(data->h_dest[5] ^ data->h_source[5])) % count;
>>> + =C2=A0 =C2=A0} else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ((ntohl(ipv6h->sa=
ddr.s6_addr32[3] ^
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ipv6h->daddr.s6_addr32[3]) & 0xffff) ^
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(data->h_dest[5] ^ data->h_source[5])) % count;
>>> =C2=A0 =C2=A0 =C2=A0}
>>>
>>
>>There have been some attempts to add support for ipv6 hashing this in
>>the past, but none have been committed. =C2=A0The best one I had seen=
 was one
>>that did some extensive testing one a wide variety of ipv6 traffic an=
d
>>it showed nice traffic distribution. =C2=A0I'm not sure if it was eve=
r posted
>>upstream, so I will see if I can dig it up.
>>
>>Can you quantify how traffic was distributed with this algorithm?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0As I recall, the IPv6 issues had to do wit=
h the "layer3+4" hash,
> because the IPv6 TCP or UDP port numbers can be harder to get at than=
 in
> IPv4 (which typically has a fixed size header). =C2=A0The above is ju=
st for
> layer 2, so it only hits the IPv6 addresses, which don't move around.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0That said, I believe that many IPv6 addres=
ses are derived from
> the MAC address, the autoconf addresses in particular, so s6_addr32[3=
]
> may not show a lot more variation than just the MAC address. =C2=A0I =
don't
> know for sure though, since I haven't tested it.
>

This is a good point. The last 32bit portion is not enough for some cas=
es.

Yinglin
