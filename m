From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 05/10] gpio: Introduce SAM gpio driver
Date: Fri, 21 Oct 2016 01:06:40 +0200
Message-ID: <CACRpkdZa9OdV3j7X4ptczhEOCBZfd=KKbp3jizQYSQP-xoTmCg@mail.gmail.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com> <1475853518-22264-6-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lee Jones <lee.jones@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Wolfram Sang <wsa@the-dreams.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wim Van Sebroeck <wim@iguana.be>,
        Peter Rosin <peda@axentia.se>,
        Debjit Ghosh <dghosh@juniper.net>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
        "linux-i2c@vger.kernel.or
To: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <1475853518-22264-6-git-send-email-pantelis.antoniou@konsulko.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

n Fri, Oct 7, 2016 at 5:18 PM, Pantelis Antoniou
<pantelis.antoniou@konsulko.com> wrote:

> From: Guenter Roeck <groeck@juniper.net>
>
> The SAM GPIO IP block is present in the Juniper PTX series
> of routers as part of the SAM FPGA.
>
> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
> Signed-off-by: Guenter Roeck <groeck@juniper.net>
> Signed-off-by: Rajat Jain <rajatjain@juniper.net>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>

First copy/paste my other review comments on the previous driver
I reviewed, this seems to have pretty much all the same issues.

> +config GPIO_SAM
> +       tristate "SAM FPGA GPIO"
> +       depends on MFD_JUNIPER_SAM
> +       default y if MFD_JUNIPER_SAM

I suspect this should use
select GPIOLIB_IRQCHIP

> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/pci.h>
> +#include <linux/gpio.h>

<linux/gpio/driver.h>

> +#include <linux/interrupt.h>
> +#include <linux/irqdomain.h>

Not needed with GPIOLIB_IRQCHIP

> +#include <linux/errno.h>
> +#include <linux/of_device.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_gpio.h>
> +#include <linux/io.h>
> +#include <linux/module.h>
> +#include <linux/sched.h>

Why?

> +#include <linux/mfd/sam.h>
> +
> +/* gpio status/configuration */
> +#define SAM_GPIO_NEG_EDGE      (1 << 8)
> +#define SAM_GPIO_NEG_EDGE_EN   (1 << 7)
> +#define SAM_GPIO_POS_EDGE      (1 << 6)
> +#define SAM_GPIO_POS_EDGE_EN   (1 << 5)

Interrupt triggers I suppose.

> +#define SAM_GPIO_BLINK         (1 << 4)

Cool, we don't support that in gpiolib as of now.
Maybe we should.

> +#define SAM_GPIO_OUT           (1 << 3)
> +#define SAM_GPIO_OUT_TS                (1 << 2)

OUT_TS ... what does TS mean here?

> +#define SAM_GPIO_DEBOUNCE_EN   (1 << 1)
> +#define SAM_GPIO_IN            (1 << 0)
> +
> +#define SAM_GPIO_BASE          0x1000

Base into what, and why is this not coming from PCI
or the device tree?

> +#define SAM_MAX_NGPIO          512

Why do we need to know this and what does it really mean?
That is the max number the GPIO subsystem can handle by
the way.

> +#define SAM_GPIO_ADDR(addr, nr)        ((addr) + SAM_GPIO_BASE + (nr) * sizeof(u32))

Why can't we just offset the address earlier, ah well it's OK.

> +struct sam_gpio_irq_group {
> +       int start;              /* 1st gpio pin */
> +       int count;              /* # of pins in group */
> +       int num_enabled;        /* # of enabled interrupts */
> +};
> +
> +/**
> + * struct sam_gpio - GPIO private data structure.
> + * @base:                      PCI base address of Memory mapped I/O register.
> + * @dev:                       Pointer to device structure.
> + * @gpio:                      Data for GPIO infrastructure.
> + * @gpio_base:                 1st gpio pin
> + * @gpio_count:                        # of gpio pins
> + * @irq_lock:                  Lock used by interrupt subsystem
> + * @domain:                    Pointer to interrupt domain
> + * @irq:                       Interrupt # from parent
> + * @irq_high:                  Second interrupt # from parent
> + *                             (currently unused)
> + * @irq_group:                 Interrupt group descriptions
> + *                             (one group per interrupt bit)
> + * @irq_type:                  The interrupt type for each gpio pin
> + */

Why do you need to keep all of this around? Is is all really
used? gpio_base makes me nervous we generally use dynamic
allocation of GPIO numbers these days.

> +struct sam_gpio {
> +       void __iomem *base;
> +       struct device *dev;
> +       struct gpio_chip gpio;
> +       int gpio_base;
> +       int gpio_count;
> +       struct mutex irq_lock;
> +       struct irq_domain *domain;
> +       int irq;
> +       int irq_high;
> +       struct sam_gpio_irq_group irq_group[18];
> +       u8 irq_type[SAM_MAX_NGPIO];
> +       struct sam_platform_data *pdata;
> +       const char **names;
> +       u32 *export_flags;
> +};
> +#define to_sam(chip)   container_of((chip), struct sam_gpio, gpio)

Instead of this use gpiochip_get_data(). Applies everywhere.

> +static void sam_gpio_bitop(struct sam_gpio *sam, unsigned int nr,
> +                          u32 bit, bool set)
> +{
> +       u32 reg;
> +
> +       reg = ioread32(SAM_GPIO_ADDR(sam->base, nr));
> +       if (set)
> +               reg |= bit;
> +       else
> +               reg &= ~bit;
> +       iowrite32(reg, SAM_GPIO_ADDR(sam->base, nr));
> +       ioread32(SAM_GPIO_ADDR(sam->base, nr));
> +}

Does that rally need a helper function?

Use BIT() and inline like I explained in the previous patch.

> +static void sam_gpio_setup(struct sam_gpio *sam)
> +{
> +       struct gpio_chip *chip = &sam->gpio;
> +
> +       chip->parent = sam->dev;
> +       chip->label = dev_name(sam->dev);
> +       chip->owner = THIS_MODULE;
> +       chip->direction_input = sam_gpio_direction_input;
> +       chip->get = sam_gpio_get;
> +       chip->direction_output = sam_gpio_direction_output;

Implement also chip->get_direction

> +       chip->set = sam_gpio_set;
> +       chip->set_debounce = sam_gpio_debounce;
> +       chip->dbg_show = NULL;
> +       chip->base = sam->gpio_base;

Oh no, why. Use -1 please and let gpiolib decide...

> +       chip->ngpio = sam->gpio_count;
> +#ifdef CONFIG_OF_GPIO
> +       chip->of_node = sam->dev->of_node;
> +#endif

I doubt this #ifdef actually. If the driver needs CONFIG_OF_GPIO to
work it should just depend on it in Kconfig.

> +static int sam_of_get_exports(struct device *dev, struct sam_gpio *sam)
> +{
> +       struct device_node *child, *exports;
> +       int err = 0;
> +
> +       if (dev->of_node == NULL)
> +               return 0;       /* No FDT node, we are done */
> +
> +       exports = of_get_child_by_name(dev->of_node, "gpio-exports");
> +       if (exports == NULL)
> +               return 0;       /* No exports, we are done */
> +
> +       if (of_get_child_count(exports) == 0)
> +               return 0;       /* No children, we are done */
> +
> +       sam->names = devm_kzalloc(dev, sizeof(char *) * sam->gpio_count,
> +                                 GFP_KERNEL);
> +       if (sam->names == NULL) {
> +               err = -ENOMEM;
> +               goto error;
> +       }
> +       sam->export_flags =
> +               devm_kzalloc(dev, sizeof(u32) * sam->gpio_count, GFP_KERNEL);
> +       if (sam->export_flags == NULL) {
> +               err = -ENOMEM;
> +               goto error;
> +       }
> +       for_each_child_of_node(exports, child) {
> +               const char *label;
> +               u32 pin, flags;
> +
> +               label = of_get_property(child, "label", NULL) ? : child->name;
> +               err = of_property_read_u32_index(child, "pin", 0, &pin);
> +               if (err)
> +                       break;
> +               if (pin >= sam->gpio_count) {
> +                       err = -EINVAL;
> +                       break;
> +               }
> +               err = of_property_read_u32_index(child, "pin", 1, &flags);
> +               if (err)
> +                       break;
> +               /*
> +                * flags:
> +                * GPIOF_DIR_IN                 bit 0=1
> +                * GPIOF_DIR_OUT                bit 0=0
> +                *      GPIOF_INIT_HIGH         bit 1=1
> +                * GPIOF_ACTIVE_LOW             bit 2=1
> +                * GPIOF_OPEN_DRAIN             bit 3=1
> +                * GPIOF_OPEN_SOURCE            bit 4=1
> +                * GPIOF_EXPORT                 bit 5=1
> +                * GPIOF_EXPORT_CHANGEABLE      bit 6=1
> +                */
> +               sam->names[pin] = label;
> +               sam->export_flags[pin] = flags;
> +       }
> +error:
> +       of_node_put(exports);
> +       return err;
> +}

What? NAK never in my life. This looks like an old hack to
export stuff to userspace. We don't do that. The kernel supports
gpio-line-names to name lines in the device tree, and you can use
the new chardev ABI to access it from userspace, sysfs is dead.

Delete this function entirely.

> +static int sam_gpio_of_init(struct device *dev, struct sam_gpio *sam)
> +{
> +       int err;
> +       u32 val;
> +       const u32 *igroup;
> +       u32 group, start, count;
> +       int i, iglen, ngpio;
> +
> +       if (of_have_populated_dt() && !dev->of_node) {
> +               dev_err(dev, "No device node\n");
> +               return -ENODEV;
> +       }

So obviously this driver Kconfig should depend on OF_GPIO.

> +
> +       err = of_property_read_u32(dev->of_node, "gpio-base", &val);
> +       if (err)
> +               val = -1;
> +       sam->gpio_base = val;

NAK, No Linux bases in the device tree. Only use -1.

> +       err = of_property_read_u32(dev->of_node, "gpio-count", &val);
> +       if (!err) {
> +               if (val > SAM_MAX_NGPIO)
> +                       val = SAM_MAX_NGPIO;
> +               sam->gpio_count = val;
> +       }

As described in the generic bindings, use "ngpios" for this if you need it.

> +       igroup = of_get_property(dev->of_node, "gpio-interrupts", &iglen);

NAK on that binding.

> +       if (igroup) {
> +               iglen /= sizeof(u32);
> +               if (iglen < 3 || iglen % 3)
> +                       return -EINVAL;
> +               iglen /= 3;
> +               for (i = 0; i < iglen; i++) {
> +                       group = be32_to_cpu(igroup[i * 3]);
> +                       if (group >= ARRAY_SIZE(sam->irq_group))
> +                               return -EINVAL;
> +                       start = be32_to_cpu(igroup[i * 3 + 1]);
> +                       count = be32_to_cpu(igroup[i * 3 + 2]);
> +                       if (start >= sam->gpio_count || count == 0 ||
> +                           start + count > sam->gpio_count)
> +                               return -EINVAL;
> +                       sam->irq_group[group].start = start;
> +                       sam->irq_group[group].count = count;
> +               }
> +       }

Do not invent custom interrupt bindings like this. Use the
standard device tree mechanism to resolve IRQs from the parent
controller. Maybe you also need to use hierarchical irqdomain
in Linux.

> +static int sam_gpio_pin_to_irq_bit(struct sam_gpio *sam, int pin)
> +{
> +       int bit;
> +
> +       for (bit = 0; bit < ARRAY_SIZE(sam->irq_group); bit++) {
> +               struct sam_gpio_irq_group *irq_group = &sam->irq_group[bit];
> +
> +               if (irq_group->count &&
> +                   pin >= irq_group->start &&
> +                   pin <= irq_group->start + irq_group->count)
> +                       return bit;
> +       }
> +       return -EINVAL;
> +}
> +
> +static bool sam_gpio_irq_handle_group(struct sam_gpio *sam,
> +                                     struct sam_gpio_irq_group *irq_group)
> +{
> +       unsigned int virq = 0;
> +       bool handled = false;
> +       bool repeat;
> +       int i;
> +
> +       /* no irq_group for the interrupt bit */
> +       if (!irq_group->count)
> +               return false;
> +
> +       WARN_ON(irq_group->num_enabled == 0);
> +       do {
> +               repeat = false;
> +               for (i = 0; i < irq_group->count; i++) {
> +                       int pin = irq_group->start + i;
> +                       bool low, high;
> +                       u32 regval;
> +                       u8 type;
> +
> +                       regval = ioread32(SAM_GPIO_ADDR(sam->base, pin));
> +                       /*
> +                        * write back status to clear POS_EDGE and NEG_EDGE
> +                        * status for this GPIO pin (status bits are
> +                        * clear-on-one). This is necessary to clear the
> +                        * high level interrupt status.
> +                        * Also consider the interrupt to be handled in that
> +                        * case, even if there is no taker.
> +                        */
> +                       if (regval & (SAM_GPIO_POS_EDGE | SAM_GPIO_NEG_EDGE)) {
> +                               iowrite32(regval,
> +                                         SAM_GPIO_ADDR(sam->base, pin));
> +                               ioread32(SAM_GPIO_ADDR(sam->base, pin));
> +                               handled = true;
> +                       }
> +
> +                       /*
> +                        * Check if the pin changed its state.
> +                        * If it did, and if the expected condition applies,
> +                        * generate a virtual interrupt.
> +                        * A pin can only generate an interrupt if
> +                        * - interrupts are enabled for it
> +                        * - it is configured as input
> +                        */
> +
> +                       if (!sam->irq_type[pin])
> +                               continue;
> +                       if (!(regval & SAM_GPIO_OUT_TS))
> +                               continue;
> +
> +                       high = regval & (SAM_GPIO_IN | SAM_GPIO_POS_EDGE);
> +                       low = !(regval & SAM_GPIO_IN) ||
> +                               (regval & SAM_GPIO_NEG_EDGE);
> +                       type = sam->irq_type[pin];
> +                       if (((type & IRQ_TYPE_EDGE_RISING) &&
> +                            (regval & SAM_GPIO_POS_EDGE)) ||
> +                           ((type & IRQ_TYPE_EDGE_FALLING) &&
> +                            (regval & SAM_GPIO_NEG_EDGE)) ||
> +                           ((type & IRQ_TYPE_LEVEL_LOW) && low) ||
> +                           ((type & IRQ_TYPE_LEVEL_HIGH) && high)) {


This if() clause does not look sane, you have to see that.
If you think this is proper then explain with detailed comments
what is going on.

> +                               virq = irq_find_mapping(sam->domain, pin);
> +                               handle_nested_irq(virq);
> +                               if (type & (IRQ_TYPE_LEVEL_LOW
> +                                           | IRQ_TYPE_LEVEL_HIGH))
> +                                       repeat = true;
> +                       }
> +               }
> +               schedule();

Why? Voluntary preemption? Just use a threaded interrupt handler
instead.

> +       } while (repeat);
> +
> +       return handled;
> +}
> +
> +static irqreturn_t sam_gpio_irq_handler(int irq, void *data)
> +{
> +       struct sam_gpio *sam = data;
> +       struct sam_platform_data *pdata = sam->pdata;
> +       irqreturn_t ret = IRQ_NONE;
> +       bool handled;
> +       u32 status;
> +
> +       do {
> +               handled = false;
> +               status = pdata->irq_status(sam->dev->parent, SAM_IRQ_GPIO,
> +                                          sam->irq);
> +               pdata->irq_status_clear(sam->dev->parent, SAM_IRQ_GPIO,
> +                                       sam->irq, status);
> +               while (status) {
> +                       unsigned int bit;
> +
> +                       bit = __ffs(status);
> +                       status &= ~(1 << bit);
> +                       handled =
> +                         sam_gpio_irq_handle_group(sam, &sam->irq_group[bit]);
> +                       if (handled)
> +                               ret = IRQ_HANDLED;
> +               }
> +       } while (handled);

This handled business looks fragile. But OK.

It is a simple IRQ handler, this driver should definately use
GPIOLIB_IRQCHIP. Please look at other drivers doing that
for inspiration. It is also well described in
Documenation/gpio/driver.txt

> +static int sam_gpio_to_irq(struct gpio_chip *chip, unsigned int offset)
> +{
> +       struct sam_gpio *sam = to_sam(chip);
> +
> +       return irq_create_mapping(sam->domain, offset);
> +}

With GPIOLIB_IRQCHIP you do not need to implement .to_irq()

> +static void sam_irq_mask(struct irq_data *data)
> +{
> +       struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
> +       struct sam_platform_data *pdata = sam->pdata;
> +       int bit = sam_gpio_pin_to_irq_bit(sam, data->hwirq);
> +
> +       if (bit < 0)
> +               return;
> +
> +       if (--sam->irq_group[bit].num_enabled <= 0) {
> +               pdata->disable_irq(sam->dev->parent, SAM_IRQ_GPIO, sam->irq,
> +                                  1 << bit);

Just BIT(bit)

> +static void sam_irq_unmask(struct irq_data *data)
> +{
> +       struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
> +       struct sam_platform_data *pdata = sam->pdata;
> +       int bit = sam_gpio_pin_to_irq_bit(sam, data->hwirq);
> +
> +       if (bit < 0)
> +               return;

Do you expect this to happen a lot? Else just delete the check or print
an error message.

> +
> +       sam->irq_group[bit].num_enabled++;
> +       pdata->enable_irq(sam->dev->parent, SAM_IRQ_GPIO, sam->irq, 1 << bit);

Dito.

> +static int sam_irq_set_type(struct irq_data *data, unsigned int type)
> +{
> +       struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
> +       int bit = sam_gpio_pin_to_irq_bit(sam, data->hwirq);
> +
> +       if (bit < 0)
> +               return bit;
> +
> +       sam->irq_type[data->hwirq] = type & 0x0f;


Why storing this and going to all that trouble?

> +       sam_gpio_bitop(sam, data->hwirq, SAM_GPIO_OUT_TS, true);
> +       sam_gpio_bitop(sam, data->hwirq, SAM_GPIO_DEBOUNCE_EN, type & 0x10);
> +       sam_gpio_bitop(sam, data->hwirq,
> +                      SAM_GPIO_POS_EDGE_EN | SAM_GPIO_POS_EDGE,
> +                      type & (IRQ_TYPE_EDGE_RISING | IRQ_TYPE_LEVEL_HIGH));
> +       sam_gpio_bitop(sam, data->hwirq,
> +                      SAM_GPIO_NEG_EDGE_EN | SAM_GPIO_NEG_EDGE,
> +                      type & (IRQ_TYPE_EDGE_FALLING | IRQ_TYPE_LEVEL_LOW));
> +
> +       return 0;
> +}

Just set up different handlers depending on edge. This likely simplifies your
IRQ handler code as well, as a special function (.irq_ack()) gets called for
edge IRQs.

Look how drivers/gpio/gpio-pl061.c does it.

> +static void sam_irq_bus_lock(struct irq_data *data)
> +{
> +       struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
> +
> +       mutex_lock(&sam->irq_lock);
> +}
> +
> +static void sam_irq_bus_unlock(struct irq_data *data)
> +{
> +       struct sam_gpio *sam = irq_data_get_irq_chip_data(data);
> +
> +       /* Synchronize interrupts to chip */
> +
> +       mutex_unlock(&sam->irq_lock);
> +}

Aha OK if it's necessary then we need to do this.

> +static struct irq_chip sam_irq_chip = {
> +       .name = "gpio-sam",

Maybe this should have an instance number or something.
Just an idea no requirement.

> +       .irq_mask = sam_irq_mask,
> +       .irq_unmask = sam_irq_unmask,

So I think this needs .irq_ack() to solve the mess above in
the interrupt handler.

> +       .irq_set_type = sam_irq_set_type,
> +       .irq_bus_lock = sam_irq_bus_lock,
> +       .irq_bus_sync_unlock = sam_irq_bus_unlock,
> +};
> +
> +static int sam_gpio_irq_map(struct irq_domain *domain, unsigned int irq,
> +                           irq_hw_number_t hwirq)
> +{
> +       irq_set_chip_data(irq, domain->host_data);
> +       irq_set_chip(irq, &sam_irq_chip);
> +       irq_set_nested_thread(irq, true);
> +
> +       irq_set_noprobe(irq);
> +
> +       return 0;
> +}

This will not be needed if you use GPIOLIB_IRQCHIP

> +static const struct irq_domain_ops sam_gpio_irq_domain_ops = {
> +       .map = sam_gpio_irq_map,
> +       .xlate = irq_domain_xlate_twocell,
> +};

Nor this.

> +static int sam_gpio_irq_setup(struct device *dev, struct sam_gpio *sam)
> +{
> +       int ret;
> +
> +       sam->domain = irq_domain_add_linear(dev->of_node,
> +                                           sam->gpio_count,
> +                                           &sam_gpio_irq_domain_ops,
> +                                           sam);
> +       if (sam->domain == NULL)
> +               return -ENOMEM;

Nor this.

> +       ret = devm_request_threaded_irq(dev, sam->irq, NULL,
> +                                       sam_gpio_irq_handler,
> +                                       IRQF_ONESHOT,
> +                                       dev_name(dev), sam);
> +       if (ret)
> +               goto out_remove_domain;

Are you not setting .can_sleep on the gpiochip?

> +
> +       sam->gpio.to_irq = sam_gpio_to_irq;
> +
> +       if (!try_module_get(dev->parent->driver->owner)) {
> +               ret = -EINVAL;
> +               goto out_remove_domain;
> +       }

Why? Is that the MFD device? Isn't the device core
handling this?

> +static int sam_gpio_unexport(struct sam_gpio *sam)
> +{
> +       int i;
> +
> +       if (!sam->export_flags)
> +               return 0;
> +
> +       /* un-export all auto-exported pins */
> +       for (i = 0; i < sam->gpio_count; i++) {
> +               struct gpio_desc *desc = gpio_to_desc(sam->gpio.base + i);
> +
> +               if (desc == NULL)
> +                       continue;
> +
> +               if (sam->export_flags[i] & GPIOF_EXPORT)
> +                       gpiochip_free_own_desc(desc);
> +       }
> +       return 0;
> +}
> +
> +static int sam_gpio_export(struct sam_gpio *sam)
> +{
> +       int i, ret;
> +
> +       if (!sam->export_flags)
> +               return 0;
> +
> +       /* auto-export pins as requested */
> +
> +       for (i = 0; i < sam->gpio_count; i++) {
> +               u32 flags = sam->export_flags[i];
> +               struct gpio_desc *desc;
> +
> +               /* request and initialize exported pins */
> +               if (!(flags & GPIOF_EXPORT))
> +                       continue;
> +
> +               desc  = gpiochip_request_own_desc(&sam->gpio, i, "sam-export");
> +               if (IS_ERR(desc)) {
> +                       ret = PTR_ERR(desc);
> +                       goto error;
> +               }
> +               if (flags & GPIOF_DIR_IN) {
> +                       ret = gpiod_direction_input(desc);
> +                       if (ret)
> +                               goto error;
> +               } else {
> +                       ret = gpiod_direction_output(desc, flags &
> +                                                   (GPIOF_OUT_INIT_HIGH |
> +                                                    GPIOF_ACTIVE_LOW));
> +                       if (ret)
> +                               goto error;
> +               }
> +               ret = gpiod_export(desc, flags & GPIOF_EXPORT_CHANGEABLE);
> +
> +               if (ret)
> +                       goto error;
> +       }
> +       return 0;
> +
> +error:
> +       sam_gpio_unexport(sam);
> +       return ret;
> +}

Just delete this. Use the new chardev ABI to access GPIOs from
userspace as explained earlier.

> +static int sam_gpio_probe(struct platform_device *pdev)
> +{
> +       struct device *dev = &pdev->dev;
> +       struct sam_gpio *sam;
> +       struct resource *res;
> +       int ret;
> +       struct sam_platform_data *pdata = dev_get_platdata(&pdev->dev);
> +
> +       sam = devm_kzalloc(dev, sizeof(*sam), GFP_KERNEL);
> +       if (sam == NULL)
> +               return -ENOMEM;

if (!sam)
  return -ENOMEM;

> +       sam->dev = dev;
> +       sam->pdata = pdata;
> +       platform_set_drvdata(pdev, sam);
> +
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       if (!res)
> +               return -ENODEV;
> +
> +       sam->irq = platform_get_irq(pdev, 0);
> +       sam->irq_high = platform_get_irq(pdev, 1);
> +
> +       sam->base = devm_ioremap_nocache(dev, res->start, resource_size(res));
> +       if (!sam->base)
> +               return -ENOMEM;
> +
> +       mutex_init(&sam->irq_lock);
> +
> +       ret = sam_gpio_of_init(dev, sam);
> +       if (ret)
> +               return ret;
> +
> +       sam_gpio_setup(sam);
> +
> +       if (pdata && sam->irq >= 0 && of_find_property(dev->of_node,
> +                                             "interrupt-controller", NULL)) {
> +               ret = sam_gpio_irq_setup(dev, sam);
> +               if (ret < 0)
> +                       return ret;
> +       }

This is fair, but do it after adding the gpiochip and use GPIOLIB_IRQCHIP
accessors gpiochip_irqchip_add() and gpiochip_set_chained_irqchip().

Yours,
Linus Walleij
