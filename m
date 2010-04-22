From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 20:27:16 +0800
Message-ID: <t2t412e6f7f1004220527mb5340bebye1d1fda0963dcf2a@mail.gmail.com>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
	<20100422.024336.119875321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:33949 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab0DVM1h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 08:27:37 -0400
Received: by pzk32 with SMTP id 32so5319331pzk.21
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 05:27:36 -0700 (PDT)
In-Reply-To: <20100422.024336.119875321.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 5:43 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Thu, 22 Apr 2010 17:09:17 +0800
>
>> + =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0input_pkt_queue_len;
>> + =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*input_pkt_queue_head;
>> + =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0**input_pkt_queue_tailp;
>> +
>
> Please do not ignore Stephen Hemminger's feedback.
>
> We already have enough odd SKB queue implementations, we
> do not need yet another one in a core location. =A0This makes
> it harder and harder to eventually convert sk_buff to use
> "struct list_head".
>
> Instead, use "struct sk_buff_head" and the lockless accessors
> (__skb_insert, etc.) and initializer (__skb_queue_head_init).
>

If I want to keep softnet_data small, I have to access the internal
fields of sk_buff_head, and modify them in a hack way. It doesn't
sound good. If not, softnet_data will become:

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
        unsigned int            input_pkt_queue_len;
        struct sk_buff_head     input_pkt_queue;
        struct napi_struct      backlog;
};

Eric, do you think it is too fat?
