From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 05:47:45 -0500
Message-ID: <1265107666.2861.117.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:42676 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab0BBKsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 05:48:09 -0500
In-Reply-To: <1265035970.2848.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-01 at 15:52 +0100, Eric Dumazet wrote:

> [PATCH] netfilter: per netns nf_conntrack_cachep
> 
> nf_conntrack_cachep is currently shared by all netns instances, but
> because of SLAB_DESTROY_BY_RCU special semantics, this is wrong.
> 
> If we use a shared slab cache, one object can instantly flight between
> one hash table (netns ONE) to another one (netns TWO), and concurrent
> reader (doing a lookup in netns ONE, 'finding' an object of netns TWO)
> can be fooled without notice, because no RCU grace period has to be
> observed between object freeing and its reuse.

I'll test this patch.

After some lengthy debugging, what actually happens here is that the
nf_conntrack_cachep SL*U*B gets corrupted such that the contained
per-cpu cpu_slabs are all pointing to the address of htable_size, which
is then helpfully set to be the value of the individual freelists (the
address of the base of the kmem_cache), or offset '51' into the table.
The worrying thing is it looks like this is actually corrupting other
random memory too, it just happens to bite once we get this far.

Jon.


