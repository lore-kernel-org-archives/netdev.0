From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/6] tcp: do not assume TCP code is non
 preemptible
Date: Thu, 28 Apr 2016 18:08:42 -0700
Message-ID: <1461892122.5535.125.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
	 <1461821152-23200-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:32980 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcD2BIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:08:46 -0400
Received: by mail-yw0-f181.google.com with SMTP id t10so156769817ywa.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 18:08:45 -0700 (PDT)
In-Reply-To: <1461821152-23200-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 22:25 -0700, Eric Dumazet wrote:
> We want to to make TCP stack preemptible, as draining prequeue
> and backlog queues can take lot of time.
> 
> Many SNMP updates were assuming that BH (and preemption) was disabled.
> 
> Need to convert some __NET_INC_STATS() calls to NET_INC_STATS()
> and some __TCP_INC_STATS() to TCP_INC_STATS()
> 
> Before using this_cpu_ptr(net->ipv4.tcp_sk) in tcp_v4_send_reset()
> and tcp_v4_send_ack(), we add an explicit preempt disabled section.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

I'll send a V2 including following changes I missed :

I'll also include the sendmsg() latency breaker.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0509a685d90c..25d527922b18 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2698,7 +2698,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
                        tp->retrans_stamp = tcp_skb_timestamp(skb);
 
        } else if (err != -EBUSY) {
-               __NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
+               NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
        }
 
        if (tp->undo_retrans < 0)
@@ -2822,7 +2822,7 @@ begin_fwd:
                if (tcp_retransmit_skb(sk, skb, segs))
                        return;
 
-               __NET_INC_STATS(sock_net(sk), mib_idx);
+               NET_INC_STATS(sock_net(sk), mib_idx);
 
                if (tcp_in_cwnd_reduction(sk))
                        tp->prr_out += tcp_skb_pcount(skb);
