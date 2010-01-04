From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] can: mscan-mpc5xxx: add support for the
	MPC521x processor
Date: Mon, 04 Jan 2010 17:52:43 +0100
Message-ID: <4B421CDB.4010902@grandegger.com>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com>	<1262420274-16586-2-git-send-email-wg@grandegger.com>	<1262420274-16586-3-git-send-email-wg@grandegger.com>	<20100102135734.GC2239@pengutronix.de>	<4B3F6F6B.5070004@grandegger.com>
	<20100104162441.GA4665@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100104162441.GA4665-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Hi Wolfram,

Wolfram Sang wrote:
> Hello Wolfgang,
> 
> first the good news: Your patches also work with our MPC5121-board.

Nice. Just for curiosity, what clock and frequency does it select on
your board? It should be listed when the driver is loaded.

>>>> +#else /* !CONFIG_PPC_MPC5200 */
>>>> +static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
>>>> +					   const char *clock_name,
>>>> +					   int *mscan_clksrc)
>>>> +{
>>>> +	return 0;
>>>> +}
>>>> +#endif /* CONFIG_PPC_MPC5200 */
>>> Hmmm, I don't really like those empty functions. I once used the data-field of
>>> struct of_device_id, which carried a function pointer to a specific
>>> init-function for the matched device. What do you think about such an approach?
>> Often the problem is that the function will not compile on the other MPC
>> arch. This is not true here. So, the main reason for the #ifdefs is
>> space saving. Your approach will not help in both cases.
> 
> My idea was: it might be nice to save both #else-branches and the if-clause in
> probe() which calls this get_clock() or the other (and then another in case
> there will be a new mpc5xyz-user in the future). And replace it with some
> mpc5xxx_custom_init() which is taken from of_device_id->data. No big issue,
> though; no show-stopper.

You mean like in the i2c-mpc driver:

http://lxr.linux.no/#linux+v2.6.32/drivers/i2c/busses/i2c-mpc.c#L585

No problem, if I handle the regs property inside the mpc5121-specific
function. The #ifdef's are for *space saving*. If nobody else than me
cares, I will remove them.

>>>> +
>>>> +#ifdef CONFIG_PPC_MPC512x
>>>> +struct mpc512x_clockctl {
>>>> +	u32 spmr;		/* System PLL Mode Reg */
>>>> +	u32 sccr[2];		/* System Clk Ctrl Reg 1 & 2 */
>>>> +	u32 scfr1;		/* System Clk Freq Reg 1 */
>>>> +	u32 scfr2;		/* System Clk Freq Reg 2 */
>>>> +	u32 reserved;
>>>> +	u32 bcr;		/* Bread Crumb Reg */
>>>> +	u32 pccr[12];		/* PSC Clk Ctrl Reg 0-11 */
>>>> +	u32 spccr;		/* SPDIF Clk Ctrl Reg */
>>>> +	u32 cccr;		/* CFM Clk Ctrl Reg */
>>>> +	u32 dccr;		/* DIU Clk Cnfg Reg */
>>>> +	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
>>>> +};
> 
> I wonder if this (and the occurence in clock.c) should be factored out and
> moved to asm/mpc5xxx.h?

I was thinking about that as well but mpc5xxx.h seems not (yet) to be a
popular place to store mpc5xxx related definitions.

>>>> +
>>>> +static struct of_device_id mpc512x_clock_ids[] __devinitdata = {
>>>> +	{ .compatible = "fsl,mpc5121-clock", },
>>>> +	{}
>>>> +};
>>>> +
>>>> +static u32  __devinit mpc512x_can_get_clock(struct of_device *ofdev,
>>>> +					    const char *clock_name,
>>>> +					    int *mscan_clksrc,
>>>> +					    ssize_t mscan_addr)
>>>> +{
>>>> +	struct mpc512x_clockctl __iomem *clockctl;
>>>> +	struct device_node *np_clock;
>>>> +	struct clk *sys_clk, *ref_clk;
>>>> +	int plen, clockidx, clocksrc = -1;
>>>> +	u32 sys_freq, val, clockdiv = 1, freq = 0;
>>>> +	const u32 *pval;
>>>> +
>>>> +	np_clock = of_find_matching_node(NULL, mpc512x_clock_ids);
>>>> +	if (!np_clock) {
>>>> +		dev_err(&ofdev->dev, "couldn't find clock node\n");
>>>> +		return -ENODEV;
>>>> +	}
>>>> +	clockctl = of_iomap(np_clock, 0);
>>>> +	if (!clockctl) {
>>>> +		dev_err(&ofdev->dev, "couldn't map clock registers\n");
>>>> +		return 0;
>>>> +	}
>>>> +
>>>> +	/* Determine the MSCAN device index from the physical address */
>>>> +	clockidx = (mscan_addr & 0x80) ? 1 : 0;
>>>> +	if (mscan_addr & 0x2000)
>>>> +		clockidx += 2;
>>> The PSCs use 'cell-index', here we use mscan_addr to derive the index. This is
>>> not consistent, but should be IMHO. Now, which is the preferred way? I think
>>> I'd go for 'cell-index', as other processors might have mscan_addr shuffled.
>>> Also, we could use 'of_iomap' again in the probe_routine.
>> I understood that "cell-index" is deprecated and it has been removed
>> from many nodes. That's why I used the address to derive the index.
> 
> Well, the arguments in your other mail make sense to me, so keep it this way.
> As not only the index-issue, but also the clock-handling is different for the
> PSCs, it is at least consistently inconsistent :D

OK.

> One further note: I couldn't spot any code handling Rev1 of the MPC5121? Do you
> plan to add such code? If not, we should at least put a comment that it is
> missing. The binding documentation should be updated as well, as you can't use
> all options on such revisions.

Do we have rev1 support in the mainline kernel? I also understood that
there are only a few devel boards out there with v1 CPUs. If necessary,
this could be fixed later on demand. But it should be documented, e.g.
in the KConfig and dts bindings doc, of course.

Did you have a chance to test bus-off recovery? I just realized one
issue if the device is stopped while in bus-off.

Will come up with a v2 patch soon...

Thanks,

Wolfgang.
