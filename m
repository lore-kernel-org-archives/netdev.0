From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI interrupt data
Date: Sat, 15 Feb 2003 17:14:53 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030215164516.C16812@shell.cyberus.ca>
References: <3E4DE95C.2050804@pobox.com> <20030215092908.E16812@shell.cyberus.ca>
 <3E4E8D32.6090706@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3E4E8D32.6090706@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 15 Feb 2003, Jeff Garzik wrote:

> jamal wrote:
> >
> > On Sat, 15 Feb 2003, Jeff Garzik wrote:
> >
> >
> > Probably the first 5-10 samples as well as the last 5-10 amples to get
> > more accuracy.
> >

I actually meant to say ignore those first 5-10 and last 5-10 samples --
looking at your data that wouldnt have made a big difference.

> > This data looks fine, no?
>
> Over 4000 interrupts per second was not something I was hoping for, to
> be honest.  ttcp did not even report 50% CPU utilization, so I reach the
> conclusion that both machines can handle well in excess of 4,000
> interrupts per second...  but overall I do not like the unbounded nature
> of the interrupt rate.  This data makes me lean towards a software[NAPI]
> + hardware mitigation solution, as opposed to totally depending on
> software interrupt mitigation.
>

Well, it is not "unbounded" perse.
It scales according to the CPU capacity. For any CPU there is an upper
limit input rate where the device would forever remain in polling mode.
If this limit is exceeded say on bootup, and a million packets are
received in a burst then youll probably see only one interupt for the
million packets. If you remove that processor and add a faster in the
same motherboard you should see more interupts than one being processed.
Therefore there is an upper bound interupt rate and it is dependent on
the CPU capacity (not to ignore other factors like PCI bus speed, memory
bandwidth etc; cpu capacity plays a much bigger role though)

Mitigation is valuable when the cost of PCI IO per packet is something
that is bothersome. It becomes bothersome if the rate of input packets is
such that you end up processing one packet per interupt; as you
yourself have pointed out in the past, the cost of PCI IO per packet is
high with NAPI.
Of course cost of PCI IO per packet is demonstrated in CPU load observed. On
slow CPUs this is clearly observed; Manfreds results for example
demonstrated this. I also saw upto 8% CPU more with NAPI on 10kpps input
rate. On a fast CPU that will probably show up as 0.5% more load (so the
question is who cares?).
What mitigation would do in the above case is amortize the cost of
PCI-IO per packet. Instead of one packet, for the same PCI cost now its 2
etc.
Mitigation becomes useless on higher input rates.
In summary: Adding mitigation helps in the low rate case and doesnt harm
in the high input case.

BTW 4k interupts/sec is a very small rate.
Try sending 5 or 6 ttcp flows instead of one and observe.

>
>  > definetly the scsi device is skewing things
> > (you are writting data to disk for example).
>
> Yes, though only once 5 seconds when ext3 flushes.  With nothing else
> going on but "ttcp" and "cat /proc/interrupts >> data ; sleep 1" there
> should be very little disk I/O.  I agree it is skewing by an unknown
> factor, however.
>

theres not that many interupts, so nothing to worry about there.
Of course if you want cleaner results dont share interupts or collect
the data from the driver instead.

>
> > - The 500Kpps from ttcp doesnt sound right; tcp will slow you down.
> > perhaps use ttcp to send udp packets to get a more interesting view.
>
>
> No, I ran 500,000 buffer I/Os total from ttcp ("-n 500000").  That
> doesn't really say anything about packets per second.  The only thing I
> measured was interrupts per second.  It was my mistake to type "packets"
> in the first email :/
>

hit it with 10 ttcps instead or send 2 or so udp ttcp flows. It starts
getting interesting then ..

cheers,
jamal
