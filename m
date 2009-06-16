From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: flow director and packet ordering
Date: Mon, 15 Jun 2009 23:42:16 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0906152327070.7160@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090615.020738.243788769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25621 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816AbZFPGm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 02:42:29 -0400
In-Reply-To: <20090615.020738.243788769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2009, David Miller wrote:

> 
> Does the flow director implementation in IXGBE make sure to preserve
> packet ordering in some way?
> 
> You can't just change the RX flow destination queue whenever you like.
> 
> For example, if a transmit happens on cpu 1, then we start to receive
> some packets for that flow on that cpu, will a sudden set of transmits
> on another cpu make the flow director quickly switch the RX
> destination?

Not by design, no.  The mode of Flow Director that is currently in the 
driver is the hashing mode.  82599 also supports a perfect match mode, 
which isn't supported yet, since there's no good interface to program the 
5-tuple filters (I've been watching the ethtool work from the Sun guys for 
niu, but haven't had time to help).

Back to the hashing mode.  The idea is that a particular flow, say on CPU 
1, will be hashed.  There are two layers of hashing; the first 
will land the flow into a bucket, the second will land it into the 
filter lists.  The two hash values for the Tx packet are then written 
to the filter table along with the Rx queue.  There are two ways that the 
Rx queue for that flow could be moved: 1) The flow itself moves from CPU 1
to a different CPU.  This is the most likely case that will move the Rx 
flow.  2) We have a double collision on the hashes.  This really isn't 
very likely that a different flow will collide on both hashed values.

The reason we have two levels of hashing is to try and avoid this possible 
situation of a collision accidentally moving a different flow.

> 
> That would be very bad.

Agreed.

> 
> Without some extreme care that will result in potential packet
> reordering.
> 
> There needs to be some safey net in place in your silicon to wait for
> a significant "quiet time" in the RX stream before you can revector
> the RX flow destination setting.  Enough time to let the stack process
> all that packets for that flow received on the currently bound flow
> CPU.

The current Rx DMA's that have been posted must be completed before our 
hardware will apply the changes to the Rx filters.

> 
> To be honest, I'm not optimistic about this situation :-/

The way the internal hashing works in the software and hardware, I think 
we're pretty safe with getting moved unexpectedely.

Cheers,
-PJ Waskiewicz
