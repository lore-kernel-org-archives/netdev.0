From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: M_CAN message RAM initialization AppNote  - was: Re: [PATCH V3
 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Thu, 06 Nov 2014 13:33:56 +0100
Message-ID: <545B6AB4.70003@hartkopp.net>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415193393-30023-3-git-send-email-b29396@freescale.com> <545A3451.2090302@pengutronix.de> <545A692E.40002@hartkopp.net> <20141106015716.GB7642@shlinux1.ap.freescale.net> <545B1D71.4000408@hartkopp.net> <20141106080940.GA22964@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141106080940.GA22964@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06.11.2014 09:09, Dong Aisheng wrote:
> On Thu, Nov 06, 2014 at 08:04:17AM +0100, Oliver Hartkopp wrote:


>> To prevent the M_CAN controller detecting checksum errors when
>> reading potentially uninitialized TX message RAM content to transmit
>> CAN frames the TX message RAM has to be written with (any kind of)
>> initial data.
>>
>
> The key point of the issue is that why M_CAN will read potentially uninitialized
> TX message RAM content which should not happen?
> e.g. for our case of the issue, if we sending a no data frame or a less
> than 4 bytes frame, why m_can will read extra 4 bytes uninitialized/unset
> data which seems not reasonable?
>
>  From IP code logic, it will read full 8 bytes of data no matter how many data
> actually to be transfered which is strange.

Yes.

>
> For sending data over 4 bytes, since the Message RAM content will be filled
> with the real data to be transfered so there's no such issue.

E.g. think about the transfer of a CAN FD frame with 32 byte.
When you only fill up content until 28 byte the last four bytes still remain 
uninitialized.

Did you try this 28 byte use-case with an uninitialized TX message RAM ?

cansend can0 123##1001122334566778899AABBCCDDEEFF001122334566778899AABB

To me it looks too risky when we only initialize the first 8 byte.

>
>> ---
>>
>> Then the code should memset() the entire TX FIFO element - and not
>> only the 8 data bytes we are addressing now.
>>
>
> Our IC guy told me the issue only happened on transferring a data size
> of less than 4 bytes and my test also proved that.

'less than'?

So you might try to use 26 bytes too:

cansend can0 123##1001122334566778899AABBCCDDEEFF001122334566778899


> So i'm not sure memset() the entire TX FIFO element is neccesary...

It's no big deal - so we should be defensive here.
And memset() is not working as Marc pointed out in another mail.

So we would need to loop with

	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i), 0x0);

>
> Do you think we could keep the current solution firstly and updated later
> if needed?

No :-)

I would like to have all data bytes to be written at startup.

Regards,
Oliver

