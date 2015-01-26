From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Mon, 26 Jan 2015 10:21:34 +0000
Message-ID: <20150126102134.16360.18418@shannon>
References: <20150120214409.GA16828@linux>
 <20150121103319.14511.57709@shannon>
 <e5439ed067931dc01bda70592eb6ed52@grandegger.com>
 <20150121144323.GA17070@linux> <20150121150015.31351.6605@shannon>
 <20150121153647.GB17070@linux>
 <49707d45a389a1acb9ccec4295d05762@grandegger.com>
 <20150123060734.GA7949@Darwish.PC> <20150123103213.6205.54618@shannon>
 <20150125024300.GA6028@Darwish.PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150125024300.GA6028@Darwish.PC>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Ahmed S. Darwish (2015-01-25 02:43:00)
> On Fri, Jan 23, 2015 at 10:32:13AM +0000, Andri Yngvason wrote:
> > Quoting Ahmed S. Darwish (2015-01-23 06:07:34)
> > > On Wed, Jan 21, 2015 at 05:13:45PM +0100, Wolfgang Grandegger wrote:
> > > > On Wed, 21 Jan 2015 10:36:47 -0500, "Ahmed S. Darwish"
> > > > <darwish.07@gmail.com> wrote:
> > > > > On Wed, Jan 21, 2015 at 03:00:15PM +0000, Andri Yngvason wrote:
> > > > >> Quoting Ahmed S. Darwish (2015-01-21 14:43:23)
> > > > >> > Hi!
> > > > > 
> > > > > ...
> > > > > 
> > > > >> > <-- Unplug the cable -->
> > > > >> > 
> > > > >> >  (000.009106)  can0  20000080   [8]  00 00 00 00 00 00 08 00  
> > > > >> >  ERRORFRAME
> > > > >> >         bus-error
> > > > >> >         error-counter-tx-rx{{8}{0}}
> > > > >> >  (000.001872)  can0  20000080   [8]  00 00 00 00 00 00 10 00  
> > > > 
> > > > For a bus-errors I would also expcect some more information in the
> > > > data[2..3] fields. But these are always zero.
> > > > 
> > > 
> > > M16C error factors made it possible to report things like
> > > CAN_ERR_PROT_FORM/STUFF/BIT0/BIT1/TX in data[2], and
> > > CAN_ERR_PROT_LOC_ACK/CRC_DEL in data[3].
> > > 
> > > Unfortunately such error factors are only reported in Leaf, but
> > > not in USBCan-II due to the wire format change in the error event:
> > > 
> > >         struct leaf_msg_error_event {
> > >                 u8 tid;
> > >                 u8 flags;
> > >                 __le16 time[3];
> > >                 u8 channel;
> > >                 u8 padding;
> > >                 u8 tx_errors_count;
> > >                 u8 rx_errors_count;
> > >                 u8 status;
> > >                 u8 error_factor;
> > >         } __packed;
> > > 
> > >         struct usbcan_msg_error_event {
> > >                 u8 tid;
> > >                 u8 padding;
> > >                 u8 tx_errors_count_ch0;
> > >                 u8 rx_errors_count_ch0;
> > >                 u8 tx_errors_count_ch1;
> > >                 u8 rx_errors_count_ch1;
> > >                 u8 status_ch0;
> > >                 u8 status_ch1;
> > >                 __le16 time;
> > >         } __packed;
> > > 
> > > I speculate that the wire format was changed due to controller
> > > bugs in the USBCan-II, which was slightly mentioned in their
> > > data sheets here:
> > > 
> > >         http://www.kvaser.com/canlib-webhelp/page_hardware_specific_can_controllers.html
> > > 
> > > So it seems there's really no way for filling such bus error
> > > info given the very limited amount of data exported :-(
> > >
> > We experienced similar problems with FlexCAN.
> 
> Hmm, I'll have a look there then...
> 
> Although my initial instincts imply that the FlexCAN driver has
> access to the raw CAN registers, something I'm unable to do here.
> But maybe there's some black magic I'm missing :-)
>
Yes, it's memory mapped.
> 
> [...]
> 
> > > 
> > > I've dumped _every_ message I receive from the firmware while
> > > disconnecting the CAN bus, waiting a while, and connecting it again.
> > > I really received _nothing_ from the firmware when the CAN bus was
> > > reconnected and the data packets were flowing again. Not even a
> > > single CHIP_STATE_EVENT, even after waiting for a long time.
> > > 
> > > So it's basically:
> > > ...
> > > ERR EVENT, txerr=128, rxerr=0
> > > ERR EVENT, txerr=128, rxerr=0
> > > ERR EVENT, txerr=128, rxerr=0
> > > ...
> > > 
> > > then complete silence, except the data frames. I've even tried with
> > > different versions of the firmware, but the same behaviour persisted.
> > > 
> > > > > So, What can the driver do given the above?
> > > > 
> > > > Little if the notification does not come.
> > > > 
> > > 
> > > We can poll the state by sending CMD_GET_CHIP_STATE to the firmware,
> > > and it will hopefully reply with a CHIP_STATE_EVENT response
> > > containing the new txerr and rxerr values that we can use for
> > > reverse state transitions.
> > >
> > > But do we _really_ want to go through the path? I feel that it will
> > > open some cans of worms w.r.t. concurrent access to both the netdev
> > > and USB stacks from a single driver.
> > >
> > Honestly, I don't know.
> > >
> > > A possible solution can be setting up a kernel thread that queries
> > > for a CHIP_STATE_EVENT every second?
> > > 
> > Have you considered polling in kvaser_usb_tx_acknowledge? You could do something
> > like:
> > if(unlikely(dev->can.state != CAN_STATE_ERROR_ACTIVE))
> > {
> >     request_state();
> > }
> > 
> 
> OK, I have four important updates on this issue:
> 
> a) My initial testing was done on high-speed channel, at a bitrate
>    of 50K. After setting the bus to a more reasonable bitrate 500K
>    or 1M, I was _consistently_ able to receive CHIP_STATE_EVENTs
>    when plugging the CAN connector again after an unplug.
> 
> b) The error counters on this device do not get reset on plugging
>    after an unplug. I've setup a kernel thread [2] that queries
>    the chip state event every second, and the error counters stays
>    the same all the time. [1]
> 
> c) There's a single case when the erro counters do indeed get
>    reversed, and it happens only when introducing some noise in
>    the bus after the re-plug. In that case, the new error events
>    get raised with new error counters starting from 0/1 again.
> 
> d) I've discovered a bug that forbids the CAN state from
>    returning to ERROR_ACTIVE in case of the error counters
>    numbers getting decreased. But independent from that bug, the
>    verbose debugging messages clearly imply that we only get the
>    error counters decreased in the case mentioned at `c)' above.
> 
> So from [1] and [2], it's now clear that the device do not reset
> these counters back in the re-plug case. I'll give a check to
> flexcan as advised, but unfortunately I don't really think there's
> much I can do about this.
> 
> [1]
> 
> [  877.207082] CAN_ERROR_: channel=0, txerr=88, rxerr=0
> [  877.207090] CAN_ERROR_: channel=0, txerr=136, rxerr=0
> [  877.207094] CAN_ERROR_: channel=0, txerr=144, rxerr=0
> [  877.207098] CAN_ERROR_: channel=0, txerr=152, rxerr=0
> [  877.207100] CAN_ERROR_: channel=0, txerr=160, rxerr=0
> [  877.207102] CAN_ERROR_: channel=0, txerr=168, rxerr=0
> [  877.208075] CAN_ERROR_: channel=0, txerr=200, rxerr=0 
> 
> (( The above error event, staying the same at txerr=200 keeps
>    flooding the bus until the CAN cable is re-plugged ))
> 
> [  878.225116] CHIP_STATE: channel=0, txerr=200, rxerr=0
> [  878.225143] CHIP_STATE: channel=1, txerr=0, rxerr=0
> [  879.265167] CHIP_STATE: channel=0, txerr=200, rxerr=0
> [  879.267152] CHIP_STATE: channel=1, txerr=0, rxerr=0
> [  879.265167] CHIP_STATE: channel=0, txerr=200, rxerr=0
> [  879.267152] CHIP_STATE: channel=1, txerr=0, rxerr=0
> 
> (( The same counters get repeated every second ))
> 
> [2] State was polled using:
> 
> static int kvaser_usb_poll_chip_state(void *vpriv) {
>       struct kvaser_usb_net_priv *priv = vpriv;
> 
>       while (!kthread_should_stop()) {
>               kvaser_usb_simple_msg_async(priv, CMD_GET_CHIP_STATE);
>               ssleep(1);
>       }
> 
>       return 0;
> }
> 
> > I don't think that anything beyond that would be worth pursuing.
> > 
> 
> I agree, but given the new input, it seems that our problem
> extends to the error counters themselves not getting decreased
> on re-plug. So, even polling will not solve the issue: we'll
> get the same txerr/rxerr values again and again :-(
> 
Well, that's a damn shame. Not much you can do about that.

Best regards,
Andri
