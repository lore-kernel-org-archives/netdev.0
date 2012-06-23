From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Add sysctl knob to control early socket demux
Date: Fri, 22 Jun 2012 17:15:09 -0700 (PDT)
Message-ID: <20120622.171509.1112294083000632011.davem@davemloft.net>
References: <20120621235011.29846.29715.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756380Ab2FWAPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 20:15:10 -0400
In-Reply-To: <20120621235011.29846.29715.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 21 Jun 2012 16:58:31 -0700

> This change is meant to add a control for disabling early socket demux.
> The main motivation behind this patch is to provide an option to disable
> the feature as it adds an additional cost to routing that reduces overall
> throughput by up to 5%.  For example one of my systems went from 12.1Mpps
> to 11.6 after the early socket demux was added.  It looks like the reason
> for the regression is that we are now having to perform two lookups, first
> the one for an established socket, and then the one for the routing table.
> 
> By adding this patch and toggling the value for ip_early_demux to 0 I am
> able to get back to the 12.1Mpps I was previously seeing.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

I applied this for now, making a minor change to move the local
variables down into the new basic block you created.

There has got to be a way to make this really cheap.  At the very
least we can have the GRO code store away the ports and therefore
allow us to just do a direct call to try and demux the socket.  Thus,
we'd avoid all of pskb_may_pull() et al. packet validations, and
packet header pointer calculations.

Furthermore, we can reduce to overhead by making a special inet
established hash demux that doesn't check for time-wait sockets,
reducing the number of probes to 1 from 2.
