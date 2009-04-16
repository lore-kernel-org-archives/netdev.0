From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH[] netfilter: use per-cpu reader-writer lock (v0.7)
Date: Thu, 16 Apr 2009 14:02:42 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904161353370.4042@localhost.localdomain>
References: <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam>
 <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net> <20090416144748.GB6924@linux.vnet.ibm.com> <49E75876.10509@cosmosbay.com> <20090416175850.GH6924@linux.vnet.ibm.com> <49E77BF6.1080206@cosmosbay.com> <20090416134956.6c1f0087@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>, paulmck@linux.vnet.ibm.com,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090416134956.6c1f0087@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Apr 2009, Stephen Hemminger wrote:
>
> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> rwlock that can be nested. It is sort of like earlier brwlock 
> (fast reader, slow writer). The locking is isolated so future improvements
> can concentrate on measuring/optimizing xt_table_info_lock. I tried
> other versions based on recursive spin locks and sequence counters and 
> for me, the risk of inventing own locking primitives not worth it at this time.

This is stil scary.

Do we guarantee that read-locks nest in the presense of a waiting writer 
on another CPU? Now, I know we used to (ie readers always nested happily 
with readers even if there were pending writers), and then we broke it. I 
don't know that we ever unbroke it.

IOW, at least at some point we deadlocked on this (due to trying to be 
fair, and not lettign in readers while earlier writers were waiting):

	CPU#1			CPU#2

	read_lock

				write_lock
				.. spins with write bit set, waiting for
				   readers to go away ..

	recursive read_lock
	.. spins due to the write bit
	   being. BOOM: deadlock  ..

Now, I _think_ we avoid this, but somebody should double-check.

Also, I have still yet to hear the answer to why we care about stale 
counters of dead rules so much that we couldn't just free them later with 
RCU.

			Linus
