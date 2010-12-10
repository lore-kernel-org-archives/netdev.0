From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Fri, 10 Dec 2010 17:05:32 +0100
Message-ID: <1291997132.13513.12.camel@laptop>
References: <1291863926.2965.1.camel@Dan>
	 <1291865039.2795.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Dan Rosenberg <drosenberg@vsecurity.com>,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1291865039.2795.46.camel@edumazet-laptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-09 at 04:23 +0100, Eric Dumazet wrote:
> > +             if (kptr_restrict) {
> > +                     if (in_interrupt())
> > +                             WARN(1, "%%pK used in interrupt context.\n");
> 
> So caller can not block BH ?
> 
> This seems wrong to me, please consider :
> 
> normal process context :
> 
> spin_lock_bh() ...
> 
> for (...)  
>         {xxx}printf( ...   "%pK"   ...)
> 
> spin_unlock_bh(); 

That's a bug in in_interrupt(), one I've been pointing out for a long
while. Luckily we recently grew the infrastructure to deal with it.

If you write it as: if (in_irq() || in_serving_softirq() || in_nmi())
you'll not trigger for the above example.

Ideally in_serving_softirq() wouldn't exist and in_softirq() would do
what in_server_softirq() does -- which would make it symmetric with the
hardirq functions -- but nobody has found time to audit all in_softirq()
users.


