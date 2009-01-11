From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Sun, 11 Jan 2009 17:42:44 +0100
Message-ID: <5a4c581d0901110842i5520cea1uff89d5772d0f3b6e@mail.gmail.com>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
	 <20090109.140422.60087297.davem@davemloft.net>
	 <43805.1231672258@turing-police.cc.vt.edu>
	 <20090111.040842.86784676.davem@davemloft.net>
	 <1231676698.25018.147.camel@macbook.infradead.org>
	 <1231678799.25018.195.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, Valdis.Kletnieks@vt.edu,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:34883 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbZAKQmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 11:42:47 -0500
In-Reply-To: <1231678799.25018.195.camel@macbook.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 1:59 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Sun, 2009-01-11 at 12:25 +0000, David Woodhouse wrote:
>> I'll take a look and see if I can remedy that. Then we wouldn't _need_
>> the FIRMWARE_IN_KERNEL option.
>
> How about this? If it fails to load the firmware from userspace during
> the initialisation, it'll try again later in tg3_open().
>
> I _think_ that's fine, because we don't do anything else in the early
> initialisation which requires the firmware to be loaded.
>
> So if you build with CONFIG_TIGON3=y, CONFIG_FIRMWARE_IN_KERNEL=n, you
> should see it fail to load the firmware at boot, but then it should load
> it successfully when you bring the device up.
>
> Untested-but-otherwise-Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 5e2dbae..f99218c 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -7535,11 +7535,45 @@ static int tg3_test_msi(struct tg3 *tp)
>        return err;
>  }
>
> +static int tg3_request_firmware(struct tg3 *tp)
> +{
> +       const __be32 *fw_data;
> +
> +       if (request_firmware(&tp->fw, tp->fw_needed, &tp->pdev->dev)) {
> +               printk(KERN_ERR "tg3: Failed to load firmware \"%s\"\n",
> +                      tp->fw_needed);
> +               return -ENOENT;
> +       }
> +
> +       fw_data = (void *)tp->fw->data;
> +
> +       /* Firmware blob starts with version numbers, followed by
> +          start address and _full_ length including BSS sections
> +          (which must be longer than the actual data, of course */
> +
> +       tp->fw_len = be32_to_cpu(fw_data[2]);   /* includes bss */
> +       if (tp->fw_len < (tp->fw->size - 12)) {
> +               printk(KERN_ERR "tg3: bogus length %d in \"%s\"\n",
> +                      tp->fw_len, tp->fw_needed);
> +               return -EINVAL;
> +       }
> +
> +       /* We no longer need firmware; we have it. */
> +       tp->fw_needed = NULL;
> +       return 0;
> +}
> +
>  static int tg3_open(struct net_device *dev)
>  {
>        struct tg3 *tp = netdev_priv(dev);
>        int err;
>
> +       if (tp->fw_needed) {
> +               err = tg3_request_firmware(tp);
> +               if (err)
> +                       return err;
> +       }
> +
>        netif_carrier_off(tp->dev);
>
>        err = tg3_set_power_state(tp, PCI_D0);
> @@ -12934,7 +12968,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>        struct net_device *dev;
>        struct tg3 *tp;
>        int err, pm_cap;
> -       const char *fw_name = NULL;
>        char str[40];
>        u64 dma_mask, persist_dma_mask;
>
> @@ -13091,7 +13124,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>        tg3_init_bufmgr_config(tp);
>
>        if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
> -               fw_name = FIRMWARE_TG3;
> +               tp->fw_needed = FIRMWARE_TG3;
>
>        if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
>                tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
> @@ -13107,34 +13140,19 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>        }
>        if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
>                if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
> -                       fw_name = FIRMWARE_TG3TSO5;
> +                       tp->fw_needed = FIRMWARE_TG3TSO5;
>                else
> -                       fw_name = FIRMWARE_TG3TSO;
> +                       tp->fw_needed = FIRMWARE_TG3TSO;
>        }
>
> -       if (fw_name) {
> -               const __be32 *fw_data;
> -
> -               err = request_firmware(&tp->fw, fw_name, &tp->pdev->dev);
> -               if (err) {
> -                       printk(KERN_ERR "tg3: Failed to load firmware \"%s\"\n",
> -                              fw_name);
> -                       goto err_out_iounmap;
> -               }
> -
> -               fw_data = (void *)tp->fw->data;
> -
> -               /* Firmware blob starts with version numbers, followed by
> -                  start address and _full_ length including BSS sections
> -                  (which must be longer than the actual data, of course */
> -
> -               tp->fw_len = be32_to_cpu(fw_data[2]);   /* includes bss */
> -               if (tp->fw_len < (tp->fw->size - 12)) {
> -                       printk(KERN_ERR "tg3: bogus length %d in \"%s\"\n",
> -                              tp->fw_len, fw_name);
> -                       err = -EINVAL;
> +       if (tp->fw_needed) {
> +               err = tg3_request_firmware(tp);
> +               /* Failure to load firmware at this stage is not fatal; we'll
> +                  try again in tg3_open(). So if you have the driver built
> +                  into the kernel, you can still get the firmware loaded
> +                  after userspace is running, when the device comes up. */
> +               if (err != -ENOENT)
>                        goto err_out_fw;
> -               }
>        }
>
>        /* TSO is on by default on chips that support hardware TSO.

Patches cleanly but doesn't build in 2.6.29-rc1:

  CC      drivers/leds/led-core.o
  CC      drivers/leds/led-class.o
  LD      drivers/leds/built-in.o
  CC      drivers/net/tg3.o
drivers/net/tg3.c: In function 'tg3_request_firmware':
drivers/net/tg3.c:7542: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c:7544: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c:7557: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c:7562: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c: In function 'tg3_open':
drivers/net/tg3.c:7571: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c: In function 'tg3_init_one':
drivers/net/tg3.c:13127: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c:13143: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c:13145: error: 'struct tg3' has no member named 'fw_needed'
drivers/net/tg3.c:13148: error: 'struct tg3' has no member named 'fw_needed'
make[2]: *** [drivers/net/tg3.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
[asuardi@sandman linux-2.6.29-rc1]$


Indeed, struct tg3 in tg3.h doesn't have fw_needed here...


--alessandro

 "Sun keeps rising in the west / I keep on waking fully confused"

   (The Replacements, "Within Your Reach")
