From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Tue, 11 Oct 2011 20:27:51 -0700
Message-ID: <CAN17JHV72d-P5bN=fRyKdF7zEhDAJ_qb7KyPGdorwhbe87ZsAw@mail.gmail.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
	<20111011143348.GA20605@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36935 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab1JLD1x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 23:27:53 -0400
Received: by bkbzt4 with SMTP id zt4so353560bkb.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 20:27:51 -0700 (PDT)
In-Reply-To: <20111011143348.GA20605@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2011 at 7:33 AM, Andy Gospodarek <andy@greyhouse.net> w=
rote:
> On Fri, Oct 07, 2011 at 10:36:45PM -0700, Yinglin Sun wrote:
>> Add IPv6 support in L2L3 xmit policy.
>> L3L4 doesn't support IPv6 either, and I'll try to fix that later.
>>
>> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
>> ---
>> =C2=A0drivers/net/bonding/bond_main.c | =C2=A0 =C2=A07 +++++++
>> =C2=A01 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 6d79b78..d6fd282 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -41,8 +41,10 @@
>> =C2=A0#include <linux/ptrace.h>
>> =C2=A0#include <linux/ioport.h>
>> =C2=A0#include <linux/in.h>
>> +#include <linux/in6.h>
>> =C2=A0#include <net/ip.h>
>> =C2=A0#include <linux/ip.h>
>> +#include <linux/ipv6.h>
>> =C2=A0#include <linux/tcp.h>
>> =C2=A0#include <linux/udp.h>
>> =C2=A0#include <linux/slab.h>
>> @@ -3372,10 +3374,15 @@ static int bond_xmit_hash_policy_l23(struct =
sk_buff *skb, int count)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct ethhdr *data =3D (struct ethhdr *)skb->d=
ata;
>> =C2=A0 =C2=A0 =C2=A0 struct iphdr *iph =3D ip_hdr(skb);
>> + =C2=A0 =C2=A0 struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
>>
>> =C2=A0 =C2=A0 =C2=A0 if (skb->protocol =3D=3D htons(ETH_P_IP)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ((ntohl(iph-=
>saddr ^ iph->daddr) & 0xffff) ^
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (data->h_dest[5] ^ data->h_source[5])) % count;
>> + =C2=A0 =C2=A0 } else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ((ntohl(ipv6h->sa=
ddr.s6_addr32[3] ^
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ipv6h->daddr.s6_addr32[3]) & 0xffff) ^
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (data->h_dest[5] ^ data->h_source[5])) % count;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>
> There have been some attempts to add support for ipv6 hashing this in
> the past, but none have been committed. =C2=A0The best one I had seen=
 was one
> that did some extensive testing one a wide variety of ipv6 traffic an=
d
> it showed nice traffic distribution. =C2=A0I'm not sure if it was eve=
r posted
> upstream, so I will see if I can dig it up.
>
> Can you quantify how traffic was distributed with this algorithm?
>

My test was not extensive. I manually set some addresses which vary by
the last 32bit portion, and the traffic was distributed evenly across
slaves.

I agree that the real world IPv6 traffic should be used for more extens=
ive test.

Yinglin
