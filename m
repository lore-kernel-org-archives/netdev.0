From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] can: mscan-mpc5xxx: add support for the
	MPC521x processor
Date: Mon, 04 Jan 2010 18:35:17 +0100
Message-ID: <4B4226D5.6000702@grandegger.com>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com>
	<1262420274-16586-2-git-send-email-wg@grandegger.com>
	<1262420274-16586-3-git-send-email-wg@grandegger.com>
	<20100102135734.GC2239@pengutronix.de>
	<4B3F6F6B.5070004@grandegger.com>
	<20100104162441.GA4665@pengutronix.de>
	<4B421CDB.4010902@grandegger.com>
	<20100104172209.GC4665@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100104172209.GC4665-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Wolfram Sang wrote:
>> Nice. Just for curiosity, what clock and frequency does it select on
>> your board? It should be listed when the driver is loaded.
> 
> Using this simple dts-snipplet
> 
>                 mscan@1300 {
>                         compatible = "fsl,mpc5121-mscan";
>                         cell-index = <0>;
>                         interrupts = <12 8>;
>                         interrupt-parent = < &ipic >;
>                         reg = <0x1300 0x80>;
>                 };
> 
> I get this output:
> 
> mpc5xxx_can 80001300.mscan: using 'sys_clk' with frequency divider 25
> mpc5xxx_can 80001300.mscan: MSCAN at 0xe1064300, irq 16, clock 16000000 Hz
> 
> mpc5xxx_can 80001380.mscan: using 'sys_clk' with frequency divider 25
> mpc5xxx_can 80001380.mscan: MSCAN at 0xe106c380, irq 17, clock 16000000 Hz

OK, the the board uses an oscillator clock of 33.333333 MHz. The "ref"
or "ip" clock would be a worse choice.

>>> My idea was: it might be nice to save both #else-branches and the if-clause in
>>> probe() which calls this get_clock() or the other (and then another in case
>>> there will be a new mpc5xyz-user in the future). And replace it with some
>>> mpc5xxx_custom_init() which is taken from of_device_id->data. No big issue,
>>> though; no show-stopper.
>> You mean like in the i2c-mpc driver:
>>
>> http://lxr.linux.no/#linux+v2.6.32/drivers/i2c/busses/i2c-mpc.c#L585
> 
> Yes.
> 
>> No problem, if I handle the regs property inside the mpc5121-specific
>> function. The #ifdef's are for *space saving*. If nobody else than me
>> cares, I will remove them.
> 
> I'd be fine with keeping them.

OK.

>>>>>> +
>>>>>> +#ifdef CONFIG_PPC_MPC512x
>>>>>> +struct mpc512x_clockctl {
>>>>>> +	u32 spmr;		/* System PLL Mode Reg */
>>>>>> +	u32 sccr[2];		/* System Clk Ctrl Reg 1 & 2 */
>>>>>> +	u32 scfr1;		/* System Clk Freq Reg 1 */
>>>>>> +	u32 scfr2;		/* System Clk Freq Reg 2 */
>>>>>> +	u32 reserved;
>>>>>> +	u32 bcr;		/* Bread Crumb Reg */
>>>>>> +	u32 pccr[12];		/* PSC Clk Ctrl Reg 0-11 */
>>>>>> +	u32 spccr;		/* SPDIF Clk Ctrl Reg */
>>>>>> +	u32 cccr;		/* CFM Clk Ctrl Reg */
>>>>>> +	u32 dccr;		/* DIU Clk Cnfg Reg */
>>>>>> +	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
>>>>>> +};
>>> I wonder if this (and the occurence in clock.c) should be factored out and
>>> moved to asm/mpc5xxx.h?
>> I was thinking about that as well but mpc5xxx.h seems not (yet) to be a
>> popular place to store mpc5xxx related definitions.
> 
> Probably because the mpc5121 is not very popular when it comes to mainline
> activity. (BTW, I also wondered why it is not named mpc512x.h as I'd think
> mpc5xxx is for common stuff between mpc5200 and mpc5121. But this is another
> issue, not relevant here.)

Well, yes. The mpc512x Socket-CAN mainline support is already in a much
better shape than the base port. I will keep it until the mpc512x port
has matured/settled.

>>> One further note: I couldn't spot any code handling Rev1 of the MPC5121? Do you
>>> plan to add such code? If not, we should at least put a comment that it is
>>> missing. The binding documentation should be updated as well, as you can't use
>>> all options on such revisions.
>> Do we have rev1 support in the mainline kernel? I also understood that
>> there are only a few devel boards out there with v1 CPUs. If necessary,
>> this could be fixed later on demand. But it should be documented, e.g.
>> in the KConfig and dts bindings doc, of course.
> 
> Yup, documenting it will do.
> 
>> Did you have a chance to test bus-off recovery? I just realized one
>> issue if the device is stopped while in bus-off.
> 
> Sorry, I just did basic transfer-tests as I am currently busy with other
> projects.

You are welcome.

>> Will come up with a v2 patch soon...
> 
> Please do an s/latetr/latter/ before posting it :)

OK.

Wolfgang.
