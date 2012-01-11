From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Wed, 11 Jan 2012 15:37:32 +0100
Message-ID: <4F0D9EAC.9010101@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF3B@saturn3.aculab.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: David Laight <David.Laight@ACULAB.COM>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF3B@saturn3.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

>
>> @@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct
>> net_device *dev, unsigned int o)
>>    	/* Nothing more to send, switch off interrupts */
>>    	cc770_write_reg(priv, msgobj[mo].ctrl0,
>>    			MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
>> -	/*
>> -	 * We had some cases of repeated IRQ so make sure the
>> -	 * INT is acknowledged
>> -	 */
>> -	cc770_write_reg(priv, msgobj[mo].ctrl0,
>> -			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>
> A wild guess is that this is needed to clear an interrupt
> that was asserted during the ISR processing.
> So you need to ack the IRQ as well as mask it.

I was digging a bit and as far as I understood by studying both
manuals of i82527 and cc770 the procedure is in any case most
probably not completely clean.

 From my point of view there would be no need to set and reset
TXIE/RXIE after every request because according to the description
as below (e.g for TXIE):


       MSB LSB    Meaning
Write  0   0  Not allowed
               (indeterminate)
        0   1  reset
        1   0  set
        1   1  unchanged



TXIE Transmit Interrupt Enable
  one  An interrupt will be generated after a successful
       transmission of a frame
  zero No interrupt will be generated after a successful
       transmission of a frame
       The Transmit Interrupt Enable bit enables the
       82527 to initiate an interrupt after the successful
       transmission by the corresponding message
       object This bit is written by the CPU

In fact with that we are telling the chip if we want to have
interrupts or not for a transmission and therefore it would
be enough, so far I understood, to set it at _init and switch
it of at _deinit and between just using 'unchanged'.

Actually to ack the IRQ we would have to set TXOK of the
status register to zero after reading a one for a successful
transmission but is in fact the chip doesn't care if we
reset TXOK or not.

However, if time permits I'll try to dig deeper and doing some
tests because it would need some changes more.


Anyway, I might be wrong as well because sometimes I'm checking
under heavy workload the wrong bit's as You know already ;-)


More or less the reason for the request of removal was just because
assuming that the repeated interrupts were caused as well not having
spinlock's and on the other hand if obsolete to save I/O resources
which affects mostly smaller systems with heavy load.

However, maybe Wolfgang can give an advice.


>
> Not sure if the difference between the xxx_UNC and xxx_RES
> bits though.
>
> 	David
>
>
Wolfgang
