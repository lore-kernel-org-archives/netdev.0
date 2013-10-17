From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] WAN: Adding support for Infineon PEF2256 E1 chipset
Date: Thu, 17 Oct 2013 11:17:01 +0100
Message-ID: <20131017101701.GB24056@e106331-lin.cambridge.arm.com>
References: <201310161525.r9GFPZI5006238@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "rob.herring@calxeda.com" <rob.herring@calxeda.com>,
	Pawel Moll <Pawel.Moll@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jerome.chantelauze@c-s.fr" <jerome.chantelauze@c-s.fr>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201310161525.r9GFPZI5006238@localhost.localdomain>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 16, 2013 at 04:25:35PM +0100, Christophe Leroy wrote:
> The patch adds WAN support for Infineon PEF2256 E1 Chipset.
> 
> Signed-off-by: Jerome Chantelauze <jerome.chantelauze@c-s.fr>
> Acked-by: Christophe Leroy <christophe.leroy@c-s.fr>

> +static ssize_t fs_attr_mode_store(struct device *dev,
> +                       struct device_attribute *attr,  const char *buf,
> +                       size_t count)
> +{
> +       struct net_device *ndev = dev_get_drvdata(dev);
> +       struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +       u32 value;
> +       int ret = kstrtol(buf, 10, (long int *)&value);

u32 is not the same as long int.

> +       int reconfigure = (value != priv->mode);
> +
> +       if (ret != 0)
> +               return ret;
> +
> +       if (value != MASTER_MODE && value != SLAVE_MODE)
> +               return -EINVAL;
> +
> +       priv->mode = value;
> +       if (reconfigure && priv->init_done) {
> +               pef2256_close(ndev);
> +               init_FALC(priv);
> +               pef2256_open(ndev);
> +       }
> +
> +       return count;

What if count is not the number of characters read?

[...]

> +
> +       /* TS 0 is reserved */
> +       if (value & 0x80000000)
> +               return -EINVAL;

Magic numbers should be turned into constants.

> +static ssize_t fs_attr_Rx_TS_show(struct device *dev,
> +                       struct device_attribute *attr, char *buf)
> +{
> +       struct net_device *ndev = dev_get_drvdata(dev);
> +       struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +
> +       return sprintf(buf, "0x%08x\n", priv->Rx_TS);
> +}
> +
> +
> +static ssize_t fs_attr_Rx_TS_store(struct device *dev,
> +                       struct device_attribute *attr,  const char *buf,
> +                       size_t count)
> +{
> +       struct net_device *ndev = dev_get_drvdata(dev);
> +       struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +       u32 value;
> +       int ret = kstrtol(buf, 10, (long int *)&value);

I'm not sure what the rules are regarding this, but why do we show this
in hexadecimal but read it in decimal?

[...]

> +int Config_HDLC(struct pef2256_dev_priv *priv)
> +{
> +       int i;
> +       int TS_idx;
> +       struct pef2256_regs *base_addr;

That sounds suspicious. Using structs for the offsets of registers isn't
very portable...

It would be preferable to #define the offsets.

> +       u8 dummy;
> +
> +       /* Set framer E1 address */
> +       base_addr = (struct pef2256_regs *)priv->base_addr;

That looks even more suspicious...

> +
> +       /* Read to remove pending IT */
> +       dummy = base_addr->ISR0;
> +       dummy = base_addr->ISR1;

You should use MMIO accessors here (readl, writel, etc). You have no
idea how the compiler may reorganise, coalese or throw away accesses,
nor how those accesses will be made. Additionally, without the requisite
barriers you have no guarantee the CPU won't reorder these accesses.

The compiler is within its rights here to throw away these accesses as
the results are never used. This is broken.

With some constants for the register offsets, this would be:

readb(base_addr + REG_ISR0);
readb(base_addr + REG_ISR1);

Which won't be reordered or thrown away by either the compiler or CPU.

> +
> +       /* Mask HDLC 1 Transmit IT */
> +       base_addr->IMR1 |= 1;
> +       base_addr->IMR1 |= 1 << 4;
> +       base_addr->IMR1 |= 1 << 5;
> +
> +       /* Mask HDLC 1 Receive IT */
> +       base_addr->IMR0 |= 1;
> +       base_addr->IMR0 |= 1 << 7;
> +       base_addr->IMR1 |= 1 << 6;
> +
> +       udelay((2 * 32) * 125);

Why the udelay, and how was the delay period (2 * 32 * 125) derived?

Is this to account for the lack of barriers, or does the hardware have a
requirement that there's a delay? 

If the former, please fix. If the later, please coment the udelay to
make this clear.

> +
> +       /* MODE.HRAC = 0 (Receiver inactive)
> +          MODE.DIV = 0 (Data normal operation)
> +          for FALC V2.2 : MODE.HDLCI = 0 (normal operation) */
> +       /* MODE.MDS2:0 = 100 (No address comparison) */
> +       /* MODE.HRAC = 1 (Receiver active) */
> +       out_8(&(base_addr->MODE), 1 << 3);

Why are you using an MMIO accessor here but not elsewhere?

Not all architectures seem to have out_8, but I think iowrite8/writeb
will work (though I'm not sure what the intended difference between
writeb and out_8 is).

> +       /* CCR1.EITS = 1 (Enable internal Time Slot 31:0 Signaling)
> +          CCR1.XMFA = 0 (No transmit multiframe alignment)
> +          CCR1.RFT1:0 = 00 (RFIFO sur 32 bytes) */
> +       /* setting up Interframe Time Fill */
> +       /* CCR1.ITF = 1 (Interframe Time Fill Continuous flag) */
> +       out_8(&(base_addr->CCR1), 0x10 | (1 << 3));
> +       /* CCR2.XCRC = 0 (Transmit CRC ON)
> +          CCR2.RCRC = 0 (Receive CRC ON, no write in RFIFO)
> +          CCR2.RADD = 0 (No write address in RFIFO) */
> +       out_8(&(base_addr->CCR2), 0x00);
> +
> +       udelay((2 * 32) * 125);

Please explain all udelay instances.

[...]

> +                               setbits8(&(base_addr->TTR1), 1 << i);

I'm not aware of a generic equivalent to setbits8, but it seems like
writeb(readb(ADDR) | bits), ADDR) would do the same.

[...]

> +static int pef2256_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> +{
> +       int ret;
> +
> +       ret = hdlc_ioctl(dev, ifr, cmd);
> +       return ret;
> +}

This seems a bit useless -- can't you just assign hdlc_ioctl to
pef2256_ops::ndo_do_ioctl directly?

> +static const struct of_device_id pef2256_match[];
> +static int pef2256_probe(struct platform_device *ofdev)

s/ofdev/pdev -- platform_device has nothing to do with OF.

> +{
> +       const struct of_device_id *match;
> +       struct pef2256_dev_priv *priv;
> +       int ret = -ENOMEM;
> +       struct net_device *netdev;
> +       hdlc_device *hdlc;
> +       int sys_ret;
> +       struct pef2256_regs *base_addr;
> +       struct device_node *np = (&ofdev->dev)->of_node;
> +       const u32 *data;
> +       int len;
> +
> +       match = of_match_device(pef2256_match, &ofdev->dev);
> +       if (!match)
> +               return -EINVAL;

Why not:

if (!pdev->dev.of_node)
	return -EINVAL;

You shouldn't have an of_node unless one of your compatible strings
matched, and this way you don't have to iterate over the list again.

> +
> +       dev_err(&ofdev->dev, "Found PEF2256\n");
> +
> +       priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +       if (!priv)
> +               return ret;
> +
> +       priv->dev = &ofdev->dev;
> +
> +       data = of_get_property(np, "data-rate", &len);
> +       if (!data || len != 4) {

Use of_property_read_u32.

> +               dev_err(&ofdev->dev, "failed to read data-rate -> using 8Mb\n");
> +               priv->data_rate = DATA_RATE_8M;
> +       } else
> +               priv->data_rate = *data;
> +
> +       data = of_get_property(np, "channel-phase", &len);
> +       if (!data || len != 4) {

Use of_property_read_u32.

> +               dev_err(&ofdev->dev, "failed to read channel phase -> using 0\n");
> +               priv->channel_phase = CHANNEL_PHASE_0;
> +       } else
> +               priv->channel_phase = *data;
> +
> +       data = of_get_property(np, "rising-edge-sync-pulse", NULL);

Use of_property_read_string.

> +       if (!data) {
> +               dev_err(&ofdev->dev, "failed to read rising edge sync pulse -> using \"transmit\"\n");
> +               strcpy(priv->rising_edge_sync_pulse, "transmit");
> +       } else if (strcmp((char *)data, "transmit") &&
> +                       strcmp((char *)data, "receive")) {
> +               dev_err(&ofdev->dev, "invalid rising edge sync pulse -> using \"transmit\"\n");
> +               strcpy(priv->rising_edge_sync_pulse, "transmit");
> +       } else
> +               strncpy(priv->rising_edge_sync_pulse, (char *)data, 10);
> +
> +       priv->irq = of_irq_to_resource(np, 0, NULL);
> +       if (!priv->irq) {
> +               dev_err(priv->dev, "no irq defined\n");
> +               return -EINVAL;
> +       }

The irq will have already been parsed, and will be in your
platform_device's set of resources. You can use platform_get_irq to get
at it rather than getting the of_ code to attempt to map it again.

Why are you storing the IRQ resource, rather than the irq itself? Surely
the irq number is easier to deal with?

> +       netdev = alloc_hdlcdev(priv);
> +       if (!netdev) {
> +               ret = -ENOMEM;
> +               return ret;

You leak priv and the priv->base_addr mapping here.

[...]

> +       ret = register_hdlc_device(netdev);
> +       if (ret < 0) {
> +               pr_err("unable to register\n");
> +               return ret;

You leak the priv, priv->base_addr, and netdev here.

> +       }
> +
> +       sys_ret = 0;
> +       sys_ret |= device_create_file(priv->dev, &dev_attr_mode);
> +       sys_ret |= device_create_file(priv->dev, &dev_attr_Tx_TS);
> +       sys_ret |= device_create_file(priv->dev, &dev_attr_Rx_TS);
> +       sys_ret |= device_create_file(priv->dev, &dev_attr_regs);

Huh? can't any of these fail individually?

> +
> +       if (sys_ret) {
> +               device_remove_file(priv->dev, &dev_attr_mode);

What about the other files?

> +               unregister_hdlc_device(priv->netdev);
> +               free_netdev(priv->netdev);

What about priv and priv->base_addr?

Why is there not a return here? We'll fall out to the main body and
return 0, as if everything's OK...

> +       }
> +
> +       priv->init_done = 0;
> +
> +       return 0;
> +}

[...]

> +
> +
> +/*
> + * Suppression du module
> + */
> +static int pef2256_remove(struct platform_device *ofdev)
> +{
> +       struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
> +       struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +
> +       device_remove_file(priv->dev, &dev_attr_Rx_TS);
> +       device_remove_file(priv->dev, &dev_attr_Tx_TS);
> +       device_remove_file(priv->dev, &dev_attr_mode);
> +
> +       unregister_hdlc_device(priv->netdev);
> +       free_netdev(priv->netdev);

What about priv and priv->base_addr?

> +
> +       /* Do E1 stuff */
> +
> +       dev_set_drvdata(&ofdev->dev, NULL);
> +       kfree(ofdev);

Is that meant to be done here? Isn't that the job of the core code?

[...]

> +static int __init pef2256_init(void)
> +{
> +       int ret;
> +       ret = platform_driver_register(&pef2256_driver);
> +       return ret;
> +}
> +module_init(pef2256_init);
> +
> +
> +static void __exit pef2256_exit(void)
> +{
> +       platform_driver_unregister(&pef2256_driver);
> +}
> +module_exit(pef2256_exit);

Use module_platform_driver?

> +/* Framer E1 registers */
> +union pef2256_Fifo {
> +       u8      XFIFO[sizeof(u16)];             /* Transmit FIFO */
> +       u8      RFIFO[sizeof(u16)];             /* Receive FIFO */
> +};

Huh? Why sizeof(u16) rather than 2?

> +struct pef2256_regs {
> +       union pef2256_Fifo      FIFO;   /* 0x00/0x01    FIFO (Tx or rx) */
> +       unsigned char   CMDR;   /* 0x02 Command Register */
> +       unsigned char   MODE;   /* 0x03 Mode Register */
> +       unsigned char   RAH1;   /* 0x04 Receive Address High 1 */
> +       unsigned char   RAH2;   /* 0x05 Receive Address High 2 */
> +       unsigned char   RAL1;   /* 0x06 Receive Address Low 1 */

[...]

Please do not use structures for calculation of register offsets.

> +       unsigned short  FEC;    /* 0x50/0x51 Framing Error Counter */
> +       unsigned short  CVC;    /* 0x52/0x53 Code Violation Counter */
> +       unsigned short  CEC1;   /* 0x54/0x55 CRC Error Counter 1 */
> +       unsigned short  EBC;    /* 0x56/0x57 E-Bit Error Counter */
> +       unsigned short  CEC2;   /* 0x58/0x59 CRC Error Counter 2 */
> +       unsigned short  CEC3;   /* 0x5A/0x5B CRC Error Counter 3 */

These may not be the size you expect.

> diff -urN a/Documentation/devicetree/bindings/net/pef2256.txt b/Documentation/devicetree/bindings/net/pef2256.txt
> --- a/Documentation/devicetree/bindings/net/pef2256.txt 1970-01-01 01:00:00.000000000 +0100
> +++ b/Documentation/devicetree/bindings/net/pef2256.txt 2013-10-13 15:05:42.000000000 +0200
> @@ -0,0 +1,29 @@
> +* Wan on Infineon pef2256 E1 controller

A brief description would be helpful. Is there any publicly available
documentation?

> +
> +Required properties:
> +- compatible: Should be "infineon,pef2256"

s/Should be/Should contain/ -- variants may exist in future.

> +- reg: Address and length of the register set for the device

Is there only the one register bank?

> +- interrupts: Should contain interrupts

How many? What do they correspond to?

> +
> +Optional properties:
> +- data-rate: Data rate on the system highway.
> +  Supported values are: 2, 4, 8, 16.
> +  8 if not defined.

What is the "system highway"? Is this configuration, or is this a
property of the device that cannot be probed?

> +- channel-phase: First time slot transmission channel phase.
> +  Supported values are: 0, 1, 2, 3, 4, 5, 6, 7.
> +  0 if not defined.

Similarly?

> +- rising-edge-sync-pulse: rising edge synchronous pulse.
> +  Supported values are: "receive", "transmit".
> +  "transmit" if not defined.

I'm not sure what this means. Could you elaborate?

Thanks,
Mark.
