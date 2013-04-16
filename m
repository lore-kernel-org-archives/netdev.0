From: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Subject: Re: Bonding driver has bad load balancing for forwarded traffic,
 3.7+
Date: Tue, 16 Apr 2013 12:01:40 +0300
Message-ID: <516D1374.1070500@telenet.dn.ua>
References: <516C075E.30105@telenet.dn.ua>  <1366072679.4459.113.camel@edumazet-glaptop> <1366081404.4459.127.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	John Eaglesham <linux@8192.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366081404.4459.127.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

16.04.2013 06:03, Eric Dumazet =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Eric Dumazet <edumazet@google.com>
>
> On Mon, 2013-04-15 at 17:37 -0700, Eric Dumazet wrote:
>> On Mon, 2013-04-15 at 16:57 +0300, Vitaly V. Bursov wrote:
>>> Hello,
>>>
>>> I have a bonding device (mode=3D802.3ad xmit_hash_policy=3Dlayer2+3=
 miimon=3D300) and
>>> for kernels <3.7 forwarded IPv4 traffic distributed fine across mul=
tiple physical
>>> links. Ethernet cards are Intel 82576 with igb driver (various vers=
ions).
>>>
>>> 3.7 and 3.8 kernels tend to fully utilize only one link and leave t=
he others almost idling.
>>>
>>> Replacing bond_xmit_hash_policy_* functions with older ones (3.6 ke=
rnel) looks like
>>> resolves the issue (but I haven't tested it thoroughly).
>>>
>>> So, I added
>>>           printk(KERN_INFO "hash_policy: protocol =3D %d, skb_netwo=
rk_header_len =3D %d, %d %d\n",
>>>               skb->protocol, skb_network_header_len(skb),
>>>               skb_headlen(skb), skb_network_offset(skb));
>>> to bond_xmit_hash_policy_l23() of bond_main.c
>>>
>>> and got this:
>>> [   65.280831] hash_policy: protocol =3D 8, skb_network_header_len =
=3D 0, 74 14
>>> [   65.280835] hash_policy: protocol =3D 8, skb_network_header_len =
=3D 0, 74 14
>>> [   65.280839] hash_policy: protocol =3D 8, skb_network_header_len =
=3D 0, 74 14
>>> [   65.280843] hash_policy: protocol =3D 8, skb_network_header_len =
=3D 0, 74 14
>>> [   65.280847] hash_policy: protocol =3D 8, skb_network_header_len =
=3D 0, 74 14
>>> [   65.280851] hash_policy: protocol =3D 8, skb_network_header_len =
=3D 0, 74 14
>>>
>>> It's clear that the new check condition (skb_network_header_len(skb=
) >=3D sizeof(*iph))
>>> fails here and hash policy fallbacks to l2 balancing.
>>>
>>> I have no idea how to fix this besides removing this check complete=
ly, any
>>> help would be appreciated.
>>>
>>
>> Thanks for your report.
>>
>> CC netdev
>>
>> I guess that for forwarding setup, we don't set skb->transport_heade=
r
>>
>> Please try following fix :
>
> Here is a more complete patch, please test it.
>
> Thanks !

Testing under real load for almost 2 hours now, works as expected.
xmit_hash_policy=3Dlayer3+4

I made a few simple test with layer2+3 policy too, looks OK.

Thanks!

> [PATCH] bonding: fix l23 and l34 load balancing in forwarding path
>
> Since commit 6b923cb7188d46 (bonding: support for IPv6 transmit hashi=
ng)
> bonding doesn't properly hash traffic in forwarding setups.
>
> Vitaly V. Bursov diagnosed that skb_network_header_len() returned 0 i=
n
> this case.
>
> More generally, the transport header might not be in the skb head.
>
> Use pskb_may_pull() & skb_header_pointer() to get it right, and use
> proto_ports_offset() in bond_xmit_hash_policy_l34() to get support fo=
r
> more protocols than TCP and UDP.
>
> Reported-by: Vitaly V. Bursov <vitalyb@telenet.dn.ua>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Cc: John Eaglesham <linux@8192.net>
> ---
>   drivers/net/bonding/bond_main.c |   55 ++++++++++++++++------------=
--
>   1 file changed, 30 insertions(+), 25 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 07401a3..d9ff09a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3286,20 +3286,22 @@ static int bond_xmit_hash_policy_l2(struct sk=
_buff *skb, int count)
>    */
>   static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count=
)
>   {
> -	struct ethhdr *data =3D (struct ethhdr *)skb->data;
> -	struct iphdr *iph;
> -	struct ipv6hdr *ipv6h;
> +	const struct ethhdr *data;
> +	const struct iphdr *iph;
> +	const struct ipv6hdr *ipv6h;
>   	u32 v6hash;
> -	__be32 *s, *d;
> +	const __be32 *s, *d;
>
>   	if (skb->protocol =3D=3D htons(ETH_P_IP) &&
> -	    skb_network_header_len(skb) >=3D sizeof(*iph)) {
> +	    pskb_network_may_pull(skb, sizeof(*iph))) {
>   		iph =3D ip_hdr(skb);
> +		data =3D (struct ethhdr *)skb->data;
>   		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>   			(data->h_dest[5] ^ data->h_source[5])) % count;
>   	} else if (skb->protocol =3D=3D htons(ETH_P_IPV6) &&
> -		   skb_network_header_len(skb) >=3D sizeof(*ipv6h)) {
> +		   pskb_network_may_pull(skb, sizeof(*ipv6h))) {
>   		ipv6h =3D ipv6_hdr(skb);
> +		data =3D (struct ethhdr *)skb->data;
>   		s =3D &ipv6h->saddr.s6_addr32[0];
>   		d =3D &ipv6h->daddr.s6_addr32[0];
>   		v6hash =3D (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
> @@ -3318,33 +3320,36 @@ static int bond_xmit_hash_policy_l23(struct s=
k_buff *skb, int count)
>   static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count=
)
>   {
>   	u32 layer4_xor =3D 0;
> -	struct iphdr *iph;
> -	struct ipv6hdr *ipv6h;
> -	__be32 *s, *d;
> -	__be16 *layer4hdr;
> +	const struct iphdr *iph;
> +	const struct ipv6hdr *ipv6h;
> +	const __be32 *s, *d;
> +	const __be16 *l4 =3D NULL;
> +	__be16 _l4[2];
> +	int noff =3D skb_network_offset(skb);
> +	int poff;
>
>   	if (skb->protocol =3D=3D htons(ETH_P_IP) &&
> -	    skb_network_header_len(skb) >=3D sizeof(*iph)) {
> +	    pskb_may_pull(skb, noff + sizeof(*iph))) {
>   		iph =3D ip_hdr(skb);
> -		if (!ip_is_fragment(iph) &&
> -		    (iph->protocol =3D=3D IPPROTO_TCP ||
> -		     iph->protocol =3D=3D IPPROTO_UDP) &&
> -		    (skb_headlen(skb) - skb_network_offset(skb) >=3D
> -		     iph->ihl * sizeof(u32) + sizeof(*layer4hdr) * 2)) {
> -			layer4hdr =3D (__be16 *)((u32 *)iph + iph->ihl);
> -			layer4_xor =3D ntohs(*layer4hdr ^ *(layer4hdr + 1));
> +		poff =3D proto_ports_offset(iph->protocol);
> +
> +		if (!ip_is_fragment(iph) && poff >=3D 0) {
> +			l4 =3D skb_header_pointer(skb, noff + (iph->ihl << 2) + poff,
> +						sizeof(_l4), &_l4);					=09
> +			if (l4)
> +				layer4_xor =3D ntohs(l4[0] ^ l4[1]);
>   		}
>   		return (layer4_xor ^
>   			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>   	} else if (skb->protocol =3D=3D htons(ETH_P_IPV6) &&
> -		   skb_network_header_len(skb) >=3D sizeof(*ipv6h)) {
> +		   pskb_may_pull(skb, noff + sizeof(*ipv6h))) {
>   		ipv6h =3D ipv6_hdr(skb);
> -		if ((ipv6h->nexthdr =3D=3D IPPROTO_TCP ||
> -		     ipv6h->nexthdr =3D=3D IPPROTO_UDP) &&
> -		    (skb_headlen(skb) - skb_network_offset(skb) >=3D
> -		     sizeof(*ipv6h) + sizeof(*layer4hdr) * 2)) {
> -			layer4hdr =3D (__be16 *)(ipv6h + 1);
> -			layer4_xor =3D ntohs(*layer4hdr ^ *(layer4hdr + 1));
> +		poff =3D proto_ports_offset(ipv6h->nexthdr);
> +		if (poff >=3D 0) {
> +			l4 =3D skb_header_pointer(skb, noff + sizeof(*ipv6h) + poff,
> +						sizeof(_l4), &_l4);
> +			if (l4)
> +				layer4_xor =3D ntohs(l4[0] ^ l4[1]);
>   		}
>   		s =3D &ipv6h->saddr.s6_addr32[0];
>   		d =3D &ipv6h->daddr.s6_addr32[0];
>
>
