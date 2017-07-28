From: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Fri, 28 Jul 2017 21:41:43 +0200
Message-ID: <20170728194143.GA10599@airbook.vandijck-laurijssen.be>
References: <20170728130231.GA10680@airbook.vandijck-laurijssen.be>
 <c7d4c364-1ed9-ca73-2571-d04297ac3788@hartkopp.net>
 <80c167a2-7eb5-8076-04fc-0989981a523d@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
        robh+dt@kernel.org, quentin.schulz@free-electrons.com,
        sergei.shtylyov@cogentembedded.com
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <80c167a2-7eb5-8076-04fc-0989981a523d@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> On 07/28/2017 01:33 PM, Oliver Hartkopp wrote:
> > Hi Kurt,
> > 
> > On 07/28/2017 03:02 PM, Kurt Van Dijck wrote:
> > 
> >>>> The word 'max-arbitration-bitrate' makes the difference very clear.
> >>>
> >>> I think you are mixing up ISO layer 1 and ISO layer 2.
> >>
> >> In order to provide higher data throughput without putting extra limits
> >> on transceiver & wire, the requirement for the round-trip delay to be
> >> within 1 bittime has been eliminated, but only for the data phase when
> >> arbitration is over.
> >> So layer 2 (CAN FD) has been adapted to circumvent the layer 1
> >> (transceiver + wire) limitations.
> >>
> >> In fact, the round-trip delay requirement never actually did matter for
> >> plain CAN during data bits either. CAN FD just makes use of that,
> >> but is therefore incompatible on the wire.
> >>
> >> I forgot the precise wording, but this is the principle that Bosch
> >> explained on the CAN conference in Nurnberg several years ago, or at
> >> least this is how I remembered it :-)
> > 
> > I just checked an example for a CAN FD qualified transceiver
> > 
> > http://www.nxp.com/products/automotive-products/energy-power-management/can-transceivers/high-speed-can-transceiver-with-standby-mode:TJA1044
> > 
> > 
> > where it states:
> > 
> > The TJA1044T is specified for data rates up to 1 Mbit/s. Pending the
> > release of ISO11898-2:2016 including CAN FD and SAE-J2284-4/5,
> > additional timing parameters defining loop delay symmetry are specified
> > for the TJA1044GT and TJA1044GTK. This implementation enables reliable
> > communication in the CAN FD fast phase at data rates up to 5 Mbit/s.
> > 
> > and
> > 
> > TJA1044GT/TJA1044GTK
> > 
> > - Timing guaranteed for data rates up to 5 Mbit/s
> > - Improved TXD to RXD propagation delay of 210 ns

Note the words "loop delay symmetry" and "CAN FD fast phase".
I didn't dig into the ISO's, but I read this as:
the TJA1044GT (not the TJA1044T) supports CAN FD data bitrate up to
5MBit/s. The overall (and thus arbitration) bitrate is max 1MBit/s.

What did I miss?

> > 
> >> I haven't followed the developments of transceivers, but with the above
> >> principle in mind, it's obvious that any transceiver allows higher
> >> bitrates during the data segment because the TX-to-RX line delay must
> >> not scale with the bitrate.
> >> In reality, maybe not all transceivers will mention this in their
> >> datasheet.
> >>
> >> So whether you call it 'max-arbitration-bitrate' & 'max-data-bitrate'
> >> or 'max-bitrate' & 'max-data-bitrate' does not really matter (I prefer
> >> 1st) but you will one day need 2 bitrates.
> > 
> > The question to me is whether it is right option to specify two bitrates
> > OR to specify one maximum bitrate and provide a property that a CAN FD
> > capable propagation delay is available.
> > 
> > E.g.
> > 
> >     max-bitrate
> >     max-data-bitrate
> > 
> > or
> > 
> >     max-bitrate
> >     canfd-capable    // CAN FD capable propagation delay available

When you say: 'there is a CAN FD capable propagation delay available',
this actually means that you the transceiver specified a seperate
max-data-bitrate, but you don't mention what it is.
How can linux determine the max-data-bitrate to use?

> > 
> > 
> > I assume the optimized propagation delay is 'always on' as the
> > transceiver is not able to detect which kind of bits it is processing.
> > That's why I think providing two bitrates leads to a wrong view on the
> > transceiver.
> 
> I agree with this.

I still disagree as I still think that CAN FD data phase (or fast phase)
has different round-trip delay (or "loop-delay symmetry") requirements
than the arbitration phase.
The CAN chip during data-phase does not need RX to follow TX as it does during
arbitration phase.  The optimized propagation delay is 'always on' but
only applicable or sufficient during data phase. during arbitration
phase, you (the CAN FD chip) requires a better round-trip delay, and the
transceiver cannot deliver this.

> 
> The transceiver is an analog device that needs to support faster
> switching frequency (FETs) including minimizing delay to support CAN-FD
> ie higher bitrate. From the transceiver perspective the bits for
> "arbitration" and "data" look exactly the same. Since it can't
> differentiate between the two (at the physical layer) then the actual
> limit isn't specific to which part/type of the CAN message is being
> sent. Rather its just a single overall max bitrate limit.

I must disagree here.
The transceiver is an analog device that performs 2 functions:
propagate tx bits to CAN wire, and propagate CAN wire state
(dominant/recesive) to rx bits.

I'll rephrase the above explanation to fit your argument:
During arbitration, both directions are required, and needs to propagate
within 1 bit time. The transceiver doesn't know, it just performs to
best effort.
During data, the round-trip timing requirement of layer2 is relaxed.
The transceiver still doesn't know, it still performs to best effort.
Due to the relaxed round-trip timing requirement, the same transceiver
can suddenly allow higher bitrates. The transceiver didn't change, the
requirement did change.
This is what I meant earlier with "layer2 has been adapted to circumvent
layer1 limitations"

Was I successfull in transcoding my thoughts onto email :-) ?

Kind regards,
Kurt
