From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Fri, 05 Feb 2010 11:00:03 +0100
Message-ID: <4B6BEC23.8020101@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net> <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100204194744.GA4185@x200>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Thu, Feb 04, 2010 at 06:04:34PM +0100, Patrick McHardy wrote:
>> Patrick McHardy wrote:
>>> Alexey Dobriyan wrote:
>>>> Jon Masters correctly points out that conntrack hash sizes
>>>> (nf_conntrack_htable_size) are global (not per-netns) and
>>>> modifiable at runtime via /sys/module/nf_conntrack/hashsize .
>>>>
>>>> Steps to reproduce:
>>>> 	clone(CLONE_NEWNET)
>>>> 	[grow /sys/module/nf_conntrack/hashsize]
>>>> 	exit()
>>>>
>>>> At netns exit we are going to scan random memory for conntracks to be killed.
>>>>
>>>> Apparently there is a code which deals with hashtable resize for
>>>> init_net (and it was there befode netns conntrack code), so prohibit
>>>> hashsize modification if there is more than one netns exists.
>>>>
>>>> To change hashtable sizes, you need to reload module.
>>>>
>>>> Expectation hashtable size was simply glued to a variable with no code
>>>> to rehash expectations, so it was a bug to allow writing to it.
>>>> Make "expect_hashsize" readonly.
>>>>
>>>> This is temporarily until we figure out what to do.
>>> How about alternatively moving nf_conntrack_hsize into the
>>> per-namespace struct? It doesn't look more complicated or
>>> intrusive and would allow to still change the init_net
>>> hashsize. Also seems less hackish :)
>> How about this (so far untested) patch? The htable_size is moved into
>> the per-namespace struct and initialized from the current (global)
>> value of nf_conntrack_htable_size. Changes through sysfs are still
>> permitted, but only affect the init namespace and newly created ones.
> 
> No matter what we do, it's a hack!
> 
>> Additionally I removed reinitializing the hash random value when
>> changing the hash size since that also requires to rehash in all
>> namespaces.
> 
> I'm not fond of this, because we're not even closely going to allow changing
> hashtable size per-netns. As such having actual per-netns hashtable size
> just slows down everything.

Actually it doesn't seem like much more work to allow changing
table size, the main problem is that sysfs module parameters
don't seem to fit into the network namespace model at all.

Please be more specific about your suspected slowdowns.
What's "everything"? What's different about the hashsize
compared to the many members we already moved to per-netns
structs?
