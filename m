From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 09:33:11 -0700
Message-ID: <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20151218185812.GD4448@1wt.eu>
	 <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151219070009.GA4634@1wt.eu>
	 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	 <20151221204127.GC8018@1wt.eu>
	 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	 <20160324061222.GA6807@1wt.eu>
	 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324142222.GB7237@1wt.eu>
	 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324153053.GA7569@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34169 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbcCXQdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 12:33:13 -0400
Received: by mail-pa0-f48.google.com with SMTP id fe3so26642684pab.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 09:33:13 -0700 (PDT)
In-Reply-To: <20160324153053.GA7569@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2016-03-24 at 16:30 +0100, Willy Tarreau wrote:
> Hi Eric,
> 
> (just lost my e-mail, trying not to forget some points)
> 
> On Thu, Mar 24, 2016 at 07:45:44AM -0700, Eric Dumazet wrote:
> > On Thu, 2016-03-24 at 15:22 +0100, Willy Tarreau wrote:
> > > Hi Eric,
> > 
> > > But that means that any software making use of SO_REUSEPORT needs to
> > > also implement BPF on Linux to achieve the same as what it does on
> > > other OSes ? Also I found a case where a dying process would still
> > > cause trouble in the accept queue, maybe it's not redistributed, I
> > > don't remember, all I remember is that my traffic stopped after a
> > > segfault of only one of them :-/ I'll have to dig a bit regarding
> > > this.
> > 
> > Hi Willy
> > 
> > Problem is : If we add a SO_REUSEPORT_LISTEN_OFF, this wont work with
> > BPF. 
> 
> I wasn't for adding SO_REUSEPORT_LISTEN_OFF either. Instead the idea was
> just to modify the score in compute_score() so that a socket which disables
> SO_REUSEPORT scores less than one which still has it. The application
> wishing to terminate just has to clear the SO_REUSEPORT flag and wait for
> accept() reporting EAGAIN. The patch simply looked like this (copy-pasted
> hence space-mangled) :
> 
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -189,6 +189,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
>                                 return -1;
>                         score += 4;
>                 }
> +               if (sk->sk_reuseport)
> +                       score++;

This wont work with BPF

>                 if (sk->sk_incoming_cpu == raw_smp_processor_id())
>                         score++;

This one does not work either with BPF

>         }
> 
> > BPF makes a decision without knowing individual listeners states.
> 
> But is the decision taken without considering compute_score() ? The point
> really was to be the least possibly intrusive and quite logical for the
> application : "disable SO_REUSEPORT when you don't want to participate to
> incoming load balancing anymore".

Whole point of BPF was to avoid iterate through all sockets [1],
and let user space use whatever selection logic it needs.

[1] This was okay with up to 16 sockets. But with 128 it does not scale.

If you really look at how BPF works, implementing another 'per listener' flag
would break the BPF selection.

You can certainly implement the SO_REUSEPORT_LISTEN_OFF by loading an
updated BPF, why should we add another way in the kernel to do the same,
in a way that would not work in some cases ?
