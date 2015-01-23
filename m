From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state
 change handling
Date: Fri, 23 Jan 2015 08:07:34 +0200
Message-ID: <20150123060734.GA7949@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux>
 <20150121103319.14511.57709@shannon>
 <e5439ed067931dc01bda70592eb6ed52@grandegger.com>
 <20150121144323.GA17070@linux>
 <20150121150015.31351.6605@shannon>
 <20150121153647.GB17070@linux>
 <49707d45a389a1acb9ccec4295d05762@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andri Yngvason <andri.yngvason@marel.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49707d45a389a1acb9ccec4295d05762@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2015 at 05:13:45PM +0100, Wolfgang Grandegger wrote:
> On Wed, 21 Jan 2015 10:36:47 -0500, "Ahmed S. Darwish"
> <darwish.07@gmail.com> wrote:
> > On Wed, Jan 21, 2015 at 03:00:15PM +0000, Andri Yngvason wrote:
> >> Quoting Ahmed S. Darwish (2015-01-21 14:43:23)
> >> > Hi!
> > 
> > ...
> > 
> >> > <-- Unplug the cable -->
> >> > 
> >> >  (000.009106)  can0  20000080   [8]  00 00 00 00 00 00 08 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{8}{0}}
> >> >  (000.001872)  can0  20000080   [8]  00 00 00 00 00 00 10 00  
> 
> For a bus-errors I would also expcect some more information in the
> data[2..3] fields. But these are always zero.
> 

M16C error factors made it possible to report things like
CAN_ERR_PROT_FORM/STUFF/BIT0/BIT1/TX in data[2], and
CAN_ERR_PROT_LOC_ACK/CRC_DEL in data[3].

Unfortunately such error factors are only reported in Leaf, but
not in USBCan-II due to the wire format change in the error event:

	struct leaf_msg_error_event {
		u8 tid;
		u8 flags;
		__le16 time[3];
		u8 channel;
		u8 padding;
		u8 tx_errors_count;
		u8 rx_errors_count;
		u8 status;
		u8 error_factor;
	} __packed;

	struct usbcan_msg_error_event {
		u8 tid;
		u8 padding;
		u8 tx_errors_count_ch0;
		u8 rx_errors_count_ch0;
		u8 tx_errors_count_ch1;
		u8 rx_errors_count_ch1;
		u8 status_ch0;
		u8 status_ch1;
		__le16 time;
	} __packed;

I speculate that the wire format was changed due to controller
bugs in the USBCan-II, which was slightly mentioned in their
data sheets here:

	http://www.kvaser.com/canlib-webhelp/page_hardware_specific_can_controllers.html

So it seems there's really no way for filling such bus error
info given the very limited amount of data exported :-(

The issue of incomplete data does not even stop here, kindly
check below notes regarding reverse state transitions:

> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{16}{0}}
> >> [...]
> >> >         error-counter-tx-rx{{80}{0}}
> >> >  (000.001910)  can0  20000080   [8]  00 00 00 00 00 00 58 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{88}{0}}
> >> >  (000.001753)  can0  20000084   [8]  00 08 00 00 00 00 60 00  
> >> >  ERRORFRAME
> >> >         controller-problem{tx-error-warning}
> >> Good.
> >> >         bus-error
> >> >         error-counter-tx-rx{{96}{0}}
> > 
> > Nice.
> > 
> >> >  (000.001720)  can0  20000080   [8]  00 00 00 00 00 00 68 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{104}{0}}
> >> >  (000.001876)  can0  20000080   [8]  00 00 00 00 00 00 70 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{112}{0}}
> >> >  (000.001749)  can0  20000080   [8]  00 00 00 00 00 00 78 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{120}{0}}
> >> >  (000.001771)  can0  20000084   [8]  00 20 00 00 00 00 80 00  
> >> >  ERRORFRAME
> >> >         controller-problem{tx-error-passive}
> >> Also good.
> >> >         bus-error
> >> >         error-counter-tx-rx{{128}{0}}
> > 
> > Also nice :-)
> > 
> >> >  (000.001868)  can0  20000080   [8]  00 00 00 00 00 00 80 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{128}{0}}
> >> >  (000.001982)  can0  20000080   [8]  00 00 00 00 00 00 80 00  
> >> >  ERRORFRAME
> >> >         bus-error
> >> >         error-counter-tx-rx{{128}{0}}
> >> > 
> >> > (( Then a continous flood, exactly similar to the above packet,
> >> > appears.
> >> >    Unfortunately this flooding is a firmware problem. ))
> >> > 
> >> > <-- Replug the cable, after a good amount of time -->
> >> >
> >> Where are the reverse state transitions?
> >> > 
> > 
> > Hmmm...
> > 
> > [ ... ]
> >> 
> >> Reverse state transitions are missing from the logs. See comments
> above.
> >> 
> > 
> > When the device is on the _receiving_ end, and I unplug the CAN cable
> after
> > introducing some noise to the level of reaching WARNING or PASSIVE, I
> > receive a BUS_ERROR event with the rxerr count reset back to 0 or 1. In
> > that case, the driver correctly transitions back the state to
> ERROR_ACTIVE
> > and candump produces something similar to:
> > 
> >     (000.000362)  can0  2000008C   [8]  00 40 40 00 00 00 00 01  
> >     ERRORFRAME
> >     controller-problem{}
> >     protocol-violation{{back-to-error-active}{}}
> >     bus-error
> >     error-counter-tx-rx{{0}{1}}
> > 
> > which is, AFAIK, the correct behaviour from the driver side.
> > 
> > Meanwhile, when the device is on the _sending_ end and I re-plug the CAN
> > cable again. Sometimes I receive events with txerr reset to 0 or 1, and
> > the driver correctly reverts back to ERROR_ACTIVE in that case. But on
> > another times like the quoted case above, I don't receive any events
> > resetting txerr back -- only data packets on the bus.
> 
> Well, the firmware seems to report *only* bus-errors via
> CMD_CAN_ERROR_EVENT messages, also carrying the new state, but no
> CMD_CHIP_STATE_EVENT just for the state changes.
> 

I've dumped _every_ message I receive from the firmware while
disconnecting the CAN bus, waiting a while, and connecting it again.
I really received _nothing_ from the firmware when the CAN bus was
reconnected and the data packets were flowing again. Not even a
single CHIP_STATE_EVENT, even after waiting for a long time.

So it's basically:
...
ERR EVENT, txerr=128, rxerr=0
ERR EVENT, txerr=128, rxerr=0
ERR EVENT, txerr=128, rxerr=0
...

then complete silence, except the data frames. I've even tried with
different versions of the firmware, but the same behaviour persisted.

> > So, What can the driver do given the above?
> 
> Little if the notification does not come.
> 

We can poll the state by sending CMD_GET_CHIP_STATE to the firmware,
and it will hopefully reply with a CHIP_STATE_EVENT response
containing the new txerr and rxerr values that we can use for
reverse state transitions.

But do we _really_ want to go through the path? I feel that it will
open some cans of worms w.r.t. concurrent access to both the netdev
and USB stacks from a single driver.

A possible solution can be setting up a kernel thread that queries
for a CHIP_STATE_EVENT every second?

Your inputs on this is appreciated.

> Wolfgang.
> 

Regards,
Darwish
