From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/3] ptp: Added a clock that uses the eTSEC found on
	the MPC85xx.
Date: Mon, 17 May 2010 10:27:57 +0200
Message-ID: <20100517082757.GA9703@riccoc20.at.omicron.at>
References: <cover.1273855016.git.richard.cochran@omicron.at>
	<ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at>
	<4BED8C91.8020107@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BED8C91.8020107-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 14, 2010 at 12:46:57PM -0500, Scott Wood wrote:
> On 05/14/2010 11:46 AM, Richard Cochran wrote:
> >diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
> 
> Get rid of both device_type and model, and specify a compatible
> string instead (e.g. "fsl,etsec-ptp").

Okay, will do. I really am at a loss at understanding all the rules in
the whole device tree world. I just tried to follow
Documentation/powerpc and what is already present in the kernel.

> Or perhaps this should just be some additional properties on the
> existing gianfar nodes, rather than presenting it as a separate
> device?  How do you associate a given ptp block with the
> corresponding gianfar node?

There only one PTP clock. Its registers repeat in each port's memory
space, but you are only supposed to touch the first set of PTP
registers. If you consider how PTP works, there can never be per port
clocks, since this would make it impossible to make a boundary clock,
for example.

The whole idea of this PTP clock framework is to keep the clock
drivers separate from the MAC drivers, even when they use the same
hardware. The functionality is logically divided into two parts. The
MAC provides time stamps, and the clock provides a way to control its
offset and frequency.

Up until this point, people have simply hacked new private ioctls into
the driver for each MAC that supports PTP. That is not a good long
term solution for PTP support in Linux.

In general, I think it will not be hard to keep the MAC and the clock
drivers from stepping on each other's toes. The eTSEC hardware is
certainly able to be used in this way.

> If there are differences in ptp implementation between different
> versions of etsec, can the ptp driver see the etsec version
> register?

There are no differences (that I know of) in how the PTP clocks
work. I have in house the mpc8313, the mpc8572, and the p2020. The
mpc8572 appears to lack some of the TMR_CTRL bits, but this is
probably a documentation bug. I will check it.

> >+  - tclk_period  Timer reference clock period in nanoseconds.
> >+  - tmr_prsc     Prescaler, divides the output clock.
> >+  - tmr_add      Frequency compensation value.
> >+  - cksel        0= external clock, 1= eTSEC system clock, 3= RTC clock input.
> >+                 Currently the driver only supports choice "1".
> >+  - tmr_fiper1   Fixed interval period pulse generator.
> >+  - tmr_fiper2   Fixed interval period pulse generator.
> 
> Dashes are more typical in OF names than underscores, and it's
> generally better to be a little more verbose -- these aren't local
> loop iterators.

The names come from the register mnemonics from the documentation. I
prefer to use the same names as is found in the manuals. That way, a
person working with docu in hand will have an easier job.

> They should probably have an "fsl,ptp-" prefix as well.

Okay, but must I then change the following code in order to find them?
Does adding the prefix just mean that I also add it to my search
strings, or is it preprocessed (stripped) somehow?

static int get_of_u32(struct device_node *node, char *str, u32 *val)
{
	int plen;
	const u32 *prop = of_get_property(node, str, &plen);

	if (!prop || plen != sizeof(*prop))
	   return -1;
	   *val = *prop;
	   return 0;
}
...
	if (get_of_u32(node, "tclk_period",&etsects->tclk_period) ||
	    get_of_u32(node, "tmr_prsc",&etsects->tmr_prsc) ||
	    get_of_u32(node, "tmr_add",&etsects->tmr_add) ||
	    get_of_u32(node, "cksel",&etsects->cksel) ||
	    get_of_u32(node, "tmr_fiper1",&etsects->tmr_fiper1) ||
	    get_of_u32(node, "tmr_fiper2",&etsects->tmr_fiper2))
		return -ENODEV;

> >+  These properties set the operational parameters for the PTP
> >+  clock. You must choose these carefully for the clock to work right.
> 
> Do these values describe the way the hardware is, or how it's been
> configured by firmware, or a set of values that are clearly optimal
> for this particular board?  If it's just configuration for the Linux
> driver, that could reasonably differ based on what a given user or
> OS will want, the device tree probably isn't the right place for it.

The values are related to the board. One important parameter is the
input clock, and the rest reflect some engineering decisions/tradeoffs
related to the signals to and from the PTP clock. There is not just
one "optimal" choice, so I wanted to let the designer set the
values. In any case, the parameters are definitely related to the
board (not to the cpu or to linux), so I think the device tree is the
right place for them.

> This one has 3 interrupts?  The driver supports only two.

The documentation does not specify the IRQ line that each event
belongs to. After some trial and error, it appears that all of the
ancillary clock interrupts arrive on the first interrupt. The other
lines (one per port) must be for the Tx/Rx packet time stamp
indication, but we don't need these for the clock or for the MAC.

I'll just reduce the driver to one interrupt.

> >+/* Private globals */
> >+static struct ptp_clock *gianfar_clock;
> 
> Do you not support more than one of these?
> 
> >+static struct etsects the_clock;
> 
> "The" clock?  As oppsed to the "other" clock one line above? :-)

The 'gianfar_clock' variable holds the returned instance from the
class driver, while 'the_clock' is the driver's private data (and
there can only be one driver).

I'll combine these into one struct to make it more clear and less
funny sounding.

> >+	return IRQ_HANDLED;
> 
> Should only return IRQ_HANDLED if you found an event.

Okay.

> >+	if (get_of_u32(node, "tclk_period",&etsects->tclk_period) ||
> >+	    get_of_u32(node, "tmr_prsc",&etsects->tmr_prsc) ||
> >+	    get_of_u32(node, "tmr_add",&etsects->tmr_add) ||
> >+	    get_of_u32(node, "cksel",&etsects->cksel) ||
> >+	    get_of_u32(node, "tmr_fiper1",&etsects->tmr_fiper1) ||
> >+	    get_of_u32(node, "tmr_fiper2",&etsects->tmr_fiper2))
> >+		return -ENODEV;
> 
> Might want to print an error so the user knows what's missing.

Okay.

> You've got two IRQs, with the same handler, and the same dev_id?
> From the manual it looks like there's one PTP interrupt per eTSEC
> (which would explain 3 interrupts on p2020).

Will reduce to just one IRQ.

> >+static struct of_device_id match_table[] = {
> >+	{ .type = "ptp_clock" },
> >+	{},
> >+};
> 
> This driver controls every possible PTP implementation?

No, I only want to match with the eTSEC clock device. Given the
compatible string above ("fsl,etsec-ptp"), what is the correct way to
do this? (pointer to an existing driver to emulate would be enough)

Thanks for your help,

Richard
