From: jamal <hadi@cyberus.ca>
Subject: Re: ENOBUFS and dev_queue_xmit()
Date: 15 Jun 2004 08:54:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087304060.1043.72.camel@jzny.localdomain>
References: <40CE818C.2090906@swapped.cc>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Pankratov <ap@swapped.cc>
In-Reply-To: <40CE818C.2090906@swapped.cc>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-06-15 at 00:56, Alex Pankratov wrote:
> I've been poking around rather weird problem today where send()
> on UDP socket was failing with ENETDOWN. When traced down to
> the kernel, it happened to originate in dev_queue_xmit() -
> 
> 	if (!netif_queue_stopped(dev)) {
> 		...
> 	}
> 	...
> 	$here
> 
> meaning that the device's queue was stopped. The comment there
> implies that only a broken virtual device may end up $here,

How did you end up there with a real phy device?? Are you trying to
circumvent the qdisc subsystem? If yes, you are responsible for how
all this gets handled.
 
>  but
> the fact is that I saw it for a physical interface running
> slightly modified via-rhine driver. The original driver code
> contains a snippet that stops the queue if its Tx ring buffer
> becomes full -
> 
> 	if (np->cur_tx == np->dirty_tx + TX_QUEUE_LEN)
> 		netif_stop_queue(dev);
> 
> and this code got actually executed with a hack applied.

> At this point I thought that dev_queue_xmit() must be mistakenly
> returning ENETDOWN instead of ENOBUFS, but looking at 'man 2 send'
> I saw that -
> 
> 	ENOBUFS
>          The output queue for a network interface was full...snip...
> 	(Normally,  this  does  not occur  in Linux. Packets are
> 	just silently dropped when a device queue overflows.)
> 
> Hmmm... so I looked at e100 and tulip and these both stop the queue
> too if they run out of buffers. In other words, the 'silently dropped'
> clause from man page does not seem to be consistently followed.
>
> Is this a known (pseudo?) issue ? ENOBUFS makes much more sense
> in this context. I can certainly check interface status (IFF_UP)
> on every ENETDOWN to see what's the real cause, but that's kind
> of ugly.

Did you mean when no space is left in the ring? Thats different
from ENOBUFF. If not, not sure i see how a driver xmit path gets
involved in kmallocing.
Look at the return code the driver returns. In case of a full ring, it
should return a busy signal and the top layer will retry later.
You dont have to worry about any of that if you are running the 
std linux semantics, of course. I have a feeling you have attempted to
bypass it otherwise the question becomes: how you even ended in this
situation. 

cheers,
jamal
