From: Dong Aisheng <b29396@freescale.com>
Subject: Re: M_CAN message RAM initialization AppNote  - was: Re: [PATCH V3
 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Thu, 6 Nov 2014 16:09:44 +0800
Message-ID: <20141106080940.GA22964@shlinux1.ap.freescale.net>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com>
 <1415193393-30023-3-git-send-email-b29396@freescale.com>
 <545A3451.2090302@pengutronix.de> <545A692E.40002@hartkopp.net>
 <20141106015716.GB7642@shlinux1.ap.freescale.net>
 <545B1D71.4000408@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <545B1D71.4000408@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 08:04:17AM +0100, Oliver Hartkopp wrote:
> On 06.11.2014 02:57, Dong Aisheng wrote:
> >On Wed, Nov 05, 2014 at 07:15:10PM +0100, Oliver Hartkopp wrote:
> 
> >>The Message RAM is usually equipped with a parity or ECC functionality.
> >>But RAM cells suffer a hardware reset and can therefore hold
> >>arbitrary content at startup - including parity and/or ECC bits.
> >>
> >>So when you write only the CAN ID and the first four bytes the last
> >>four bytes remain untouched. Then the M_CAN starts to read in 32bit
> >>words from the start of the Tx Message element. So it is very likely
> >>to trigger the message RAM error when reading the uninitialized
> >>32bit word from the last four bytes.
> >>
> >>Finally it turns out that an initial writing (with any kind of data)
> >>to the entire message RAM is mandatory to create valid parity/ECC
> >>checksums.
> >>
> >>That's it.
> >>
> >
> >Thanks for sharing this information.
> >Does it mean this issue is related to the nature of Message RAM and is
> >supposed to exist on all M_CAN IP versions?
> 
> From what I know from the 3.1.x revision there's no change regarding
> IR.BRU and IR.BEC - so I would assume this to stay on all M_CAN IP
> revisions.
> 
> But after some sleep I wonder if this patch [3/3] would need an update too.
> 
> Writing to the TX message RAM is obviously no workaround but a valid
> and needed initialization process.
> 
> I would tend to make this patch:
> 
> ---
> 
> can: m_can: add missing TX message RAM initialization
> 
> The M_CAN message RAM is usually equipped with a parity or ECC functionality.
> But RAM cells suffer a hardware reset and can therefore hold
> arbitrary content at startup - including parity and/or ECC bits.
> 
> To prevent the M_CAN controller detecting checksum errors when
> reading potentially uninitialized TX message RAM content to transmit
> CAN frames the TX message RAM has to be written with (any kind of)
> initial data.
> 

The key point of the issue is that why M_CAN will read potentially uninitialized
TX message RAM content which should not happen?
e.g. for our case of the issue, if we sending a no data frame or a less
than 4 bytes frame, why m_can will read extra 4 bytes uninitialized/unset
data which seems not reasonable?

>From IP code logic, it will read full 8 bytes of data no matter how many data
actually to be transfered which is strange.

For sending data over 4 bytes, since the Message RAM content will be filled
with the real data to be transfered so there's no such issue.

> ---
> 
> Then the code should memset() the entire TX FIFO element - and not
> only the 8 data bytes we are addressing now.
> 

Our IC guy told me the issue only happened on transferring a data size
of less than 4 bytes and my test also proved that.
So i'm not sure memset() the entire TX FIFO element is neccesary...

Do you think we could keep the current solution firstly and updated later
if needed?

> Maybe it makes sense to send the entire updated patch set (3) again ...
> 
> [1/3] can: add can_is_canfd_skb() API
> [2/3] can: m_can: update to support CAN FD features
> [3/3] can: m_can: add missing message RAM initialization
> 
> Are you ok with that?
> 
> Regards,
> Oliver
> 

Regards
Dong Aisheng
