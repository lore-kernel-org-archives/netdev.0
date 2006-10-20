From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 23:01:29 +0200
Message-ID: <200610202301.29859.ak@suse.de>
References: <20061019171814.281988608@osdl.org> <20061020.134209.85688168.davem@davemloft.net> <20061020134826.75dd1cba@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:59564 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1946488AbWJTVBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:01:40 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061020134826.75dd1cba@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> But, it also violates the assumptions of the network devices.
> It calls NAPI poll back with IRQ's disabled and potentially doesn't
> obey the semantics about only running on the same CPU as the
> received packet.

netpoll always played a little fast'n'lose with various locking rules.
Also often inside the drivers are a little sloppy in the poll path.

That's fine for getting an oops out, but risky for normal kernel
messages when the driver must be still working afterwards.

The standard console code makes this conditional on oops_in_progress -
it breaks locks when true and otherwise it follows the safe
approach.

Perhaps it would be better to use different paths in netconsole too 
depending  on whether oops_in_progress is true or not.  

e.g. if !oops_in_progress (use the standard output path)
else use current path.

That would avoid breaking the driver during normal operation
and also have the advantage that the normal netconsole messages
would go through the queueing disciplines etc.

-Andi
