From: David Miller <davem@davemloft.net>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 16:45:11 -0500 (EST)
Message-ID: <20130116.164511.2027039182184636075.davem@davemloft.net>
References: <1358316366.14898.8.camel@cr0>
	<50F6B761.8070106@linux-ipv6.org>
	<1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
	eblake@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, libc-alpha@sourceware.org, schwab@suse.de,
	carlos@systemhalted.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 16 Jan 2013 15:47:12 +0000

> On Wed, 2013-01-16 at 23:21 +0900, YOSHIFUJI Hideaki wrote:
>> Cong Wang wrote:
>> > (Cc'ing some glibc developers...)
>> > 
>> > Hello,
>> > 
>> > In glibc source file inet/netinet/in.h and kernel source file
>> > include/uapi/linux/in6.h, both define struct in6_addr, and both are
>> > visible to user applications. Thomas reported a conflict below.
>> > 
>> > So, how can we handle this? /me is wondering why we didn't see this
>> > before.
> [...]
>> This is not a new issue.  In addition to this,
>> netinet/in.h also conflits with linux/in.h.
>> 
>> We might have
>>  #if !defined(__GLIBC__) || !defined(_NETINET_IN_H)
>>  :
>>  #endif
>> around those conflicting definitions in uapi/linux/in{,6}.h.
> 
> This only solves half the problem, as <netinet/in.h> might be included
> after <linux/in.h>.  Also, not all Linux userland uses glibc.

So I've been looking at reasonable ways to fix this.

What would be really nice is if GCC treated multiple identical
definitions of structures the same way it handles multiple identical
definitions of CPP defines.  Which is to silently accept them.

But that's not the case, so we need a different solution.

Another thing to do is to use a new structure for in6_addr in kernel
headers exported to userland.

If we were to make the structure members and accessor macros identical
we could avoid breaking most if not all apps.

However the type name is different so:

	struct in6_addr *p = &kern_struct->member;

wouldn't work so well.  And you couldn't fix up the sources to these
kinds of accesses in a way that work cleanly both before and after
changing the kernel headers.

I'm out of ideas for today.
