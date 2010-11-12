From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 07:37:32 -0500
Message-ID: <1289565452.3090.222.camel@Dan>
References: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
	 <20101111.182939.258124014.davem@davemloft.net>
	 <1289529269.3090.207.camel@Dan>
	 <1289546610.17691.1770.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	kuznet@ms2.inr.ac.ru, urs.thuermann@volkswagen.de,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jmorris@namei.org,
	remi.denis-courmont@nokia.com, pekkas@netcore.fi, sri@us.ibm.com,
	vladislav.yasevich@hp.com, tj@kernel.org, lizf@cn.fujitsu.com,
	joe@perches.com, shemminger@vyatta.com, hadi@mojatatu.com,
	ebiederm@xmission.com, adobriyan@gmail.com, jpirko@redhat.com,
	johannes.berg@intel.com, daniel.lezcano@free.fr, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, torvalds@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:65216 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757119Ab0KLMhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 07:37:37 -0500
In-Reply-To: <1289546610.17691.1770.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> 1) Inode numbers are not guaranteed to be unique. Its a 32bit seq
> number, and we dont check another socket inode use the same inode number
> (after 2^32 allocations it can happens)
> 

Ok...this is a bit far-fetched, but I see your point.

> 2) /proc/net/ files can deliver same "line" of information several
> times, because of their implementation.
> 
> 3) Because of SLAB_DESTROY_BY_RCU, same 'kernel socket pointer' can be
> seen several times in /proc/net/tcp & /proc/net/udp, but really on
> different "sockets"
> 
> 4) Some good applications use both the socket pointer and inode number
> (tuple) to filter out the [2] problem. Dont break them, please ?
> Anything that might break an application must be at the very least
> tunable.
> 
> In my opinion, a good thing would be :
> 
> - Use a special printf() format , aka "secure pointer", as Thomas
> suggested.
> 

I am happy to write this, but just to be sure, you're sure we're ok with
a printf() format that cannot be used in interrupt context?  %pS and %ps
are taken, so I'm thinking %pH ("hidden").

> - Make sure you print different opaque values for two different kernel
> pointers. This is mandatory.
> 
> - Make sure the NULL pointer stay as a NULL pointer to not let the
> hostile user know your secret, and to ease debugging stuff.
> 

Alright, this is fine by me.

> - Have security experts advice to chose a nice crypto function, maybe
> jenkin hash. Not too slow would be nice.
> 
> 
> static unsigned long securize_kpointers_rnd;
> 
> At boot time, stick a random value in this variable.
> (Maybe make sure the 5 low order bits are 0)
> 

I don't really like the approach of relying on a global secret value
that's used repeatedly.  Sure, it's better than not obfuscating the
pointers at all, but it seems like it will be difficult to prevent its
value from being inferred or discovered.

> unsigned long opacify_kptr(unsigned long ptr)
> {
> 	if (ptr == 0)
> 		return ptr;
> 	if (capable(CAP_NET_ADMIN))
> 		return ptr;
> 
> 	return some_crypto_hash(ptr, &securize_kpointers_rnd);
> }
> 

I question the use of CAP_NET_ADMIN.  Sure, that makes sense in this
context, but wouldn't it be useful to be able to use this format
specifier outside of net?  In fact, I'm not sure that CAP_SYS_ADMIN is
appropriate either - perhaps just going off current_euid()?

> At least, use a central point, so that we can easily add/change the
> logic if needed.
> 
> Please provide this patch in kernel/printk.c for initial review, then
> once everybody is OK, you can send one patch for net tree.
> 

Do you mean lib/vsprintf.c?

> No need to send 10 patches if we dont agree on the general principle.

Agreed.

-Dan

