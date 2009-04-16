From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Wed, 15 Apr 2009 17:01:11 -0700
Message-ID: <20090415170111.6e1ca264@nehalam>
References: <49E5BDF7.8090502@trash.net>
	<20090415135526.2afc4d18@nehalam>
	<49E64C91.5020708@cosmosbay.com>
	<20090415.164811.19905145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, kaber@trash.net, jeff.chua.linux@gmail.com,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090415.164811.19905145.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Apr 2009 16:48:11 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 15 Apr 2009 23:07:29 +0200
> 
> > Well, it seems original patch was not so bad after all
> > 
> > http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/023175.html
> > 
> > So change per-cpu spinlocks to per-cpu rwlocks 
> > 
> > and use read_lock() in ipt_do_table() to allow recursion...
> 
> Grumble, one more barrier to getting rid of rwlocks in the whole
> tree. :-/

Hey, we are reinventing your brwlock ;-<

The other option is use spinlock, over a smaller area (only counters),
and other mechanism to synchronize on replace.

> I really think we should entertain the idea where we don't RCU quiesce
> when adding rules.  That was dismissed as not workable because the new
> rule must be "visible" as soon as we return to userspace but let's get
> real, effectively it will be.

The counters are the bigger problem, otherwise we could just free table
info via rcu.  Do we really have to support: replace where the counter
values coming out to user space are always exactly accurate, or is it
allowed to replace a rule and maybe lose some counter ticks (worst case
NCPU-1).

> If there are any stale object reference issues, we can use RCU object
> destruction to handle that kind of thing.

The problem is pulling the counter values out of the object in the
replace case. It could be changed to use some form of counting semaphore
like thing but that gets expensive.
 
> I almost cringed when the per-spinlock idea was proposed, but per-cpu
> rwlocks just takes things too far for my tastes.

