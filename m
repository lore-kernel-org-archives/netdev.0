From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: about latencies
Date: Thu, 23 Apr 2009 15:34:42 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>
References: <49F0E579.5030200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Lameter <cl@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40060 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbZDWWeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 18:34:46 -0400
In-Reply-To: <49F0E579.5030200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Apr 2009, Eric Dumazet wrote:
> Some time later, NIC tells us TX was completed.
> We free skb().
>  1) dst_release()   (might dirty one cache line, that was increased by application cpu)
> 
>  2) and more important... since UDP is now doing memory accounting...
> 
> sock_wfree()
>   -> sock_def_write_space()
>      -> _read_lock()
>      -> __wake_up_sync_key()
>   and lot of functions calls to wakeup the task, for nothing since it
> will just schedule again. Lot of cache lines dirtied...
> 
> 
> We could improve this.
> 
> 1) dst_release at xmit time, should save a cache line ping-pong on general case
> 2) sock_wfree() in advance, done at transmit time (generally the thread/cpu doing the send)

how much does the effect socket accounting?  will the app then fill the 
hardware tx ring all the time because there is no application throttling 
due to delayed kfree?

> 3) changing bnx2_poll_work() to first call bnx2_rx_int(), then bnx2_tx_int() to consume tx.

at least all of the intel drivers that have a single vector (function) 
handling interrupts, always call tx clean first so that any tx buffers are 
free to be used immediately because the NAPI calls can generate tx traffic 
(acks in the case of tcp and full routed packet transmits in the case of 
forwarding)

of course in the case of MSI-X (igb/ixgbe) most times the tx cleanup is 
handled independently (completely async) of rx.


> 
> What do you think ?

you're running a latency sensitive test on a NOHZ kernel below, isn't that 
a bad idea?

OT - the amount of timer code (*ns*) and spinlocks noted below seems 
generally disturbing.

> function ftrace of one "tx completion, extra wakeup, incoming udp, outgoing udp"

thanks for posting this, very interesting to see the flow of calls.  A ton 
of work is done to handle just two packets.
 
might also be interesting to see what happens (how much shorter the call 
chain is) on a UP kernel.
