From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Requeues
Date: Sat, 03 Mar 2012 05:13:57 -0500
Message-ID: <1330769637.4671.193.camel@denise.theartistscloset.com>
References: <1330753728.4671.190.camel@denise.theartistscloset.com>
	 <4F51C01C.3040208@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:57957 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948Ab2CCKOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 05:14:02 -0500
In-Reply-To: <4F51C01C.3040208@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-02 at 22:54 -0800, John Fastabend wrote:
> On 3/2/2012 9:48 PM, John A. Sullivan III wrote:
> > Hello, all.  I am seeing a small but significant number of requeues on
> > our pfifo_fast qdiscs.  I've not been able to find much on what this
> > means but the little I have implies it may be a problem with the
> > physical interfaces.  However, these are fairly high end systems with
> > Intel e1000 quad port cards.
> > 
> > We thought it might have something to do with the bonded interfaces so
> > we checked some other high end systems without bonded interfaces but the
> > same quad port cards and, lo and behold, the same small but significant
> > number of requeues.
> > 
> > Is this normal or does it indicate a problem somewhere? Thanks - John
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> One of two things can happen to cause the requeue counter to increment.
> 
> When the qdisc dequeues a packet it then gets enqueued in yet another
> queue in the e1000 driver. If the qdisc is dequeueing packets faster
> than the hardware can consume them the driver will return a
> NETDEV_TX_BUSY error. This causes the qdisc to 'requeue' the packet and
> in the process increments this counter. 
> 
> The gist is pfifo_fast dequeued a packet tried to give it to e1000 which
> pushed back so pfifo_fast put the packet back on the queue.
> 
> By the way you can tune the size of the e1000 queues manually by playing
> with:
> 
> 	/sys/class/net/ethx/tx_queue_len
> 
> But you likely don't want to make them any larger else you'll hit the
> buffer bloat problem. I'm guessing we should add byte queue limit support
> here.
> 
> The second way to trigger this is multiple cpus contending for a lock.
> 
> In short requeue counts as long as its not excessive are just part 
> of normal operation. So shouldn't be a problem.
<snip>
Thank you very much.  I was not aware of CPU contention being a cause.
We did notice the problem primarily on systems with 8 to 16 cores - John
