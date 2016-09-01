From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [RT PATCH 2/2] net: add a lock around icmp_sk()
Date: Thu, 1 Sep 2016 10:11:46 +0200
Message-ID: <20160901081146.nabh52qssjkvztxz@linutronix.de>
References: <20160831160049.14303-1-bigeasy@linutronix.de>
 <20160831160049.14303-2-bigeasy@linutronix.de>
 <1472661463.14381.327.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
        tglx@linutronix.de, Steven Rostedt <rostedt@goodmis.org>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472661463.14381.327.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-08-31 09:37:43 [-0700], Eric Dumazet wrote:
> > --- a/net/ipv4/icmp.c
> > +++ b/net/ipv4/icmp.c
> > @@ -216,12 +219,14 @@ static inline struct sock *icmp_xmit_lock(struct net *net)
> >  
> >  	local_bh_disable();
> >  
> > +	local_lock(icmp_sk_lock);
> 
> Deadlock alert ?
> Please read the comment few lines after, explaining why we have to use
> spin_trylock().
> Or maybe I should double check what is local_lock() in RT

On !RT local_lock() is preempt_disable().
On RT local_lock() is a per-CPU sleeping spinlock which can be taken
recursively by the owner.

On a "normal" ping reply we have
- icmp_reply()
  - icmp_xmit_lock()
    - local_lock()
  - icmp_push_reply()
 icmp_send()
    - local_lock()

so that works. I didn't manage to resolve a possible dst_link_failure()
path but I would assume it is like the above (where the owner takes the
same local_lock() multiple times).

Sebastian
