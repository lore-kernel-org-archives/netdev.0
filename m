From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC] myri10ge: small rx_done refactoring
Date: Thu, 24 Mar 2011 16:59:37 +0100
Message-ID: <20110324155937.GA6041@redhat.com>
References: <20110323124939.GA7834@redhat.com>
 <20110323083357.457f10aa@nehalam>
 <20110324081621.GA5508@redhat.com>
 <20110324081539.47ad0972@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933821Ab1CXQAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 12:00:15 -0400
Content-Disposition: inline
In-Reply-To: <20110324081539.47ad0972@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 08:15:39AM -0700, Stephen Hemminger wrote:
> > On Wed, Mar 23, 2011 at 08:33:57AM -0700, Stephen Hemminger wrote:
> > > On Wed, 23 Mar 2011 13:52:04 +0100
> > > Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> > > 
> > > > Add lro_enable variable to read NETIF_F_LRO flag only once per napi poll
> > > > call. This should fix theoretical race condition with
> > > > myri10ge_set_rx_csum() and myri10ge_set_flags() where flag NETIF_F_LRO
> > > > can be changed.
> > > 
> > > You may need a barrier or the race may still be there.
> > 
> > I don't understand why barrier in that case is need.
> > 
> > What I tried to avoid is.
> > 
> > myri10ge_clean_rx_done():
> > 
> > if (dev->features & NETIF_F_LRO) 
> > 	setup lro 
> > 					myri10ge_set_flags()
> > 
> > if (dev->features & NETIF_F_LRO)
> > 	flush lro
> > 
> > Now we read dev->features & NETIF_F_LRO only once to local
> > lro_enabled variable. So we can not flush without setup
> > or setup without flush. No idea why memory barries is still
> > needed.
> > 
> > > The driver seems to use mb() where wmb() is intended, and never use rmb()?
> > 
> > Yes, I think we can have some optimalization here.
> > 
> 
> Without barrier there is no guarantee that compiler read the flags
> into a local variable. It is free to do the same thing as the original
> code.

Ok, so C code like:

code1
if (dev->features & NETIF_F_LRO) 
	branch1
code2;
if (dev->features & NETIF_F_LRO)
	branch2

and

bool lro_enabled = dev->features & NETIF_F_LRO;
code1
if (lro_enabled)
	branch1
code2
if (lro_enabled)
	branch2

can give the same assembly output.

It's really hard for me to understand that. I could
understand, if we would get global variable directly
like:
bool lro_enabled = dev->lro_enabled;
instead of:
bool lro_enabled = dev->features & NETIF_F_LRO;

David, can you confirm that Staphen is correct?

Also where this barrier() should go. Before  
"bool lro_enabled = dev->features & NETIF_F_LRO;"
or after?

Stanislaw
