From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 09 Jun 2004 07:20:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086780010.1051.106.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <20040608195238.GA21089@bougret.hpl.hp.com>
	 <1086728139.1023.71.camel@jzny.localdomain>
	 <200406090851.40691.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406090851.40691.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-09 at 01:51, Vladimir Kondratiev wrote:

> > Is it a FIFO or there are several DMA rings involved? If the later:
> > when do you stop the netdevice (i.e call netif_stop_queue())?
>
> You hit the problem. 

Sorry, I should have made it clear and reemphasized it a few times. I
think Jean understands the issue but not its repurcassions.

> Due to single queue, I can't provide separate back 
> pressure for different access categories. What I do now, I do some internal 
> buffering and netif_stop_queue() when total number of packets (or bytes) 
> exceed some threshold. Of course, with watermarks to fight jitter.

Will work fine if you have mostly only one priority really. 

> Let's consider real example. Some application do FTP transfer, lots of data. 
> Simultaneously, voice-over-IP connection invoked. Now question is: how to 
> assure voice quality? 

Non-trivial with current setup. 

> Accordingly to TGe, voice is send either with high 
> priority, or in TSPEC. If we will send all packets with high priority, we 
> will hit ourselves. If we can't provide some back pressure for low priority 
> traffic, it will block voice packets, since some moment you should 
> netif_stop_queue().
> 
> Ideal would be if I can call netif_stop_queue(id), separately for each id.

Indeed. 
Looking at the transmit path code it seems doable.
for each dev->id you also maintain a dev->id_state.
We either use skb->fwmark or skb->priority to map to the different
dev->ids.
The major challenge would be how to start the different queues once they
are stopped. I suspect there is only tx completed interupt; i take it
you can tell when each of the FIFOs is ready to swallow more packets?

cheers,
jamal
