From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 10:18:50 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904221001270.3101@localhost.localdomain>
References: <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam>
 <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu> <49EE2293.4090201@cosmosbay.com> <20090422073524.GA31835@elte.hu> <49EEDAF0.2010507@cosmosbay.com> <alpine.LFD.2.00.0904220806320.3101@localhost.localdomain>
 <49EF4C75.6060604@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54377 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753424AbZDVRaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 13:30:13 -0400
In-Reply-To: <49EF4C75.6060604@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 22 Apr 2009, Eric Dumazet wrote:
> 
> I actually sent *one* buggy patch, and you already gave your feedback 
> and NACK.

Actually, the thing is, I don't even think your original patch was even 
buggy. The bug crept in later. I NAK'ed it not because it was buggy, but 
because of the ad-hoc'ness and the naming. Really.

And I actually even said so in my original rant:

 'The fact that code "happens to work by mistake" (and I'm not saying that
  your does - but it might just because of the per-cpu'ness of it [..]'

because your original patch still had the

	rcu_read_lock_bh();

in place before the whole

	rl = &__get_cpu_var(arp_tables_lock);
	if (likely(rl->count++ == 0))
		spin_lock(&rl->lock);

and that should have protected against both BH callers and preemption.

So I actually believe that your original patch probably worked fine (but 
as I said in my reaction to it, I thought it was almost by mistake and I 
wasn't going to review it)

So the actual _bug_ crept in later, when the RCU lock was removed, and the 
lock was cleaned up and separated into a function of its own.

And in fact, that is kind of my point: "uncommented locking with ad-hoc 
semantics is very fragile". Even _correct_ code ends up not being correct 
in the long run, because people don't realize all the subtle issues.

> I even relayed this to Stephen suggesting him not calling this a recursive lock.
> (Note how I use 'suggesting' here)
> 
> So, what do you want from me ? Should I copy 100 times :

So I consider this thread ended from a technical standpoint.

[ That said, I will not be at all shocked to hear if people decide later 
  that the RCU method was better after all, and that even the per-cpu
  rwlock or spinlock is just too expensive. ]

My problem today (apart from the relatively minor issue of also wanting to 
get the commit log fixed up) is just that I see emails from you finding my 
reaction shocking and from Jarek Poplawski that seem to still think that 
I'm a troll.

Just because I pointed out real technical problems? Is that shocking or 
trolling?

Really - please go back to my _original_ email. No, it was not polite. But 
here's another quote from it:

  "Because even if it works today, it's just a bug waiting to happen."

and dammit, I sent that out _before_ the very next version of the patch 
that actually _did_ introduce that exact bug.

So dammit - what part of my email was "shocking" or "trolling"? The part 
where I was right? Or what?

			Linus
