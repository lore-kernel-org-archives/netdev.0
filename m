From: Neal Cardwell <ncardwell@google.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 23 Feb 2012 13:39:00 -0500
Message-ID: <CADVnQyk+ujAXPh1=59TB-Pb6ZcQX8NWCN5pWoNvXXLBnr6qOhg@mail.gmail.com>
References: <20120222055139.GB8026@google.com>
	<1329896195.18384.83.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50438 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab2BWSjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 13:39:02 -0500
Received: by qadc10 with SMTP id c10so7011925qad.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 10:39:01 -0800 (PST)
In-Reply-To: <1329896195.18384.83.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2012 at 2:36 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> This skb->truesize/skb->len affair is suspect if you ask me.
>
> We increase rcv_ssthresh if we receive a 'good skb', but we have no
> guarantee of future skbs.
>
> When we are close to the converged value, we might spend some time in
> tcp_grow_window() and decide not to increase rcv_sshthresh
>
> IMHO a better way would be to look at integration values
> (sk->sk_rmem_alloc) to not increase rcv_sshthresh if socket receive
> queue is full of 'bad skbs'

I agree that using a single skb->truesize/skb->len sample is
unfortunate, and it would be nice to have a larger sample size.

Looking at sk->sk_rmem_alloc would be an improvement, though I'm
guessing that often this will still be a small sample of just a couple
of packets, for the case of well-behaved apps that mostly keep up with
reading everything that arrives in their read buffer.

If we wanted a larger sample of truesize/len ratios, perhaps we'd want
some sort of exponentially weighted moving average of skb->truesize
and skb->len, or the ratio of the two. That could give us a larger
sample even for well-behaved apps that keep their read queues short.
But that is starting to seem like it's perhaps overkill.

> Note that with your patch and 'good skb', rcv_ssthresh increases slower
> than before (MSS increases instead of 2*MSS)

Good point. How about:

  u32 incr = max(skb->len, 2U * tp->advmss);

Or do you think we'd want:

  u32 incr = 2U * max(skb->len, tp->advmss);

neal
