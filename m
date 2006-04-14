From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 14 Apr 2006 16:53:29 -0700 (PDT)
Message-ID: <20060414.165329.24988172.davem@davemloft.net>
References: <Pine.WNT.4.63.0604141543170.2116@jbrandeb-desk.amr.corp.intel.com>
	<20060414.155202.82987818.davem@davemloft.net>
	<Pine.WNT.4.63.0604141553210.2116@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bb@kernelpanic.ru, herbert@gondor.apana.org.au,
	kernel@linuxace.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63885
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751332AbWDNX5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 19:57:15 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0604141553210.2116@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 15:55:10 -0700 (Pacific Daylight Time)

> I'm trying to isolate more of a reproduction case, I'll be sure to
> post if I can find anything with more detail.

I think I see the bug.

If tbench with large numbers of clients is part of what helps
reproduce it, the key might be hitting the memory limits in tcp_mem[]
and friends, or something to do with concurrent access to
sk->sk_forward_alloc.

I bet there is some race in there.

A lot of the action is in net/core/stream.c  We modify
sk->sk_forward_alloc non-atomically but that should be ok
since we ought to be holding all of the correct locks when
we hit these accesses.  But it is the first thing to audit.

Let's look at sk_stream_rfree() as that is invoked from SKB
freeing callbacks and is the most likely suspect for these
kinds of problems.

It is hooked up to the skb->destructor by sk_stream_set_owner_r() and
then invoked via __kfree_skb().

Nothing here takes any locks, and as stated above we modify
sk->sk_forward_alloc non-atomically, and this is therefore the bug.

Shit.

I'll think of how to fix this in the least invasive manner.  I also
want to search the changelog history to see if this race was always
present or if it was "introduced".

Making sk->sk_forward_alloc an atomic_t would be incredibly expensive
so I'll try to find a way to avoid that.  We may be able to just do
a bh_lock_sock()/bh_unlock_sock() around the body of sk_stream_rfree()
to fix this.
