From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Mon, 19 Oct 2015 20:51:18 -0700
Message-ID: <CALx6S34399AT+6SX2PJrB2R_tYKvZEycUwvLdFw3qNtZJyEYYg@mail.gmail.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	<1438621878-1113072-4-git-send-email-tom@herbertland.com>
	<CAEP_g=8tCkyRfPYARV4pqA7g0w6tQvioTnWLtFescv+3OS4JLw@mail.gmail.com>
	<1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<1445306641.30896.42.camel@edumazet-glaptop2.roam.corp.google.com>
	<1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Wolfgang Walter <linux@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33562 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbJTDvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 23:51:18 -0400
Received: by igbkq10 with SMTP id kq10so64024373igb.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 20:51:18 -0700 (PDT)
In-Reply-To: <1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 8:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Tom Herbert added SIT support to GRO with commit
> 19424e052fb4 ("sit: Add gro callbacks to sit_offload"),
> later reverted by Herbert Xu.
>
> The problem came because Tom patch was building GRO
> packets without proper meta data : If packets were locally
> delivered, we would not care.
>
> But if packets needed to be forwarded, GSO engine was not
> able to segment individual segments.
>
> With the following patch, we correctly set skb->encapsulation
> and inner network header. We also update gso_type.
>
> Tested:
>
> Server :
> netserver
> modprobe dummy
> ifconfig dummy0 8.0.0.1 netmask 255.255.255.0 up
> arp -s 8.0.0.100 4e:32:51:04:47:e5
> iptables -I INPUT -s 10.246.7.151 -j TEE --gateway 8.0.0.100
> ifconfig sixtofour0
> sixtofour0 Link encap:IPv6-in-IPv4
>           inet6 addr: 2002:af6:798::1/128 Scope:Global
>           inet6 addr: 2002:af6:798::/128 Scope:Global
>           UP RUNNING NOARP  MTU:1480  Metric:1
>           RX packets:411169 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:409414 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:20319631739 (20.3 GB)  TX bytes:29529556 (29.5 MB)
>
> Client :
> netperf -H 2002:af6:798::1 -l 1000 &
>
> Checked on server traffic copied on dummy0 and verify segments were
> properly rebuilt, with proper IP headers, TCP checksums...
>
> tcpdump on eth0 shows proper GRO aggregation takes place.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/ipv6/ip6_offload.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 08b62047c67f..eeca943f12dc 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -264,6 +264,9 @@ static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
>         struct ipv6hdr *iph = (struct ipv6hdr *)(skb->data + nhoff);
>         int err = -ENOSYS;
>
> +       if (skb->encapsulation)
> +               skb_set_inner_network_header(skb, nhoff);
> +
>         iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
>
>         rcu_read_lock();
> @@ -280,6 +283,13 @@ out_unlock:
>         return err;
>  }
>
> +static int sit_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +       skb->encapsulation = 1;
> +       skb_shinfo(skb)->gso_type |= SKB_GSO_SIT;
> +       return ipv6_gro_complete(skb, nhoff);
> +}
> +
>  static struct packet_offload ipv6_packet_offload __read_mostly = {
>         .type = cpu_to_be16(ETH_P_IPV6),
>         .callbacks = {
> @@ -292,6 +302,8 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
>  static const struct net_offload sit_offload = {
>         .callbacks = {
>                 .gso_segment    = ipv6_gso_segment,
> +               .gro_receive    = ipv6_gro_receive,
> +               .gro_complete   = sit_gro_complete,
>         },
>  };
>
>
>
