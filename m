From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: [PATCH 0/2] net: smsc911x: get IRQ flags from chip if not present in IORESOURCE_IRQ
Date: Fri, 12 Apr 2013 20:05:41 +0200
Message-ID: <1365789943-3812-1-git-send-email-javier.martinez@collabora.co.uk>
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Rob Herring <robherring2@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jon Hunter <jon-hunter@ti.com>,
	devicetree-discuss@lists.ozlabs.org,
	linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:43000 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab3DLSGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 14:06:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is the second attempt to solve the issue that IRQ flags when
defined  using Device Trees, are not passed to drivers that try
to obtain them from a IORESOURCE_IRQ struct resource.

According to Documentation/devicetree/bindings/interrupt-controller/interrupts.txt
the "#interrupt-cells" property of an "interrupt-controller" is used
to define the number of cells needed to specify a single interrupt.

A commonly used variant is two cell on which #interrupt-cells = <2>
and the first cell defines the index of the interrupt in the controller
while the second cell is used to specify any of the following flags:

    - bits[3:0] trigger type and level flags
        1 = low-to-high edge triggered
        2 = high-to-low edge triggered
        4 = active high level-sensitive
        8 = active low level-sensitive

An example of an interrupt controller which use the two cell format is
the OMAP GPIO controller that allows GPIO lines to be used as IRQ
(Documentation/devicetree/bindings/gpio/gpio-omap.txt)

But setting #interrupt-cells = <2> on the OMAP GPIO device node and
specifying the GPIO-IRQ type and level flags on the second cell does not
store this value on the populated IORESOURCE_IRQ struct resource.

This is because when using an IRQ from an interrupt controller and
setting both cells (e.g:)

        interrupt-parent = <&gpio6>;
        interrupts = <16 8>;

A call to of_irq_to_resource() is made and this function calls to
irq_of_parse_and_map_type() to get the virtual IRQ mapped to the real
index for this interrupt controller. This IRQ number is populated on
the struct resource:

int of_irq_to_resource(struct device_node *dev, int index, struct resource *r)
{
        int irq = irq_of_parse_and_map(dev, index);
        ..
        r->start = r->end = irq;
}

irq_of_parse_and_map() calls to irq_create_of_mapping() which calls to
the correct xlate function handler according to "#interrupt-cells"
(irq_domain_xlate_onecell or irq_domain_xlate_twocell) and to
irq_set_irq_type() to set the IRQ type.

But the type is never returned so it can't be saved on the IRQ struct
resource flags member.

This means that drivers that want to get the IRQ edge/level flags
defined in the Device Tree from a struct resource will not be able
to get it.
    
Drivers can get the IRQ flags by using irq_get_irq_data(irq) and
irqd_get_trigger_type(irq_data) but this will unnecessary expose
irq_data to callers and also is more error prone.

This problem was first discussed here [1] and a first approach to
solved was discussed here [2]. This was by saving the IRQ edge/level
flags on the struct resource but the feedback was that IORESOURCE_IRQ
is not supposed to be used with DT but with architectures supporting ACPI/PnP.
    
So, this second patch-set is composed of the following patches:

[PATCH 1/2] genirq: add function to get IRQ edge/level flags
[PATCH 2/2] net: smsc911x: get IRQ flags from chip if not present in IORESOURCE_IRQ

And adds an irq_get_trigger_type() function to obtain the edge/level
flags for an IRQ and use it as a fallback if a driver does not find
the flags on an IORESOURCE_IRQ struct resource.

Thanks a lot and best regards,
Javier

[1]: https://patchwork.kernel.org/patch/2194911/
[2]: http://permalink.gmane.org/gmane.linux.ports.arm.omap/96908
