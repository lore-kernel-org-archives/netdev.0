From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH 6/7] can: m_can: update to support CAN FD features
Date: Tue, 4 Nov 2014 15:12:08 +0800
Message-ID: <20141104071146.GA17367@shlinux1.ap.freescale.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
 <1414579527-31100-6-git-send-email-b29396@freescale.com>
 <54513E38.4020703@hartkopp.net>
 <20141030024226.GA29572@shlinux1.ap.freescale.net>
 <5452A071.2000307@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, varkabhadram@gmail.com, linux-can@vger.kernel.org,
 mkl@pengutronix.de, wg@grandegger.com, linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <5452A071.2000307@hartkopp.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 30, 2014 at 09:32:49PM +0100, Oliver Hartkopp wrote:
> 
> On 10/30/2014 03:42 AM, Dong Aisheng wrote:
> > On Wed, Oct 29, 2014 at 08:21:28PM +0100, Oliver Hartkopp wrote:
> 
> >> So first I would suggest to check the core release register (CREL) to be
> >> version 3.0.x and quit the driver initialization if it doesn't fit this
> >> version. I would suggest to provide a separate patch for that check. What
> >> about printing the core release version into the kernel log at driver
> >> initialization time?
> >>
> > 
> > One question is that if v3.1.0 and v3.2.0 will be backward compatible with
> > v3.0.1, if yes, how about let the driver still work for them instead of
> > simply quit?
> 
> There are several important differences between 3.0.x and 3.1.x.
> E.g. the CCCR, BTP, PSR and others are changed and a register for the
> transmitter delay compensation is added.
> 
> I assume from 3.1.x to 3.2.x the controller registers will only change in
> small details as the main update will be on the wire and not in the functionality.
> 
> > And then we can add new features according new released IP version.
> 
> Yes. We probably can wait for 3.[12].x to become available before adding the
> special code that behaves according the core release register content.
> 

Okay

> >>> @@ -375,7 +414,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
> >>>  		if (rxfs & RXFS_RFL)
> >>>  			netdev_warn(dev, "Rx FIFO 0 Message Lost\n");
> >>>  
> >>> -		skb = alloc_can_skb(dev, &frame);
> >>> +		skb = alloc_canfd_skb(dev, &frame);
> >>
> >> You are *always* allocating CAN FD frames now?
> >>
> > 
> > Yes, currently it is.
> > The test seemed ok using CAN FD frames even receive normal frame.
> 
> When you put CAN frame content into a CAN FD skb it becomes a CAN FD frame -
> which is wrong.
> 
> CAN 2.0 frame (EDL is clear) -> alloc_can_skb()
> CAN FD frame (EDL is set) -> alloc_canfd_skb()
> 
> You can have a CAN FD frame with a DLC of 8, which does *not* mean that you
> have a CAN 2.0 frame.
> 
> > The issue i know is that candump seemed can not recognize remote frame reported
> > by the driver.
> 
> Do you use the latest candump from
> 

Yes, i'm using latest candump.

> 	https://gitorious.org/linux-can/can-utils/
> ??
> 
> The latest candump switches the CAN_RAW socket into the mode to accept both
> CAN *and* CAN FD frames and displays the frames correctly.
> 
> > Not sure if it's caused by canfd_frame used.
> 
> Yes. CAN FD frames do not have a RTR bit.
> 

You're right.
It's indeed caused by using the CAN FD frames to receive RTR frame.
After switch to normal frame, candump showed it well.

> > Will test and check.
> > 
> >> Depending on RX_BUF_EDL in the RX FIFO message you should create a CAN or CAN
> >> FD frame.
> >>
> >> Of course you can use the struct canfd_frame in m_can_read_fifo() as the
> >> layout of the struct can_frame is identical when filled with 'normal' CAN
> >> frame content.
> >>
> >> But you need to distinguish whether it is a CAN or CAN FD frame when
> >> allocating the skb based on the RX_BUF_EDL value.
> >>
> > 
> > Yes, i think it's good to do that.
> > One obvious benefit is it saves memory at least.
> 
> The main point is that CAN frames and CAN FD frames are separated by this
> (MTU) length information. It's not about saving memory.
> A CAN FD frame with DLC 8 still has 64 data bytes inside it's data structure.
> 

For normal can frame, the CAN_MAX_DLEN is 8 while CANFD_MAX_DLEN is 64.
So i meant using struct canfd_frame to receive normal frame is a bit waste memory.
And besides, actually it's wrong as you already indicated.
I will send out the updated patch with this changed in v2 soon.
Thanks for pointing out this.

Regards
Dong Aisheng

> Regards,
> Oliver
