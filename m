From: Matt Mackall <mpm@selenic.com>
Subject: Re: Problem with Netpoll based netdumping and NAPI
Date: Mon, 19 Apr 2004 12:42:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419174254.GQ1175@waste.org>
References: <20040419125148.GA4495@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, mingo@elte.hu,
        suparna@in.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hariprasad Nellitheertha <hari@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040419125148.GA4495@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[changed cc: from linux-net to netdev]

On Mon, Apr 19, 2004 at 06:21:48PM +0530, Hariprasad Nellitheertha wrote:
> Hi All,
> 
> I am facing a problem while trying to network dump using LKCD. My 
> debugging so far indicates that this is due to both NAPI and NETPOLL 
> being enabled.
> 
> I am using LKCD on the 2.6.5 kernel and both the client and server are 
> i386 boxes. The dumping machine has an e100 card. I have built the kernel
> with both CONFIG_E100_NAPI and CONFIG_NET_POLL_CONTROLLER (and the other
> netpoll related options) selected.
> 
> LKCD uses netpoll for its network dump implementation. The problem we see
> is that the network dump driver does not receive any packet from the 
> card driver and hence dumping fails. In e100_intr(), we call 
> netif_rx_schedule() if we are using the NAPI feature. netif_rx_schedule, 
> in turn, ends up adding the processing of this packet to the NET_RX_SOFTIRQ 
> softirq.

Netpoll should be manually calling the NAPI poll function like this 
after calling the interrupt handler (in netpoll_poll()):

      /* If scheduling is stopped, tickle NAPI bits */
         if(trapped && np->dev->poll &&
            test_bit(__LINK_STATE_RX_SCHED, &np->dev->state))
                 np->dev->poll(np->dev, &budget);

Please ensure that LKCD is calling netpoll_set_trap(1) which tells it
that packet scheduling is stopped.

I've tested this path primarily with tg3 and kgdb-over-ethernet, but
it should be functionally quite similar to e100 and lkcd.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
