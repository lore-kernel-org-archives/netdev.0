From: Andi Kleen <ak@suse.de>
Subject: Re: RFR: new SiS gige driver
Date: Sat, 9 Aug 2003 17:27:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809152747.GA1618@wotan.suse.de>
References: <20030808173932.GA4077@gtf.org> <20030809141533.GB4539@wotan.suse.de> <3F350CC8.3090605@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F350CC8.3090605@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 09, 2003 at 11:01:28AM -0400, Jeff Garzik wrote:
> Andi Kleen wrote:
> >* netif_stop_queue in hard_start_xmit is not protected against the 
> >interrupt by the spinlock. That's racy, isn't it?
> 
> Shouldn't be, if done right.  If the interrupt runs a TX completion 
> cycle, it will run the code
> 	if (work_done && netif_queue_stopped(dev))
> 		netif_wake_queue(dev)
> 
> Since ->hard_start_xmit is guaranteed never to be called if the queue is 
> stopped, you also guaranteed that netif_wake_queue and ->hard_start_xmit 
> are mutually exclusive.

The race is

	CPU0                      CPU1

 	hard_start_xmit          
	release lock
                              TX finished interrupt

	my queue is full...       
                              clean some packets
							  netif_wake_queue

	netif_stop_queue


The netif_wake_queue is lost. It's only deadly when clean some packets
clears the full TX ring, otherwise it will likely recover with the 
next TX finished interrupt but give suboptimal performance.

Fix is to do the my queue is full -> netif_stop_queue inside the spinlock.

-Andi
