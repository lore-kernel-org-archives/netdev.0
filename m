From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 21:06:19 +0800
Message-ID: <y2n412e6f7f1004220606id324dc9bj2cc04cfbad50a101@mail.gmail.com>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
	<1271936227.7895.5285.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:35147 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab0DVNGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 09:06:40 -0400
Received: by pwj9 with SMTP id 9so5909558pwj.19
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 06:06:39 -0700 (PDT)
In-Reply-To: <1271936227.7895.5285.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 7:37 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> Please reorder things better.
>
> Most likely this function is called for one packet.
>
> In your version you take twice the rps_lock()/rps_unlock() path, so
> it'll be slower.
>
> Once to 'transfert' one list to process list
>
> Once to be able to do the 'label out:' post processing.
>

It doesn't make any difference. We have to hold rps_lock to update
input_pkt_queue_len, if we don't use another variable to record the
length of the process queue, or atomic variable.

I think it is better that using another variable to record the length
of the process queue, and updating it before process_backlog()
returns. For one packet, there is only one locking/unlocking. There is
only one issue you concerned: cache miss due to sum the two queues'
length. I'll change softnet_data to:

struct softnet_data {
        struct Qdisc            *output_queue;
        struct list_head        poll_list;
        struct sk_buff          *completion_queue;
        struct sk_buff_head     process_queue;

#ifdef CONFIG_RPS
        struct softnet_data     *rps_ipi_list;

        /* Elements below can be accessed between CPUs for RPS */
        struct call_single_data csd ____cacheline_aligned_in_smp;
        struct softnet_data     *rps_ipi_next;
        unsigned int            cpu;
        unsigned int            input_queue_head;
#endif
        unsigned int            process_queue_len;
        struct sk_buff_head     input_pkt_queue;
        struct napi_struct      backlog;
};

=46or one packets, we have to update process_queue_len in any way. For
more packets, we only change process_queue_len just before
process_backlog() returns. It means that process_queue_len change is
batched.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
