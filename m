From: Ben Greear <greearb@candelatech.com>
Subject: Re: inter-packet gap in pktgen
Date: Wed, 08 Dec 2004 11:32:14 -0800
Message-ID: <41B756BE.3050504@candelatech.com>
References: <20041207222522.GA30266@xi.wantstofly.org>	<41B632F3.1090104@candelatech.com>	<20041208073858.GA4027@xi.wantstofly.org> <16822.54722.755218.745451@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16822.54722.755218.745451@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Lennert Buytenhek writes:
>  > 
>  > Another option is:
>  > 
>  > 	next_tx = get_time_in_ns();
>  > 	while (--count) {
>  > 		tx_packet();
>  > 		next_tx += 1e9/intended_pps;
>  > 		nanospin(next_tx - get_time_in_ns());
>  > 	}
> 
>  Hello!
> 
>  I think this what Ben is doing with his userland app. Ev. adjusting
>  the ipg delay in runtime? A kind of control system. Even the device 
>  stats could possible be read.

Actually, I do return virtually the entire pktgen_interface_info
structure through an IOCTL call.  I do adjust the ipg often based on
what my control logic tells me I should do, 10 times a second I believe.

I found I needed external control because the control is fairly complex,
and I didn't want it in the kernel.  I also aim to allow X number of
interfaces to be used at once, and allow a mixture of different speeds.
The traffic on the interfaces affect each other..so I found the external
control useful again...

All that said, when we do calculate the 'next-tx' timer in the kernel,
there is no reason I see not to use the method above to get as accurate as
possible.

>  > This should be relatively independent of system load.  OK, I know,
>  > time to show some code.
>  
>  Also an idea might be to have some kind of option to use pktgen w. 
>  existent qdisc/tc infrastructure for this type of tests. Ben did
>  you try this?

Actually, yes.  My pktgen no longer busy-spins.  I probably add a bit
of jitter at a very low level, but over all system performance is much
better.  I use a callback from net_device.h to wake up the pktgen thread,
and I put it to sleep as soon as I have no more work to do, or I get
a hard-start-xmit error.  The netdev.h code looks like this:

@@ -474,9 +482,18 @@
  	void                    (*poll_controller)(struct net_device *dev);
  #endif

+        /* Callback for when the queue is woken, used by pktgen currently */
+        int			(*notify_queue_woken)(struct net_device *dev);
+        void* nqw_data; /* To be used by the method above as needed */
+
  	/* bridge stuff */
  	struct net_bridge_port	*br_port;





static inline void netif_wake_queue(struct net_device *dev)
{
#ifdef CONFIG_NETPOLL_TRAP
	if (netpoll_trap())
		return;
#endif
	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state)) {
		__netif_schedule(dev);

                 if (dev->notify_queue_woken) {
                    dev->notify_queue_woken(dev);
                 }
         }
}


pktgen registers with devices' notify_queue_woken hook.  For VLANs, I have some fairly complex
logic in pktgen so that it still registers with the 'real' device
since the VLAN won't have the netif_wake_queue called when the
real device drains it's fifo.

I'd be happy to have this included in the kernel, or be a basis for something
similar, so let me know if you'd like to see the full patch.  It is unlikely
that davem will allow my pktgen-rx code in as well, but the tx stuff might
still prove useful.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
