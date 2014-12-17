From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Netlink mmap tx security?
Date: Wed, 17 Dec 2014 16:26:46 +0000
Message-ID: <20141217162646.GB28766@casper.infradead.org>
References: <20141014.220908.123550384430402000.davem@davemloft.net>
 <543F6998.5090000@redhat.com>
 <20141016070753.GA16738@casper.infradead.org>
 <20141216.175817.576861457076632402.davem@davemloft.net>
 <1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dborkman@redhat.com,
	luto@amacapital.net, torvalds@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55987 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaLQQ0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 11:26:49 -0500
Content-Disposition: inline
In-Reply-To: <1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/14 at 04:02pm, Eric Dumazet wrote:
> On Tue, 2014-12-16 at 17:58 -0500, David Miller wrote:
> 
> > +		__skb_put(skb, nm_len);
> > +		memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, nm_len);
> > +		netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
> >  
> 
> Not related to this patch, but it looks like netlink_set_status()
> barrier is wrong ?
> 
> It seems we need smp_wmb() after the memcpy() and before the
> hdr->nm_status = status; 

Yes, definitely wrong as-is. I'll send a patch. For the particular
case we'd need a smp_rmb() after the memcpy() to complete the loads.
The skb destructor needs a smp_wmb() after setting nm_len. We could
get away with a smp_wmb() first thing in netlink_set_status() with
the code as-is but smp_mb() might be the less fragile thing to do.
Objections?
