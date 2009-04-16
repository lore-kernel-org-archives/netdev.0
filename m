From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu recursive spinlock  (v6)
Date: Thu, 16 Apr 2009 09:37:07 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904160926520.4042@localhost.localdomain>
References: <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
 <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net> <20090416144748.GB6924@linux.vnet.ibm.com> <49E75876.10509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55371 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756812AbZDPQrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 12:47:39 -0400
In-Reply-To: <49E75876.10509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 16 Apr 2009, Eric Dumazet wrote:
>  
> +struct rec_lock {
> +	spinlock_t lock;
> +	int	   count; /* recursion count */
> +};
> +static DEFINE_PER_CPU(struct rec_lock, arp_tables_lock);

What the _fuck_ are you doing?

Stop sending these shit-for-brains crazy patches out. That's not a lock, 
that's a messy way of saying "I don't know what the hell I'm doing, but 
I'll mess things up".

Don't do recursive locks (or your own locking primitives in general), but 
goddammit, if you have to, at least know what the hell you're doing. Your 
thing is a piece of shit.

A recursive lock needs an owner, or it's not a lock at all. It's some 
random data structure that contains a lock that may or may not be taken, 
and that may actually _work_ depending on the exact patterns of taking the 
lock, but that's not an excuse.

The fact that code "happens to work by mistake" (and I'm not saying that 
your does - but it might just because of the per-cpu'ness of it, and I'm 
not even going to look at crap like that it closer to try to prove it one 
way or the other) does not make that code acceptable.

Because even if it works today, it's just a bug waiting to happen. The 
thing you did is _not_ a generic recursive lock, and it does _not_ work in 
general. Don't call it a "rec_lock". Don't write code that accesses it 
without any comments as if it was simple. Just DON'T.

Guys, this whole discussion has just been filled with crazy crap. Can 
somebody even explain why we care so deeply about some counters for 
something that we just _deleted_ and that have random values anyway?

I can see the counters being interesting while a firewall is active, but I 
sure don't see what's so wonderfully interesting after-the-fact about a 
counter on something that NO LONGER EXISTS that it has to be somehow 
"exactly right".

And it's certainly not interesting enough to merit this kind of random 
fragile crazy code.

Please. Get a grip, people!

Show of hands, here: tell me a single use that really _requires_ those 
exact counters of a netfilter rule that got deleted and is no longer 
active?

			Linus
