From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 07:14:50 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:45016 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbZDKFOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 01:14:53 -0400
In-Reply-To: <20090411041533.GB6822@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2009-04-11 06:15, Paul E. McKenney wrote:
>On Fri, Apr 10, 2009 at 06:39:18PM -0700, Linus Torvalds wrote:
>>An unhappy user reported:
>>>>> Adding 200 records in iptables took 6.0sec in 2.6.30-rc1 compared to 
>>>>> 0.2sec in 2.6.29. I've bisected down this commit.
>>>>> 784544739a25c30637397ace5489eeb6e15d7d49
>> 
>> I wonder if we should bring in the RCU people too, for them to tell you 
>> that the networking people are beign silly, and should not synchronize 
>> with the very heavy-handed
>> 
>> 	synchronize_net()
>> 
>> but instead of doing synchronization (which is probably why adding a few 
>> hundred rules then takes several seconds - each synchronizes and that 
>> takes a timer tick or so), add the rules to be free'd on some rcu-freeing 
>> list for later freeing.

iptables works in whole tables. Userspace submits a table, checkentry is 
called for all rules in the new table, things are swapped, then destroy 
is called for all rules in the old table. By that logic (which existed
since dawn I think), only the swap operation needs to be locked.

Jeff Chua wrote:
>So, to make it easy for testing, you can do a loop like this ...
>        for((i = 1; i < 100; i++))
>        do
>                iptables -A block -s 10.0.0.$i -j ACCEPT
>        done

The fact that `iptables -A` is called a hundred times means you are 
doing 100 table replacements -- instead of one. And calling
synchronize_net at least a 100 times.

"Wanna use iptables-restore?"

>1.	Assuming that the synchronize_net() is intended to guarantee
>	that the new rules will be in effect before returning to
>	user space:

As I read the new code, it seems that synchronize_net is only
used on copying the rules from kernel into userspace;
not when updating them from userspace:

IPT_SO_GET_ENTRIES -> get_entries -> copy_entries_to_user -> 
alloc_counters -> synchronize_net.

>3.	For the alloc_counters() case, the comments indicate that we
>	really truly do want an atomic sampling of the counters.
>	The counters are 64-bit entities, which is a bit inconvenient.
>	Though people using this functionality are no doubt quite happy
>	to never have to worry about overflow, I hasten to add!
>
>	I will nevertheless suggest the following egregious hack to
>	get a consistent sample of one counter for some other CPU:
>       [...]

Would a seqlock suffice, as it does for the 64-bit jiffies?
