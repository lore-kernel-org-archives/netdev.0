From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: locking in net_device_ops callbacks
Date: Wed, 21 Mar 2012 19:58:19 +0000
Message-ID: <1332359899.2553.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Haran <jharan@bytemobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10455 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757891Ab2CUT6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 15:58:22 -0400
In-Reply-To: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-21 at 18:59 +0000, Jeff Haran wrote:
> Hi,
> 
> I had posted the below to the kernelnewbies email list and never got a
> response. I am hoping somebody on this list could provide some
> feedback.
> 
> Just to be clear, it's not the issue of copying the MAC address that I
> am asking about. That's just an example.
> 
> What I am trying to understand is, what mechanisms generally are at
> play to serialize access to struct net_device private data that is
> accessed in both process and softirq contexts? Explicit locking
> "seems" to be mostly absent from the driver sources I've inspected so
> I can't help but believe I am missing something fundamental here.
[...]
> I can't help but notice there is no locking going on around the
> memcpy()s of the passed in MAC address to the net_device dev_addr and
> private data mac_addr fields.
> 
> I assume that e1000_set_mac() is typically called in process context in
> response to some user space application like ifconfig or ip changing the
> interface MAC address.

Yes.  Most interface reconfiguration is done in process context, with
the (global) rtnetlink lock held.  The address *lists* (additional
unicast addresses and multicast addresses) may be updated in softirq
context, and are updated with the (per-interface) addr_lock held.

> I am also assuming that these dev_addr and
> mac_addr fields are also referenced in other contexts. An Ethernet MAC
> address is 6 bytes, so the memcpy()'s can't be atomic operations at
> least on a 32 bit machine.
> 
> Shouldn't there have been some sort of lock taken before the memcpy()s
> are executed so that other execution contexts won't see a partially
> copied MAC address?

As I think you've recognised, the MAC address may still be read when
constructing packet headers.  eth_mac_addr() fails if the interface is
running, which should avoid this problem.  However some other
implementations of ndo_set_mac_address don't check that.  Maybe they
should - or else that check should be done in the caller,
dev_set_mac_address().

> Is there some sort of lock taken higher up the call stack by the code
> that calls these callback functions so that the callbacks themselves
> don't have to do it explicitly?

In most cases, yes.

> I am writing a network device driver (modifying an existing one
> actually) and am therefore trying to understand what kinds of explicit
> locking my net_device_ops callbacks need to take in order to ensure
> proper operation on an SMP system.

I would like to point you to documentation, but unfortunately I can't
see an up-to-date description.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
