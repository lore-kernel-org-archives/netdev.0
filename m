From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2 net-next 2/2] sit: add support of x-netns
Date: Wed, 26 Jun 2013 15:49:07 +0200
Message-ID: <51CAF153.4070809@6wind.com>
References: <51C9A4E3.2060906@6wind.com> <1372170295-4717-1-git-send-email-nicolas.dichtel@6wind.com> <1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com> <20130625.165612.1653110297729408070.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:32799 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab3FZNtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 09:49:10 -0400
Received: by mail-wg0-f45.google.com with SMTP id j13so10667121wgh.24
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 06:49:09 -0700 (PDT)
In-Reply-To: <20130625.165612.1653110297729408070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/06/2013 01:56, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 25 Jun 2013 16:24:55 +0200
>
>> @@ -453,6 +454,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, stru=
ct sk_buff *skb,
>>   	tstats->rx_bytes +=3D skb->len;
>>   	u64_stats_update_end(&tstats->syncp);
>>
>> +	skb_scrub_packet(skb);
>> +
>>   	if (tunnel->dev->type =3D=3D ARPHRD_ETHER) {
>>   		skb->protocol =3D eth_type_trans(skb, tunnel->dev);
>>   		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>
> I can't see how this can be ok.
>
> If something in netfilter depends upon the state you are clearing out
> here, someone's packet filtering setup is going to break.
Just for the record, note that nf_reset() is already called in=20
iptunnel_pull_header() and iptunnel_xmit().
Hence 4in4 (ipip and sit) and gre tunnels are already reseting netfilte=
r state.
6in4 (sit) do it only in xmit path and Xin6 (ip6_tunnel) never.

We can also notice that nf_reset() was added by the commit 3d7b46cd20e3=
=20
"ip_tunnel: push generic protocol handling to ip_tunnel module." (net-n=
ext only)=20
in rx path.

The nf_reset() of xmit path of 4in4 (ipip) is here for years (at least =
2.6.12).
=46or gre, it has been added by c54419321455 "GRE: Refactor GRE tunneli=
ng code."=20
(v3.10-rc1).

It seems that the code is different depending of the type of the tunnel=
=2E If we=20
omit skb_orphan() (and maybe another one?, to be done only when changin=
g=20
namespace), it can be good to have a common function to have the same b=
ehavior=20
for each tunnel.

Maybe something like:
void skb_scrub_packet(bool netnschange)
{
	if (netnschange)
	        skb_orphan(skb);
         skb->tstamp.tv64 =3D 0;
         skb->pkt_type =3D PACKET_HOST;
         skb->skb_iif =3D 0;
         skb_dst_drop(skb);
         skb->mark =3D 0;
         secpath_reset(skb);
         nf_reset(skb);
         nf_reset_trace(skb);
}

What's your opinion?
