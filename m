From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Wed, 9 Jun 2004 08:51:40 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406090851.40691.vkondra@mail.ru>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <20040608195238.GA21089@bougret.hpl.hp.com> <1086728139.1023.71.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1086728139.1023.71.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 08 June 2004 23:55, jamal wrote:
> On Tue, 2004-06-08 at 15:52, Jean Tourrilhes wrote:
> > On Tue, Jun 08, 2004 at 03:18:37PM -0400, jamal wrote:
> > > Prioritization is a subset of QoS. So if 802.11e talks prioritization,
> > > thats precisely what it means - QoS.
> >
> > 	Yes, it's one component of a QoS solution. But, my point is
> > that on it's own, it's not enough.
>
> There is no mapping or exclusivity of QoS to bandwidth reservation.
> The most basic QoS and most popular QoS mechanisms even on Linux is
> just prioritization and nothing to do with bandwidth allocation.
Correct. If you deal with bandwidth allocation, this is integrated service. 
Usually, diff serv used, which is just priority. BTW, in wireless QoS, 
bandwidth allocation present as well. Protocol is as follows: transmitter 
station should ask access point to establish new TSPEC (traffic 
specification), it get ID for this traffic, and then AP will poll station for 
this TSPEC, providing guranteed bandwidth, delay etc.
>
> > > The guy has some valid points in terms of multiple DMA rings if i
> > > understood him correctly. Theres current architectural deficiencies.
> >
> > 	I don't buy that. The multiple DMA ring is not the main thing
> > here, all DMA transfer share the same I/O bus to the card and share
> > the same memory pool, so there is no real performance gain there. The
> > I/O bnandwidth to the card is vastly superior to the medium bandwidth,
> > so the DMA process will never be a bottleneck.
>
> According to Vladimir the wireless piece of it is different.
> i.e each DMA ring will get different 802.11 channels
> with different backoff and contention window parameters.
> So nothing to do with the DMA process being a bottleneck.
>
> Help me understand this better:
> theres a wired side and a wireless side or are both send and receive
> interafacing to the air?
>
All on wireless.
> > The real benefit is that the contention on the medium is
> > prioritised (between contenting nodes). The contention process (CSMA,
> > backoff, and all the jazz) will give a preference to stations with
> > packet of the highest priority compared to stations wanting to send
> > packet of lower priorities. To gain advantage of that, you only need
> > to assign your packet the right priority at the driver level, and the
> > CSMA will send it appropriately.
>
> Yes, but how does the CSMA figure that? Is it not from the different
> DMA rings?
>
> > With respect to the 4 different hardware queue, you should see
> > them only as an extension of the netdev queues. Basically, you just
> > have a pipeline between the scheduler and the MAC which is almost a
> > FIFO, but not exactly a FIFO. Those queues may do packet reordering
> > between themselves, based on priorities. But at the end of the day
> > they are only going to send what the scheduler is feeding them, and
> > every packet the scheduler pass to those queues is eventually sent, so
> > they are totally slave to the scheduler.
>
> Is it a FIFO or there are several DMA rings involved? If the later:
> when do you stop the netdevice (i.e call netif_stop_queue())?
You hit the problem. Due to single queue, I can't provide separate back 
pressure for different access categories. What I do now, I do some internal 
buffering and netif_stop_queue() when total number of packets (or bytes) 
exceed some threshold. Of course, with watermarks to fight jitter.

Let's consider real example. Some application do FTP transfer, lots of data. 
Simultaneously, voice-over-IP connection invoked. Now question is: how to 
assure voice quality? Accordingly to TGe, voice is send either with high 
priority, or in TSPEC. If we will send all packets with high priority, we 
will hit ourselves. If we can't provide some back pressure for low priority 
traffic, it will block voice packets, since some moment you should 
netif_stop_queue().

Ideal would be if I can call netif_stop_queue(id), separately for each id.

I will send explanation for TGe in separate mail
