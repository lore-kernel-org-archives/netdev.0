From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] wlcore: spi: add wl18xx support
Date: Wed, 30 Mar 2016 16:02:31 +0300
Message-ID: <CANUX_P0=Xg20_ZaLNQ+wOqs4CCXeDBMnzoc=FkyT=FomvPb6FA@mail.gmail.com>
References: <1459342694-24461-1-git-send-email-eyalr@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
To: Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459342694-24461-1-git-send-email-eyalr-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2016 at 3:58 PM, Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> From: Eyal <eyalr@eyalr-VirtualBox.(none)>

Are you trying to hide or something? :)

>
> Add support for using with both wl12xx and wl18xx.
>
> - all wilink family needs special init command for entering wspi mode.
>   extra clock cycles should be sent after the spi init command while the
>   cs pin is high.
> - switch to controling the cs pin from the spi driver for achieveing the
>   above.
> - the selected cs gpio is read from the spi device-tree node using the
>   cs-gpios field and setup as a gpio.
> - See the example below for specifying the cs gpio using the cs-gpios entry
>
> &spi0   {
>         status = "okay";
>         pinctrl-names = "default";
>         pinctrl-0 = <&spi0_pins>;
>         cs-gpios = <&gpio0 5 0>;
>         #address-cells = <1>;
>         #size-cells = <0>;
>         wlcore: wlcore@0 {
>                 compatible = "ti,wl1835";
>                 vwlan-supply = <&wlan_en_reg>;
>                 spi-max-frequency = <48000000>;
>                 reg = <0>;      /* chip select 0 on spi0, ie spi0.0 */
>                 interrupt-parent = <&gpio0>;
>                 interrupts = <27 IRQ_TYPE_EDGE_RISING>;
>         };
> };
>
> Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
> ---
>  drivers/net/wireless/ti/wlcore/spi.c |  176 ++++++++++++++++++++++++++++++----
>  1 file changed, 157 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
> index 96d9c9d..6c5a369 100644
> --- a/drivers/net/wireless/ti/wlcore/spi.c
> +++ b/drivers/net/wireless/ti/wlcore/spi.c
> @@ -32,6 +32,7 @@
>  #include <linux/platform_device.h>
>  #include <linux/of_irq.h>
>  #include <linux/regulator/consumer.h>
> +#include <linux/gpio.h>
>
>  #include "wlcore.h"
>  #include "wl12xx_80211.h"
> @@ -70,16 +71,30 @@
>  #define WSPI_MAX_CHUNK_SIZE    4092
>
>  /*
> - * only support SPI for 12xx - this code should be reworked when 18xx
> - * support is introduced
> + * wl18xx driver aggregation buffer size is (13 * PAGE_SIZE) compared to
> + * (4 * PAGE_SIZE) for wl12xx, so use the larger buffer needed for wl18xx
>   */
> -#define SPI_AGGR_BUFFER_SIZE (4 * PAGE_SIZE)
> +#define SPI_AGGR_BUFFER_SIZE (13 * PAGE_SIZE)
>
>  /* Maximum number of SPI write chunks */
>  #define WSPI_MAX_NUM_OF_CHUNKS \
>         ((SPI_AGGR_BUFFER_SIZE / WSPI_MAX_CHUNK_SIZE) + 1)
>
>
> +struct wilink_familiy_data {
> +       char name[8];
> +};
> +
> +const struct wilink_familiy_data *wilink_data;
> +
> +static const struct wilink_familiy_data wl18xx_data = {
> +       .name = "wl18xx",
> +};
> +
> +static const struct wilink_familiy_data wl12xx_data = {
> +       .name = "wl12xx",
> +};
> +
>  struct wl12xx_spi_glue {
>         struct device *dev;
>         struct platform_device *core;
> @@ -120,6 +135,8 @@ static void wl12xx_spi_init(struct device *child)
>         struct spi_transfer t;
>         struct spi_message m;
>         u8 *cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
> +       struct spi_device *spi = (struct spi_device *)glue->dev;
> +       struct spi_master *master = spi->master;
>
>         if (!cmd) {
>                 dev_err(child->parent,
> @@ -127,6 +144,15 @@ static void wl12xx_spi_init(struct device *child)
>                 return;
>         }
>
> +       if (!master->cs_gpios) {
> +               dev_err(child->parent,
> +                       "spi chip select pin missing in platform data!\n");
> +               return;
> +       }
> +
> +       /* Drive CS line low */
> +       gpio_direction_output(master->cs_gpios[0], 0);
> +
>         memset(&t, 0, sizeof(t));
>         spi_message_init(&m);
>
> @@ -163,6 +189,26 @@ static void wl12xx_spi_init(struct device *child)
>         spi_message_add_tail(&t, &m);
>
>         spi_sync(to_spi_device(glue->dev), &m);
> +
> +       /* Send extra clocks with CS high. this is required by the wilink
> +        * family in order for successfully enter WSPI mode
> +        */
> +       gpio_direction_output(master->cs_gpios[0], 1);
> +
> +       memset(&m, 0, sizeof(m));
> +       spi_message_init(&m);
> +
> +       cmd[0] = 0xff;
> +       cmd[1] = 0xff;
> +       cmd[2] = 0xff;
> +       cmd[3] = 0xff;
> +       swab32s((u32 *)cmd);
> +
> +       t.tx_buf = cmd;
> +       t.len = 4;
> +       spi_message_add_tail(&t, &m);
> +       spi_sync(to_spi_device(glue->dev), &m);
> +
>         kfree(cmd);
>  }
>
> @@ -213,6 +259,16 @@ static int __must_check wl12xx_spi_raw_read(struct device *child, int addr,
>         u32 *busy_buf;
>         u32 *cmd;
>         u32 chunk_len;
> +       struct spi_device *spi = (struct spi_device *)glue->dev;
> +       struct spi_master *master = spi->master;
> +
> +       if (!master->cs_gpios) {
> +               dev_err(child->parent,
> +                       "spi chip select pin missing in platform data!\n");
> +               return -EINVAL;
> +       }
> +       /* Drive CS line low */
> +       gpio_direction_output(master->cs_gpios[0], 0);
>
>         while (len > 0) {
>                 chunk_len = min_t(size_t, WSPI_MAX_CHUNK_SIZE, len);
> @@ -267,25 +323,44 @@ static int __must_check wl12xx_spi_raw_read(struct device *child, int addr,
>                 len -= chunk_len;
>         }
>
> +       /* Drive CS line high */
> +       gpio_direction_output(master->cs_gpios[0], 1);
>         return 0;
>  }
>
> -static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,
> -                                            void *buf, size_t len, bool fixed)
> +static int __wl12xx_spi_raw_write(struct device *child, int addr,
> +                                 void *buf, size_t len, bool fixed)
>  {
>         struct wl12xx_spi_glue *glue = dev_get_drvdata(child->parent);
> -       /* SPI write buffers - 2 for each chunk */
> -       struct spi_transfer t[2 * WSPI_MAX_NUM_OF_CHUNKS];
> +       struct spi_transfer *t;
>         struct spi_message m;
>         u32 commands[WSPI_MAX_NUM_OF_CHUNKS]; /* 1 command per chunk */
>         u32 *cmd;
>         u32 chunk_len;
>         int i;
> +       struct spi_device *spi = (struct spi_device *)glue->dev;
> +       struct spi_master *master = spi->master;
> +
> +       if (!master->cs_gpios) {
> +               dev_err(child->parent,
> +                       "spi chip select pin missing in platform data!\n");
> +               return -EINVAL;
> +       }
> +
> +       /* SPI write buffers - 2 for each chunk */
> +       t = kzalloc(sizeof(*t) * 2 * WSPI_MAX_NUM_OF_CHUNKS, GFP_KERNEL);
> +       if (!t) {
> +               dev_err(child->parent,
> +                       "could not allocate spi write buffer\n");
> +               return -ENOMEM;
> +       }
> +
> +       /* Drive CS line low */
> +       gpio_direction_output(master->cs_gpios[0], 0);
>
>         WARN_ON(len > SPI_AGGR_BUFFER_SIZE);
>
>         spi_message_init(&m);
> -       memset(t, 0, sizeof(t));
>
>         cmd = &commands[0];
>         i = 0;
> @@ -318,9 +393,29 @@ static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,
>
>         spi_sync(to_spi_device(glue->dev), &m);
>
> +       /* Drive CS line high */
> +       gpio_direction_output(master->cs_gpios[0], 1);
> +
> +       kfree(t);
>         return 0;
>  }
>
> +static int __must_check wl12xx_spi_raw_write(struct device *child, int addr,
> +                                            void *buf, size_t len, bool fixed)
> +{
> +       int ret;
> +
> +       /* The ELP wakeup write may fail the first time due to internal
> +        * hardware latency. It is safer to send the wakeup command twice to
> +        * avoid unexpected failures.
> +        */
> +       if (addr == HW_ACCESS_ELP_CTRL_REG)
> +               ret = __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
> +       ret = __wl12xx_spi_raw_write(child, addr, buf, len, fixed);
> +
> +       return ret;
> +}
> +
>  /**
>   * wl12xx_spi_set_power - power on/off the wl12xx unit
>   * @child: wl12xx device handle.
> @@ -349,17 +444,38 @@ static int wl12xx_spi_set_power(struct device *child, bool enable)
>         return ret;
>  }
>
> +/**
> + * wl12xx_spi_set_block_size
> + *
> + * This function is not needed for spi mode, but need to be present.
> + * Without it defined the wlcore fallback to use the wrong packet
> + * allignment on tx.
> + */
> +static void wl12xx_spi_set_block_size(struct device *child,
> +                                     unsigned int blksz)
> +{
> +}
> +
>  static struct wl1271_if_operations spi_ops = {
>         .read           = wl12xx_spi_raw_read,
>         .write          = wl12xx_spi_raw_write,
>         .reset          = wl12xx_spi_reset,
>         .init           = wl12xx_spi_init,
>         .power          = wl12xx_spi_set_power,
> -       .set_block_size = NULL,
> +       .set_block_size = wl12xx_spi_set_block_size,
>  };
>
>  static const struct of_device_id wlcore_spi_of_match_table[] = {
> -       { .compatible = "ti,wl1271" },
> +       { .compatible = "ti,wl1271", .data = &wl12xx_data},
> +       { .compatible = "ti,wl1273", .data = &wl12xx_data},
> +       { .compatible = "ti,wl1281", .data = &wl12xx_data},
> +       { .compatible = "ti,wl1283", .data = &wl12xx_data},
> +       { .compatible = "ti,wl1801", .data = &wl18xx_data},
> +       { .compatible = "ti,wl1805", .data = &wl18xx_data},
> +       { .compatible = "ti,wl1807", .data = &wl18xx_data},
> +       { .compatible = "ti,wl1831", .data = &wl18xx_data},
> +       { .compatible = "ti,wl1835", .data = &wl18xx_data},
> +       { .compatible = "ti,wl1837", .data = &wl18xx_data},
>         { }
>  };
>  MODULE_DEVICE_TABLE(of, wlcore_spi_of_match_table);
> @@ -375,18 +491,24 @@ static int wlcore_probe_of(struct spi_device *spi, struct wl12xx_spi_glue *glue,
>                            struct wlcore_platdev_data *pdev_data)
>  {
>         struct device_node *dt_node = spi->dev.of_node;
> -       int ret;
> +       const struct of_device_id *of_id;
> +
> +       of_id = of_match_node(wlcore_spi_of_match_table, dt_node);
> +       if (!of_id)
> +               return -ENODEV;
> +
> +       wilink_data = of_id->data;
> +       dev_info(&spi->dev, "selected chip familiy is %s\n",
> +                wilink_data->name);
>
>         if (of_find_property(dt_node, "clock-xtal", NULL))
>                 pdev_data->ref_clock_xtal = true;
>
> -       ret = of_property_read_u32(dt_node, "ref-clock-frequency",
> -                                  &pdev_data->ref_clock_freq);
> -       if (IS_ERR_VALUE(ret)) {
> -               dev_err(glue->dev,
> -                       "can't get reference clock frequency (%d)\n", ret);
> -               return ret;
> -       }
> +       /* optional clock frequency params */
> +       of_property_read_u32(dt_node, "ref-clock-frequency",
> +                            &pdev_data->ref_clock_freq);
> +       of_property_read_u32(dt_node, "tcxo-clock-frequency",
> +                            &pdev_data->tcxo_clock_freq);
>
>         return 0;
>  }
> @@ -397,6 +519,7 @@ static int wl1271_probe(struct spi_device *spi)
>         struct wlcore_platdev_data pdev_data;
>         struct resource res[1];
>         int ret;
> +       struct spi_master *master = spi->master;
>
>         memset(&pdev_data, 0x00, sizeof(pdev_data));
>
> @@ -410,6 +533,12 @@ static int wl1271_probe(struct spi_device *spi)
>
>         glue->dev = &spi->dev;
>
> +       if (!master->cs_gpios) {
> +               dev_err(glue->dev,
> +                       "spi chip select pin missing in platform data!\n");
> +               return -EINVAL;
> +       }
> +
>         spi_set_drvdata(spi, glue);
>
>         /* This is the only SPI value that we need to set here, the rest
> @@ -431,15 +560,21 @@ static int wl1271_probe(struct spi_device *spi)
>                 return ret;
>         }
>
> +       if (gpio_request(master->cs_gpios[0], "spi1-cs0"))
> +               return -EINVAL;
> +
>         ret = spi_setup(spi);
>         if (ret < 0) {
>                 dev_err(glue->dev, "spi_setup failed\n");
> +               gpio_free(master->cs_gpios[0]);
>                 return ret;
>         }
>
> -       glue->core = platform_device_alloc("wl12xx", PLATFORM_DEVID_AUTO);
> +       glue->core = platform_device_alloc(wilink_data->name,
> +                                          PLATFORM_DEVID_AUTO);
>         if (!glue->core) {
>                 dev_err(glue->dev, "can't allocate platform_device\n");
> +               gpio_free(master->cs_gpios[0]);
>                 return -ENOMEM;
>         }
>
> @@ -474,14 +609,17 @@ static int wl1271_probe(struct spi_device *spi)
>
>  out_dev_put:
>         platform_device_put(glue->core);
> +       gpio_free(master->cs_gpios[0]);
>         return ret;
>  }
>
>  static int wl1271_remove(struct spi_device *spi)
>  {
>         struct wl12xx_spi_glue *glue = spi_get_drvdata(spi);
> +       struct spi_master *master = spi->master;
>
>         platform_device_unregister(glue->core);
> +       gpio_free(master->cs_gpios[0]);
>
>         return 0;
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
