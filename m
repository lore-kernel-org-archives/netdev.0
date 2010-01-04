From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next 2/3] can: mscan-mpc5xxx: add support for the
 MPC521x processor
Date: Mon, 04 Jan 2010 13:49:10 +0100
Message-ID: <4B41E3C6.9060306@grandegger.com>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com>	<1262420274-16586-2-git-send-email-wg@grandegger.com>	<1262420274-16586-3-git-send-email-wg@grandegger.com>	<20100102135734.GC2239@pengutronix.de> <4B3F6F6B.5070004@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de, Netdev@vger.kernel.org,
	Devicetree-discuss@lists.ozlabs.org, Linuxppc-dev@lists.ozlabs.org,
	Wolfgang Grandegger <wg@denx.de>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4B3F6F6B.5070004@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Wolfram Sang wrote:
>> On Sat, Jan 02, 2010 at 09:17:53AM +0100, Wolfgang Grandegger wrote:
>>> From: Wolfgang Grandegger <wg@denx.de>
>>>
>>> The main differences compared to the MSCAN on the MPC5200 are:
>>>
>>> - More flexibility in choosing the CAN source clock and frequency:
>>>
>>>   Three different clock sources can be selected: "ip", "ref" or "sys".
>>>   For the latter two, a clock divider can be defined as well. If the
>>>   clock source is not specified by the device tree, we first try to
>>>   find an optimal CAN source clock based on the system clock. If that
>>>   is not possible, the reference clock will be used.
>>>
>>> - The behavior of bus-off recovery is configurable:
>>>
>>>   To comply with the usual handling of Socket-CAN bus-off recovery,
>>>   "recovery on request" is selected (instead of automatic recovery).
>>>
>>> Signed-off-by: Wolfgang Grandegger <wg@denx.de>
>>> ---
>>>  drivers/net/can/mscan/Kconfig       |    2 +-
>>>  drivers/net/can/mscan/mpc5xxx_can.c |  234 +++++++++++++++++++++++++++++------
>>>  drivers/net/can/mscan/mscan.c       |   41 +++++--
>>>  drivers/net/can/mscan/mscan.h       |   81 ++++++------
>>>  4 files changed, 271 insertions(+), 87 deletions(-)
>>>
> [snip]
> 
>>> +#else /* !CONFIG_PPC_MPC5200 */
>>> +static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
>>> +					   const char *clock_name,
>>> +					   int *mscan_clksrc)
>>> +{
>>> +	return 0;
>>> +}
>>> +#endif /* CONFIG_PPC_MPC5200 */
>> Hmmm, I don't really like those empty functions. I once used the data-field of
>> struct of_device_id, which carried a function pointer to a specific
>> init-function for the matched device. What do you think about such an approach?
> 
> Often the problem is that the function will not compile on the other MPC
> arch. This is not true here. So, the main reason for the #ifdefs is
> space saving. Your approach will not help in both cases.
> 
>>> +
>>> +#ifdef CONFIG_PPC_MPC512x
>>> +struct mpc512x_clockctl {
>>> +	u32 spmr;		/* System PLL Mode Reg */
>>> +	u32 sccr[2];		/* System Clk Ctrl Reg 1 & 2 */
>>> +	u32 scfr1;		/* System Clk Freq Reg 1 */
>>> +	u32 scfr2;		/* System Clk Freq Reg 2 */
>>> +	u32 reserved;
>>> +	u32 bcr;		/* Bread Crumb Reg */
>>> +	u32 pccr[12];		/* PSC Clk Ctrl Reg 0-11 */
>>> +	u32 spccr;		/* SPDIF Clk Ctrl Reg */
>>> +	u32 cccr;		/* CFM Clk Ctrl Reg */
>>> +	u32 dccr;		/* DIU Clk Cnfg Reg */
>>> +	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
>>> +};
>>> +
>>> +static struct of_device_id mpc512x_clock_ids[] __devinitdata = {
>>> +	{ .compatible = "fsl,mpc5121-clock", },
>>> +	{}
>>> +};
>>> +
>>> +static u32  __devinit mpc512x_can_get_clock(struct of_device *ofdev,
>>> +					    const char *clock_name,
>>> +					    int *mscan_clksrc,
>>> +					    ssize_t mscan_addr)
>>> +{
>>> +	struct mpc512x_clockctl __iomem *clockctl;
>>> +	struct device_node *np_clock;
>>> +	struct clk *sys_clk, *ref_clk;
>>> +	int plen, clockidx, clocksrc = -1;
>>> +	u32 sys_freq, val, clockdiv = 1, freq = 0;
>>> +	const u32 *pval;
>>> +
>>> +	np_clock = of_find_matching_node(NULL, mpc512x_clock_ids);
>>> +	if (!np_clock) {
>>> +		dev_err(&ofdev->dev, "couldn't find clock node\n");
>>> +		return -ENODEV;
>>> +	}
>>> +	clockctl = of_iomap(np_clock, 0);
>>> +	if (!clockctl) {
>>> +		dev_err(&ofdev->dev, "couldn't map clock registers\n");
>>> +		return 0;
>>> +	}
>>> +
>>> +	/* Determine the MSCAN device index from the physical address */
>>> +	clockidx = (mscan_addr & 0x80) ? 1 : 0;
>>> +	if (mscan_addr & 0x2000)
>>> +		clockidx += 2;
>> The PSCs use 'cell-index', here we use mscan_addr to derive the index. This is
>> not consistent, but should be IMHO. Now, which is the preferred way? I think
>> I'd go for 'cell-index', as other processors might have mscan_addr shuffled.
>> Also, we could use 'of_iomap' again in the probe_routine.
> 
> I understood that "cell-index" is deprecated and it has been removed
> from many nodes. That's why I used the address to derive the index.

So more thoughts: I still find inspecting the regs less error prune than
defining cell-index and it should work fine for "fsl,mpc5121_mscan".
Other processor variants might handle a different register layout with
another appropriate compatibility string. But I could retrieve the
"regs" property inside mpc512x_can_get_clock() to use of_iomap() as before.

Wolfgang.

