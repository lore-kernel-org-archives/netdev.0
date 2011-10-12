From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Tue, 11 Oct 2011 20:39:00 -0700
Message-ID: <CAN17JHVsgRqkOgeJ0+vvQe3kN1W0ue0vKHa3uebFHa9oH2ngXA@mail.gmail.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
	<20111011143348.GA20605@gospo.rdu.redhat.com>
	<23119.1318348739@death>
	<20111012025137.GB20605@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	John Eaglesham <johneagl@yahoo-inc.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35173 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab1JLDjB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 23:39:01 -0400
Received: by bkbzt4 with SMTP id zt4so361651bkb.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 20:39:00 -0700 (PDT)
In-Reply-To: <20111012025137.GB20605@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2011 at 7:51 PM, Andy Gospodarek <andy@greyhouse.net> w=
rote:
> On Tue, Oct 11, 2011 at 08:58:59AM -0700, Jay Vosburgh wrote:
>> Andy Gospodarek <andy@greyhouse.net> wrote:
> [...]
>> >
>> >There have been some attempts to add support for ipv6 hashing this =
in
>> >the past, but none have been committed. =C2=A0The best one I had se=
en was one
>> >that did some extensive testing one a wide variety of ipv6 traffic =
and
>> >it showed nice traffic distribution. =C2=A0I'm not sure if it was e=
ver posted
>> >upstream, so I will see if I can dig it up.
>> >
>> >Can you quantify how traffic was distributed with this algorithm?
>>
>> =C2=A0 =C2=A0 =C2=A0 As I recall, the IPv6 issues had to do with the=
 "layer3+4" hash,
>> because the IPv6 TCP or UDP port numbers can be harder to get at tha=
n in
>> IPv4 (which typically has a fixed size header). =C2=A0The above is j=
ust for
>> layer 2, so it only hits the IPv6 addresses, which don't move around=
=2E
>>
>> =C2=A0 =C2=A0 =C2=A0 That said, I believe that many IPv6 addresses a=
re derived from
>> the MAC address, the autoconf addresses in particular, so s6_addr32[=
3]
>> may not show a lot more variation than just the MAC address. =C2=A0I=
 don't
>> know for sure though, since I haven't tested it.
>>
>> =C2=A0 =C2=A0 =C2=A0 I don't recall seeing the patch you mention, An=
dy, that checks
>> ipv6 traffic; can you post it?
>>
>
> I found the patch, cleaned it up, and compile tested it against
> net-next. =C2=A0I traded some emails with John Eaglesham (cc'd) earli=
er this
> year and though he planned to post it, I never followed up.
>
> His comments about this patch were as follows:
>
> "I've attached my patch for IPv6 transmit hashing for the nic bonding
> driver.
>
> "The algorithm I chose is based on 273,913 IPv6 client addresses I
> gathered from webservers and ran through a test program that implemen=
ted
> several algorithms. This algorithm provided the most even distributio=
n
> while using the fewest instructions.
>
> "I've tested this on 2.6.39-rc4 and a similar patch to 2.6.18 (from
> RHEL5 5.4.3) and it has performed as expected in both cases.
>
> "Please let me know if you have any comments, otherwise I suppose the
> next step is to propose the patch to LKML."
>
> I would suggest we use this. =C2=A0John or I could write an official
> changelog and post this in it's own thread if it looks good to others=
=2E
>
> ---
> =C2=A0drivers/net/bonding/bond_main.c | =C2=A0 30 +++++++++++++++++++=
++++++-----
> =C2=A01 files changed, 25 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 6191e63..335cb67 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3368,11 +3368,20 @@ static struct notifier_block bond_inetaddr_no=
tifier =3D {
> =C2=A0static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int c=
ount)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ethhdr *data =3D (struct ethhdr *)s=
kb->data;
> - =C2=A0 =C2=A0 =C2=A0 struct iphdr *iph =3D ip_hdr(skb);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_IP)) =
{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct iphdr *iph =
=3D ip_hdr(skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ((ntohl=
(iph->saddr ^ iph->daddr) & 0xffff) ^
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0(data->h_dest[5] ^ data->h_source[5])) % count;
> + =C2=A0 =C2=A0 =C2=A0 } else if (skb->protocol =3D=3D htons(ETH_P_IP=
V6)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ipv6hdr *ip=
v6h =3D ipv6_hdr(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 v6hash =3D (
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 );
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 v6hash =3D (v6hash=
 >> 16) ^ (v6hash >> 8) ^ v6hash;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return (v6hash ^ d=
ata->h_dest[5] ^ data->h_source[5]) % count;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return (data->h_dest[5] ^ data->h_source[5=
]) % count;
> @@ -3386,11 +3395,11 @@ static int bond_xmit_hash_policy_l23(struct s=
k_buff *skb, int count)
> =C2=A0static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int c=
ount)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ethhdr *data =3D (struct ethhdr *)s=
kb->data;
> - =C2=A0 =C2=A0 =C2=A0 struct iphdr *iph =3D ip_hdr(skb);
> - =C2=A0 =C2=A0 =C2=A0 __be16 *layer4hdr =3D (__be16 *)((u32 *)iph + =
iph->ihl);
> - =C2=A0 =C2=A0 =C2=A0 int layer4_xor =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 u32 layer4_xor =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_IP)) =
{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct iphdr *iph =
=3D ip_hdr(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __be16 *layer4hdr =
=3D (__be16 *)((u32 *)iph + iph->ihl);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!ip_is_fra=
gment(iph) &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
(iph->protocol =3D=3D IPPROTO_TCP ||
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 iph->protocol =3D=3D IPPROTO_UDP)) {
> @@ -3398,7 +3407,18 @@ static int bond_xmit_hash_policy_l34(struct sk=
_buff *skb, int count)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return (layer4=
_xor ^
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
> -
> + =C2=A0 =C2=A0 =C2=A0 } else if (skb->protocol =3D=3D htons(ETH_P_IP=
V6)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ipv6hdr *ip=
v6h =3D ipv6_hdr(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __be16 *layer4hdrv=
6 =3D (__be16 *)((u8 *)ipv6h + sizeof(*ipv6h));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ipv6h->nexthdr=
 =3D=3D IPPROTO_TCP || ipv6h->nexthdr =3D=3D IPPROTO_UDP) {

Does this work if this is a fragmentation packet? and if
ipv6h->nexthdr is not IPPROTO_TCP/IPPROTO_UDP, it doesn't mean this is
not TCP/UDP packet. We need to go through the extension header chain
and look at the last one. It's likely there are some other extension
headers before L4 header.

Yinglin

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 layer4_xor =3D (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 layer4_xor ^=3D (
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 );
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ((layer4_xo=
r >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return (data->h_dest[5] ^ data->h_source[5=
]) % count;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
