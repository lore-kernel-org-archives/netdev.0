From: Alex Pankratov <ap@swapped.cc>
Subject: ENOBUFS and dev_queue_xmit()
Date: Mon, 14 Jun 2004 21:56:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CE818C.2090906@swapped.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been poking around rather weird problem today where send()
on UDP socket was failing with ENETDOWN. When traced down to
the kernel, it happened to originate in dev_queue_xmit() -

	if (!netif_queue_stopped(dev)) {
		...
	}
	...
	$here

meaning that the device's queue was stopped. The comment there
implies that only a broken virtual device may end up $here, but
the fact is that I saw it for a physical interface running
slightly modified via-rhine driver. The original driver code
contains a snippet that stops the queue if its Tx ring buffer
becomes full -

	if (np->cur_tx == np->dirty_tx + TX_QUEUE_LEN)
		netif_stop_queue(dev);

and this code got actually executed with a hack applied.

At this point I thought that dev_queue_xmit() must be mistakenly
returning ENETDOWN instead of ENOBUFS, but looking at 'man 2 send'
I saw that -

	ENOBUFS
         The output queue for a network interface was full...snip...
	(Normally,  this  does  not occur  in Linux. Packets are
	just silently dropped when a device queue overflows.)

Hmmm... so I looked at e100 and tulip and these both stop the queue
too if they run out of buffers. In other words, the 'silently dropped'
clause from man page does not seem to be consistently followed.

Is this a known (pseudo?) issue ? ENOBUFS makes much more sense
in this context. I can certainly check interface status (IFF_UP)
on every ENETDOWN to see what's the real cause, but that's kind
of ugly.

Alex
