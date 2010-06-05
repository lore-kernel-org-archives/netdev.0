From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 5 Jun 2010 21:26:05 +0800
Message-ID: <AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
	<1275743224.3490.44.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44435 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756109Ab0FEN0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:26:25 -0400
Received: by pwj5 with SMTP id 5so342140pwj.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:26:25 -0700 (PDT)
In-Reply-To: <1275743224.3490.44.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 5, 2010 at 9:07 PM, jamal <hadi@cyberus.ca> wrote:
> Changli,
>
> I like the idea..
>
> My preference would be to not change ingress qdisc to have queues.

ingress doesn't have any qdisc, but a class tree. The ingress_queue
will be sth. like this:

while (1) {
 result = tc_classify(..., &res);
 cl = ingress_find(res.classid, ...);
 if (!cl->level)
     break;
 ...
}

Then we can classify skbs in tree  manner.

> The cpuid should be sufficient to map to a remote cpu queue, no?

It should be sufficient, but it isn't efficient. With map option, we
can use cls_flow to map traffic to classid, and use act_cpu map to map
classid to cpuid.

> Now, if you could represent each cpu as a netdevice, then we wouldnt
> need any change;-> And we could have multiple types of ways to redirect
> to cpus instead of just doing IPIs - example, ive always thought of
> sending over something like HT (I think it would be a lot cheaper).

I won't implement a new netdevice, but reuse the softnet. Even, I'll
reuse the enqueue_to_backlog() introduced by RPS, and of course, use
IPIs as RPS. Is there another way to trigger an IRQ of the remote CPU?

>
> I didnt queit understand the map OFFSET part. is this part of rfs?
>

No. As class IDs are started from 1, but CPU IDs are started from 0, I
need to minus/add a number from/to class IDs to map class IDs from CPU
IDs.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
