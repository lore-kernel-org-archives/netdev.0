From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Wed, 25 Mar 2015 15:26:34 -0700
Message-ID: <1427322394.25985.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427107090-4100-1-git-send-email-alexey.kodanev@oracle.com>
	 <1427118726.25985.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <551327C0.3020303@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33684 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbbCYW0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:26:36 -0400
Received: by iecvj10 with SMTP id vj10so33772342iec.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:26:35 -0700 (PDT)
In-Reply-To: <551327C0.3020303@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-26 at 00:25 +0300, Alexey Kodanev wrote:

> Did various testing with exactly that change and hadn't found any 
> "serious performance impact" on the stack (at least on my configuration).

Sure, but nobody will take the risk to make such change without serious
tests on multiple workloads and arches.

> 
> Alright, what about other part of the patch, is it acceptable?
> 
> I came up with one more solution... not so radical :)
> We can restore inet6_skb_parm with
> 
>      memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6, ...)
> 
> in the two places in tcp_v6_rcv(), before xfrm6_policy_check() + 
> tcp_v6_fill_cb() are called again:
> 
>   static int tcp_v6_rcv(struct sk_buff *skb)
>   {
>          const struct tcphdr *th;
> @@ -1543,6 +1552,7 @@ do_time_wait:
>                          inet_twsk_deschedule(tw, &tcp_death_row);
>                          inet_twsk_put(tw);
>                          sk = sk2;
> +                       tcp_v6_restore_cb(skb);
>                          goto process;
>                  }
>                  /* Fall through to ACK */
> @@ -1551,6 +1561,7 @@ do_time_wait:
>                  tcp_v6_timewait_ack(sk, skb);
>                  break;
>          case TCP_TW_RST:
> +               tcp_v6_restore_cb(skb);
>                  goto no_tcp_socket;
>          case TCP_TW_SUCCESS:
> 

Looks good to me !
