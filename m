From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Thu, 30 Oct 2008 11:21:22 -0700
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA85A83@NASANEXMB10.na.qualcomm.com>
References: <1225371622.5322.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:53386 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758464AbYJ3Saq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 14:30:46 -0400
In-Reply-To: <1225371622.5322.18.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Johann,

There's no need to keep the index (packet_index).  Just store the pointer directly (change it to void *) - saves an extra lookup.  Also, I don't think setting TP_STATUS_COPY is necessary since the user can't really do anything with that information.  Simply leave it at TP_STATUS_USER & TP_STATUS_KERNEL.

Also, when you set the status back to TP_STATUS_KERNEL in the destructor, you need
 to add the following barriers:

__packet_set_status(po, ph, TP_STATUS_KERNEL);
smp_mb();   // make sure the TP_STATUS_KERNEL was actually written to memory before this - couldn't this actually be just a smp_wmb?
flush_dcache_page(virt_to_page(ph));  // on non-x86 architectures like ARM that have a moronic cache (i.e cache by virtual rather than physical address). on x86 this is a noop.

Also, I think that I looked at your code while working on my version and there may have been some logical problems with the way you're building packets.  I'll compare it within the next few days as I start cleaning up my code.

The atomic_inc of pending_skb should happen after the skb was allocated - the atomic_dec in out_status can also be removed.  out_status can be removed completely if you get rid of TP_STATUS_COPY.  If you leave it, you still need the barriers as above after changing tp_status, or the user may not see the change.  Also, you've got a potential threading issue - you're not protecting the frame index behind the spinlock.

As a benchmark on a 10G card (and not performing any optimizations like using syspart & dedicating a cpu for tx), I was able to hit 8.6 GBits/s using a dedicated kernel thread for the transmission.  With the dedicated CPU, I'm confident the line-rate will go up significantly

.I'll try to test your changes within the next few days.  TCPdump maxes out at around 1.5 GBits/s

As for CPU usage, there's a noticeable advantage to traditional send.  Using tcpreplay  - there's about 80% CPU utilization when sending.  Using the tx ring, there's maybe 10-15%.

I'm going to have latency numbers soon as well (i.e. how much jitter is introduced by the kernel).

Vitali