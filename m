From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 7 Sep 2012 14:01:23 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5741E@EXDCVYMBSTM006.EQ1STM.local>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
 <1676538.CEPj2RtrPe@linux-lqwf.site>
 <CACVXFVM9OdUbmOFvf1KG4ePoz7wCxLRwCET3cgL=EynNBLx2AA@mail.gmail.com>
 <1446113.XC2Qbo4flT@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446113.XC2Qbo4flT-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum-l3A5Bk7waGM@public.gmane.org]
> Sent: Friday, September 07, 2012 9:36 AM

> > > Well, that is the mistake. Using a timer is a bad idea.
> >
> > Why is a bad idea?  Without a timer, how can usbnet or low level
> > driver aggregate the later coming transmit frames to form a biger
> > aggregated frame?
> 
> By registering demand in an abstract sense. The timer makes sense only
> when no other buffers are being transfered.
> 
> The timer means that we transmit if no other more packages are coming
> down from the upper layers. Now, either the device is still busy or it
> is not.
> While it is busy, we might just as well wait, because the upper layer
> may change its mind.
> If the device is not busy we worsen latency by waiting for the timer.

...

> > As I said above, without a timeout timer, the queued skb might not be
> > sent out even some long time passed if no frame comes later.
> 
> Therefore we check whether the device is still busy.
> 

The purpose of NCM is to reduce the amount of interrupts and the number
of DMA jobs that must be handled by the device. It is most efficient to
send and especially to receive NTBs of agreed size, padded if needed.

Misunderstanding of the reason why NCM protocol is doing aggregation
of several ETH frames into a single NTB leads to crippled implementation. 
Look at NCM gadget, which is not really NCM device at all, it's kinda ECM
device with NCM framing.

The experience from early implementations and prototyping of NCM was that
using NCM with 4-8kB NTB increased max throughput in loop-mode by a factor
of 5-6 even 8-10 times compared to using ECM. One real-world example was
modem for 21+6Mbit/s what used 100% CPU with ECM responsible for approx. 40%
of the MIPS used. Using NCM instead CPU was only at approx. 65% utilization.
Which allowed multiple other functions to be added and significantly increased
the usability and value of the modem.

NCM efficiency is gained either by accessing TX queue of upper layer or
by using timer. 

These findings were later confirmed by multiple major industry players
(names withheld), and demonstrated during multiple NCM interoperability
workshops using multiple device HW platforms, multiple operating systems
and multiple host HW ranging from Beagleboard to latest quad-core x86.    

Until we do something with network device framework in order to get access
to upper layer Tx queue we need to utilize timer.

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
