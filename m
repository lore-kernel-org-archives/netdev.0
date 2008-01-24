From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Slow OOM  in netif_RX function
Date: Thu, 24 Jan 2008 10:29:52 -0800
Message-ID: <20080124102952.2a88bc1e@deepthought>
References: <4798CAA9.1080005@obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ivan Dichev <idichev@obs.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48464 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975AbYAXSdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 13:33:24 -0500
In-Reply-To: <4798CAA9.1080005@obs.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jan 2008 19:28:09 +0200
Ivan Dichev <idichev@obs.bg> wrote:

> Hello,
> I got problem with my linux router. It has slow persistent OOM
> problems from few months ago.
> Every working(I mean days when more traffic is generated) day my
> router is leaking with 15-20 MB memory and
> after 2 weeks the restart is a MUST.
> From /proc/slabinfo I saw that size-2048 and size-512 are growing
> rapidly every day when traffic occur.
> 
> --------- /proc/slabinfo --------------------
> size-2048          20322  20349   2072    3    2 : tunables   24  
> 12    0 : slabdata   6780   6783      0
> size-512           50984  51016    536    7    1 : tunables   32  
> 16    0 : slabdata   7288   7288      0
> 
> 
> I was wondering who is allocating this mem pools and then I changed
> the kernel with 2.6.23-rc12 including  options
> CONFIG_DEBUG_SLAB=y
> CONFIG_DEBUG_SLAB_LEAK=y
> 
> 
> Unfortunately changing the kernel didn't solve the mem leak....
> Now /proc/slab_allocators is showing that 3c59x driver is allocating
> 2048 and 512 bytes memory pools
> caused by RX function.
> --------- from /proc/slab_allocators ------------------------------
> 7612 size-2048: boomerang_rx+0x33b/0x437 [3c59x]
> 16018 size-512: boomerang_rx+0x165/0x437 [3c59x]
> 
> I was thinking that the 3com driver is bogus, .. but not!
> After few days I changed the cards with rtl8139 and now ....
> --------- from /proc/slab_allocators ------------------------------
> size-2048: 20159 rtl8139_rx+0x155/0x2dc [8139too]
> size-1024: 2693 rtl8139_rx+0x155/0x2dc [8139too]
> size-512: 50515 rtl8139_rx+0x155/0x2dc [8139too]
> 
> the memory leak appear again in the same function(RX).
> 
> I did search over the mailing list and found as similar only this
> http://www.spinics.net/lists/kernel/old/2003-q4/msg03071.html
> 
> 
> For sure it does not depend on kernel version and network
> driver(except case if both drivers are bogus :)
> Any ideas ?
> 
> Ivan
> 

Receive packets are allocated by the driver, and then consumed by
the protocols or sockets.  The problem is in the consumer side, so you need
to go looking to see if lots of data is getting queued to some application
that is never reading.  Alternatively, it could be some form of control packet
that is not properly processed by a protocol.

Also look at firewall and classification rules, could be a buggy iptables rule?

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
