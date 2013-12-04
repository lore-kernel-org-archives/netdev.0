From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Change in IPv4 TCP reset behavior after kernel upgrade
Date: Wed, 04 Dec 2013 15:37:01 -0800
Message-ID: <1386200221.30495.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2ECE9D9EEF1F524185270138AE2326593BF9B5EE@S0MSMAIL112.arc.local>
	 <CADVnQynL6=91zAZXMAoKEeCY7=Eajfq1DyP+Dzd8xhzBhujtyQ@mail.gmail.com>
	 <2ECE9D9EEF1F524185270138AE2326593BF9B935@S0MSMAIL112.arc.local>
	 <20131204175610.GB27943@order.stressinduktion.org>
	 <1386181774.30495.113.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131204220238.GA9110@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fiedler Roman <Roman.Fiedler@ait.ac.at>,
	Neal Cardwell <ncardwell@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:50749 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3LDXhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 18:37:05 -0500
Received: by mail-yh0-f54.google.com with SMTP id z12so12009220yhz.13
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 15:37:04 -0800 (PST)
In-Reply-To: <20131204220238.GA9110@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 23:02 +0100, Hannes Frederic Sowa wrote:

> Oh yes, actually looking at the code we definitely run into __ip_select_ident
> and generate an inetpeer and use the derived ipid from that.
> 
> Roman, I would be very interested why you only experienced that with
> 3.10.21, could you share the specific vserver patch?

BTW I think we might have an opportunity to respect no_pmtu_disc sysctl
as in :

(ie have DF bit set or unset for RST packets, and ACK packets sent on behalf
of TIMEWAIT sockets)

Still we use a non 0 id for these packets.

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9124027..a1e05a9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1473,7 +1473,6 @@ static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
                .sk_allocation  = GFP_ATOMIC,
                .sk_flags       = (1UL << SOCK_USE_WRITE_QUEUE),
        },
-       .pmtudisc       = IP_PMTUDISC_WANT,
        .uc_ttl         = -1,
 };
 
@@ -1519,6 +1518,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
        inet = &get_cpu_var(unicast_sock);
 
        inet->tos = arg->tos;
+       inet->pmtudisc = ipv4_config.no_pmtu_disc ? IP_PMTUDISC_DONT : IP_PMTUDISC_WANT;
        sk = &inet->sk;
        sk->sk_priority = skb->priority;
        sk->sk_protocol = ip_hdr(skb)->protocol;
