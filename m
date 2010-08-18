From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 20:42:00 +0800
Message-ID: <AANLkTi=50qHT_-OoMbWcPT1Fi7JEa0e_kReZhnpVJJdR@mail.gmail.com>
References: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com> <1282129364.23601.17.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59934 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab0HRMmX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 08:42:23 -0400
Received: by wyb32 with SMTP id 32so739061wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 05:42:21 -0700 (PDT)
In-Reply-To: <1282129364.23601.17.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 7:02 PM, jamal <hadi@cyberus.ca> wrote:
> On Wed, 2010-08-18 at 13:05 +0800, Changli Gao wrote:
>
>> -static int has_ports(u8 protocol)
>> -{
>> - =A0 =A0 switch (protocol) {
>> - =A0 =A0 case IPPROTO_TCP:
>> - =A0 =A0 case IPPROTO_UDP:
>> - =A0 =A0 case IPPROTO_UDPLITE:
>> - =A0 =A0 case IPPROTO_SCTP:
>> - =A0 =A0 case IPPROTO_DCCP:
>> - =A0 =A0 case IPPROTO_ESP:
>> - =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> - =A0 =A0 default:
>> - =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> - =A0 =A0 }
>> -}
>> -
>> =A0static u32 flow_get_proto_src(struct sk_buff *skb)
>> =A0{
>> =A0 =A0 =A0 switch (skb->protocol) {
>> =A0 =A0 =A0 case htons(ETH_P_IP): {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct iphdr *iph;
>> + =A0 =A0 =A0 =A0 =A0 =A0 int poff;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_network_may_pull(skb, sizeof(*=
iph)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph =3D ip_hdr(skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)=
) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 has_ports(iph->protocol) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pskb_network_may_pull(skb, iph->ih=
l * 4 + 2))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ntohs(*(__be16 *)((=
void *)iph + iph->ihl * 4));
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (iph->frag_off & htons(IP_MF|IP_OFFSET)=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 poff =3D proto_ports_offset(iph->protocol)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (poff >=3D 0 &&
>
>
> I dont think this maintains the same semantic. Ex: In the original co=
de
> AH returns 0. In your case it returns 4 and passes the above test.
> Same with the other spot.
>

I suppose we want to spread the traffic as possible as we can. For
ESP, we use the SPI as a key. And I think we can also use SPI in the
AH header as a key. It does change the semantic slightly for AH, but I
should not hurt, as the only effect is that the AH traffic is
distributed into different flows according to their different SPI.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
