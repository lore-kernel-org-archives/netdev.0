From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Thu, 11 Nov 2010 18:56:24 +0900
Message-ID: <002501cb8186$b56a6280$66f8800a@maildom.okisemi.com>
References: <005301cb7ffa$5b63cd90$66f8800a@maildom.okisemi.com>
	<00fe01cb8009$62e11410$66f8800a@maildom.okisemi.com>
	<4CD945B4.4060408@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, November 09, 2010 9:59 PM, Marc Kleine-Budde wrote :

> 
> On 11/09/2010 01:26 PM, Tomoya MORINAGA wrote:
> >>>> Can you please explain me your locking sheme? If I understand the
> >>>> documenation correctly the two message interfaces can be used mutual.
> >>>> And you use one for rx the other one for tx.
> >>>
> >>> I show our locking scheme.
> >>> When CPU accesses MessageRAM via IF1, CPU protect until read-modify-write
> >>> so that IF2 access not occurred, vice versa.
> >>
> >> Why is that needed?
> >
> > For MessageRAM data consistency.
> 
> As far as I understand the datasheet the access to IF1 and IF2 is
> completely independent. Why do you lock here?

You are right.
Each IF1 and IF2 is completely independent.
All message objects can be accessed via both IF1 and IF2.
There is a possibility that a message object is accessed by IF1 and IF2 simultaneously.
But this driver separates message object by Tx/Rx completely.(Rx:1~26, Tx:27~32)
Thus, these locks are unnecessary.
I will delete these.

> 
> [...]
> 
> >>>> Please use just "debug" level not warning here. Consider to use
> >>>> netdev_dbg() instead. IMHO the __func__ can be dropped and the
> >>>> "official" name for the error is "Error Warning".
> >>>
> >>> I want to know the reason.
> >>> Why is it not dev_warn but netdev_dbg ?
> >>
> >> If you use warning level it would end up on the console or and in the
> >> syslog. It's quite complicated (for programs) to get information from
> >> there. This is why we send CAN error frames. They hold the same
> >> information but int a binary form, thus it's easier to process.
> >
> > I understand the reason.
> > BTW, Why do you say not dev_dbg but netdev_dbg ?
> 
> Sorry - netdev_dbg() is easier to use, its first argument is the
> netdevice, while dev_dbg needs a device and that's deeply hidden in the
> netdevice.
> 

I understand.


> [...]
> 
> >>>>> +static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
> >>>>> +{
> >>>>> + unsigned long flags;
> >>>>> + struct pch_can_priv *priv = netdev_priv(ndev);
> >>>>> + struct can_frame *cf = (struct can_frame *)skb->data;
> >>>>> + int tx_buffer_avail = 0;
> >>>>
> >>>> What I'm totally missing is the TX flow controll. Your driver has to
> >>>> ensure that the package leave the controller in the order that come
> >>>> into the xmit function. Further you have to stop your xmit queue if
> >>>> you're out of tx objects and reenable if you have a object free.
> >>>>
> >>>> Use netif_stop_queue() and netif_wake_queue() for this.
> >>>
> >>> In this code, I think "out of tx objects" cannot be  occurred.
> >>
> >> It's not a matter of code it's the hardware. You cannot put more than a
> >> certain number of CAN frames into the hardware. If you have a CAN bus at
> >> a certain speed, you can only send a certain number of CAN frames in a
> >> second. So you cannot push more than this amount of frames/s into the
> >> hardware.
> >>
> >>> Nevertheless, are netif_stop_queue() and netif_wake_queue() is necessary ?
> >>
> >> Yes.
> >
> > I can' understand your issue.
> > Please can you hear my opinion?
> >
> > Please see the head of pch_xmit.
> >
> >>> + if (priv->tx_obj == (PCH_OBJ_NUM + 1)) { /* Point tail Obj + 1 */
> >>> +  while (ioread32(&priv->regs->treq2) & 0xfc00)
> >>> +   udelay(1);
> >
> > When points tail of Tx message object,
> > this driver waits until completion of all tx messaeg objects.
> 
> Looping busy it not an option here.
> 
> > Thus, application/driver ought not to be able to put Tx object exceed the number of tx message object.
> > Thus I think these code(netif_stop_queue/netif_wake_queue) are completely redundant.
> 
> Nope - please remove the waiting completely and convert your flow
> control to netif_stop_queue/netif_wake_queue.
> 

I see.
I will remove like above.

BTW, Let me know the reason.
Could you explain the reason why you deny looping busy loop ?


Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
