From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs copy_to_user].
Date: Thu, 11 May 2006 10:40:37 +0400
Message-ID: <20060511064037.GB22770@2ka.mipt.ru>
References: <20060508122418.GA22554@2ka.mipt.ru> <20060510.125848.44052388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:21927 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965157AbWEKGlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 02:41:37 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060510.125848.44052388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 10, 2006 at 12:58:48PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Mon, 8 May 2006 16:24:22 +0400
> 
> > I hope he does not take offence at name shortening :)
> 
> Perhaps you are still not convinced how truly expensive the code path
> from netif_receive_skb() to the protocol receive processing really is.

That is why UDP was selected - it is itself does not cost anything,
ip_rcv() + netif_receive_skb() will be in any channels, but instead of
searching through unified cache with src/port/dst/port/proto we search
through src/port/dst/port + through proto in ip_rcv().
There are no locks there except disabled preemption, those codepath
_never_ showed in profiles.
Grand unified cache is of course a good idea, but it will not bring new
performance gain to Linux.
It _is_ much more convenient and code path will be shorter, but only
because route/dst lookup will be hidden in unified cache.

Memory copy and context switch were eliminated in net channel, and that 
trashed any cache much more than than removing 50 lines of code accessed
parts of skb->data.

> It is absolutely necessary to find ways to get rid of these layering
> costs.  "Layering is how you design networking protocols, not how you
> implement them."

If I provide a patch which will allow to mark special socket as
no-protocol-and-any-upper-layer-lookup, but instead process skb->data
(like copying to userspace, or just allow recv() to return without any
copy) and performance will not differ from what we have with layers, 
will it justify that not abstract cache trashing and lookup split into
socket/route are not the problem?

Or have you switched from engineering to researching mode? :)

-- 
	Evgeniy Polyakov
