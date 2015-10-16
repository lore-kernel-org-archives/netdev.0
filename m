From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] ipv6: Add gro functions to sit_offloads
Date: Fri, 16 Oct 2015 08:23:49 -0700
Message-ID: <1445009029.25595.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	 <1438621878-1113072-4-git-send-email-tom@herbertland.com>
	 <CAEP_g=8tCkyRfPYARV4pqA7g0w6tQvioTnWLtFescv+3OS4JLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Wolfgang Walter <linux@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jesse Gross <jesse@nicira.com>, Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35886 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932819AbbJPPXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 11:23:51 -0400
Received: by pacfv9 with SMTP id fv9so25646165pac.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 08:23:50 -0700 (PDT)
In-Reply-To: <CAEP_g=8tCkyRfPYARV4pqA7g0w6tQvioTnWLtFescv+3OS4JLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-06 at 17:15 -0700, Jesse Gross wrote:
> On Mon, Aug 3, 2015 at 10:11 AM, Tom Herbert <tom@herbertland.com> wrote:
> > For GRO to work with sit we need gro_receive and gro_complete populated
> > in the sit_offload structure.
> >
> > Signed-off-by: Tom Herbert <tom@herbertland.com>
> 
> You might want to checkout the recent history on this file unless
> there's something that's changed in the last couple of weeks:
> 
> commit fdbf5b097bbd9693a86c0b8bfdd071a9a2117cfc
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Mon Jul 20 17:55:38 2015 +0800
> 
>     Revert "sit: Add gro callbacks to sit_offload"
> 
>     This patch reverts 19424e052fb44da2f00d1a868cbb51f3e9f4bbb5 ("sit:
>     Add gro callbacks to sit_offload") because it generates packets
>     that cannot be handled even by our own GSO.
> 
>     Reported-by: Wolfgang Walter <linux@stwm.de>
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> --


What about the following more complete patch ?

We properly set skb->encapsulation and inner network header as some NIC
drivers depend on it. Our GSO should also work properly I think.

Wolfgang, could you please test it ? (this is a patch on top of David
Miller net-next tree)

Both Google and Facebook are eager to get proper GRO/SIT support ;)

Thanks !

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 08b62047c67f..eeca943f12dc 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -264,6 +264,9 @@ static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
 	struct ipv6hdr *iph = (struct ipv6hdr *)(skb->data + nhoff);
 	int err = -ENOSYS;
 
+	if (skb->encapsulation)
+		skb_set_inner_network_header(skb, nhoff);
+
 	iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
 
 	rcu_read_lock();
@@ -280,6 +283,13 @@ out_unlock:
 	return err;
 }
 
+static int sit_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_SIT;
+	return ipv6_gro_complete(skb, nhoff);
+}
+
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.callbacks = {
@@ -292,6 +302,8 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_segment	= ipv6_gso_segment,
+		.gro_receive    = ipv6_gro_receive,
+		.gro_complete   = sit_gro_complete,
 	},
 };
 
