From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 1/3] can: kvaser_usb: Fix tx queue start/stop race
 conditions
Date: Sat, 14 Mar 2015 10:38:20 -0400
Message-ID: <20150314143820.GA22071@linux>
References: <20150226152011.GA6075@linux>
 <20150314130249.GA20796@linux>
 <55043A7E.7040001@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55043A7E.7040001@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Sat, Mar 14, 2015 at 02:41:18PM +0100, Marc Kleine-Budde wrote:
> On 03/14/2015 02:02 PM, Ahmed S. Darwish wrote:
> > From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > 
> > A number of tx queue wake-up events went missing due to the
> > outlined scenario below. Start state is a pool of 16 tx URBs,
> > active tx_urbs count = 15, with the netdev tx queue open.
> > 
> > CPU #1 [softirq]                         CPU #2 [softirq]
> > start_xmit()                             tx_acknowledge()
> > ................                         ................
> > 
> > atomic_inc(&tx_urbs);
> > if (atomic_read(&tx_urbs) >= 16) {
> >                         -->
> >                                          atomic_dec(&tx_urbs);
> >                                          netif_wake_queue();
> >                                          return;
> >                         <--
> >     netif_stop_queue();
> > }
> > 
> > At the end, the correct state expected is a 15 tx_urbs count
> > value with the tx queue state _open_. Due to the race, we get
> > the same tx_urbs value but with the tx queue state _stopped_.
> > The wake-up event is completely lost.
> > 
> > Thus avoid hand-rolled concurrency mechanisms and use a proper
> > lock for contexts and tx queue protection.
> > 
> > Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> Applied to can. This will go into David's net tree and finally into
> net-next. Then I'll apply patches 2+3. Nag me, if I forget about them ;)
> 

Thanks! :-)

So if I've understood correctly, this patch will go to -rc5 and
the rest will go into net-next?

If so, IMHO patch #2 should also go to -rc5. I know it's usually
frowned up on to add further patches at this late -rc stage, but
here's my logic:

The original driver code just _arbitrarily_ assumed a MAX_TX_URB
value of 16 parallel transmissions. This value was chosen, it seems,
because the driver was heavily based on esd_usb2.c and the esd code
just did so :-(

Meanwhile, in the Kvaser hardware at hand, if I've increased the
driver's max parallel transmissions little above the recommended
limit reported by firmware, the firmware breaks up badly, reports a
massive list of internal errors, and the candump traces becomes
sort of an internal mess hardly related to the actual frames sent
and received.

In my case, I was lucky that the brand we own here (*) had a higher
max outstanding transmissions value than 16. But if there is hardware
out there with a max oustanding tx support < 16 (#), such hardware
will break badly under a heavy transmission load :-(

(*) http://www.kvaser.com/products/kvaser-usb-hs-ii-hsls/

(#) There are a huge list of Kvaser products having the same controller
    but with different performance metrics, so this is quite a
    possiblity.

Thanks,
Darwish
