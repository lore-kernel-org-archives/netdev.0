From: Dong Aisheng <b29396@freescale.com>
Subject: Re: M_CAN message RAM initialization AppNote  - was: Re: [PATCH V3
 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Fri, 7 Nov 2014 16:34:50 +0800
Message-ID: <20141107083447.GA23086@shlinux1.ap.freescale.net>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com>
 <1415193393-30023-3-git-send-email-b29396@freescale.com>
 <545A3451.2090302@pengutronix.de> <545A692E.40002@hartkopp.net>
 <20141106015716.GB7642@shlinux1.ap.freescale.net>
 <545B1D71.4000408@hartkopp.net>
 <20141106080940.GA22964@shlinux1.ap.freescale.net>
 <545B6AB4.70003@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <545B6AB4.70003@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 01:33:56PM +0100, Oliver Hartkopp wrote:
> On 06.11.2014 09:09, Dong Aisheng wrote:
> >On Thu, Nov 06, 2014 at 08:04:17AM +0100, Oliver Hartkopp wrote:
> 
> 
> >>To prevent the M_CAN controller detecting checksum errors when
> >>reading potentially uninitialized TX message RAM content to transmit
> >>CAN frames the TX message RAM has to be written with (any kind of)
> >>initial data.
> >>
> >
> >The key point of the issue is that why M_CAN will read potentially uninitialized
> >TX message RAM content which should not happen?
> >e.g. for our case of the issue, if we sending a no data frame or a less
> >than 4 bytes frame, why m_can will read extra 4 bytes uninitialized/unset
> >data which seems not reasonable?
> >
> > From IP code logic, it will read full 8 bytes of data no matter how many data
> >actually to be transfered which is strange.
> 
> Yes.
> 
> >
> >For sending data over 4 bytes, since the Message RAM content will be filled
> >with the real data to be transfered so there's no such issue.
> 
> E.g. think about the transfer of a CAN FD frame with 32 byte.
> When you only fill up content until 28 byte the last four bytes
> still remain uninitialized.
> 
> Did you try this 28 byte use-case with an uninitialized TX message RAM ?
> 
> cansend can0 123##1001122334566778899AABBCCDDEEFF001122334566778899AABB
> 
> To me it looks too risky when we only initialize the first 8 byte.
> 

I tried 28 byte case with two MX6SX SDB board and it worked.
See below:
Tx side:
root@imx6sxsabresd:~# cansend can0 123##1001122334566778899AABBC566778899AABB334
Rx side:
root@imx6sxsabresd:~# candump -x can0
  can0  RX B -  123  [32]  00 11 22 33 45 66 77 88 99 AA BB CC DD EE FF 00 11 22 33 45 66 77 88 99 AA BB 00 00 00 00 00 00

I think this is mainly because the driver will ensure to write
the full 32 bytes to Message RAM even we only fill up content of
28 bytes. The remain 4 bytes written to M_RAM are default 0.
This seems avoid the possibility of reading uninitialized TX message RAM
for transfer.

The code is done as follows:
for (i = 0; i < cf->len; i += 4)
        m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
                         *(u32 *)(cf->data + i));
cf->len will be rounded to 32 in cansend.

> >
> >>---
> >>
> >>Then the code should memset() the entire TX FIFO element - and not
> >>only the 8 data bytes we are addressing now.
> >>
> >
> >Our IC guy told me the issue only happened on transferring a data size
> >of less than 4 bytes and my test also proved that.
> 
> 'less than'?
> 

As i said before, from IP code logic, M_CAN will read extra data bytes
from TX buffer only for sending data less than 4 bytes.
e.g.
cansnd can0 123#
cansnd can0 123#112233
Both case will read the full 8 byte from TX buffer even it sends no data
and a 3 bytes data.

But
cansnd can0 123#1122334455
it read 8 bytes
cansnd can0 123##1112233445566778899001122
it read 12 bytes.
No extra uninitialized data read.

> So you might try to use 26 bytes too:
> 
> cansend can0 123##1001122334566778899AABBCCDDEEFF001122334566778899
> 
> 

It works too.

> >So i'm not sure memset() the entire TX FIFO element is neccesary...
> 
> It's no big deal - so we should be defensive here.
> And memset() is not working as Marc pointed out in another mail.
> 
> So we would need to loop with
> 
> 	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i), 0x0);
> 

This simple loop may not work.
m_can_fifo_write is only for Tx Buffer.

Since Message RAM may be shared, we may want to initialize each part of
Message RAM used by this M_CAN controller.
Something like follows in probe() function:

/* initialize the entire Message RAM in use to avoid possible
* ECC/parity checksum errors when reading an uninitialized buffer
*/
start = priv->mcfg[MRAM_SIDF].off;
end = priv->mcfg[MRAM_TXB].off +
priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
for (i = start; i < end; i += 4)
        writel(0x0, priv->mram_base + i);

I will send a updated patch for this.

Regards
Dong Aisheng

> >
> >Do you think we could keep the current solution firstly and updated later
> >if needed?
> 
> No :-)
> 
> I would like to have all data bytes to be written at startup.
> 
> Regards,
> Oliver
> 
