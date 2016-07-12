From: Guodong Xu <guodong.xu@linaro.org>
Subject: Re: [PATCH 1/2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Tue, 12 Jul 2016 13:31:03 +0800
Message-ID: <CAFGCpxxZthBfxD2kK7CAWZwhGPx9Td8i=YDvaC4RbQZQEMSKMQ@mail.gmail.com>
References: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	devicetree@vger.kernel.org,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Guodong Xu <guodong.xu@linaro.org>
To: Marcel Holtmann <marcel@holtmann.org>, gustavo@padovan.org,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xu Wei <xuwei5@hisilicon.com>,
	Rob Herring <robh+dt@kernel.org>,
	=?UTF-8?Q?Pawe=C5=82_Moll?= <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Haojian Zhuang <haojian.zhuang@linaro.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear maintainers,

Would you have a review on this?

-Guodong

On 23 June 2016 at 12:58, Guodong Xu <guodong.xu@linaro.org> wrote:
> Two LED triggers are defined: tx_led and rx_led. Upon frames
> available in HCI core layer, for tx or for rx, the combined LED
> can blink.
>
> Verified on HiKey, 96boards. It uses hi6220 SoC and TI WL1835 combo
> chip.
>
> Signed-off-by: Guodong Xu <guodong.xu@linaro.org>
> ---
>  include/net/bluetooth/hci_core.h |  1 +
>  net/bluetooth/hci_core.c         |  3 +++
>  net/bluetooth/leds.c             | 15 +++++++++++++++
>  net/bluetooth/leds.h             |  2 ++
>  4 files changed, 21 insertions(+)
>
> diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
> index dc71473..37b8dd9 100644
> --- a/include/net/bluetooth/hci_core.h
> +++ b/include/net/bluetooth/hci_core.h
> @@ -398,6 +398,7 @@ struct hci_dev {
>         bdaddr_t                rpa;
>
>         struct led_trigger      *power_led;
> +       struct led_trigger      *tx_led, *rx_led;
>
>         int (*open)(struct hci_dev *hdev);
>         int (*close)(struct hci_dev *hdev);
> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> index 45a9fc6..c6e1210 100644
> --- a/net/bluetooth/hci_core.c
> +++ b/net/bluetooth/hci_core.c
> @@ -3248,6 +3248,7 @@ int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb)
>         skb_queue_tail(&hdev->rx_q, skb);
>         queue_work(hdev->workqueue, &hdev->rx_work);
>
> +       hci_leds_blink_oneshot(hdev->rx_led);
>         return 0;
>  }
>  EXPORT_SYMBOL(hci_recv_frame);
> @@ -3325,6 +3326,8 @@ static void hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
>                 BT_ERR("%s sending frame failed (%d)", hdev->name, err);
>                 kfree_skb(skb);
>         }
> +
> +       hci_leds_blink_oneshot(hdev->tx_led);
>  }
>
>  /* Send HCI command */
> diff --git a/net/bluetooth/leds.c b/net/bluetooth/leds.c
> index 8319c84..c4825d5 100644
> --- a/net/bluetooth/leds.c
> +++ b/net/bluetooth/leds.c
> @@ -19,6 +19,8 @@ struct hci_basic_led_trigger {
>  #define to_hci_basic_led_trigger(arg) container_of(arg, \
>                         struct hci_basic_led_trigger, led_trigger)
>
> +#define BLUETOOTH_BLINK_DELAY  50 /* ms */
> +
>  void hci_leds_update_powered(struct hci_dev *hdev, bool enabled)
>  {
>         if (hdev->power_led)
> @@ -37,6 +39,15 @@ static void power_activate(struct led_classdev *led_cdev)
>         led_trigger_event(led_cdev->trigger, powered ? LED_FULL : LED_OFF);
>  }
>
> +void hci_leds_blink_oneshot(struct led_trigger *trig)
> +{
> +       unsigned long led_delay = BLUETOOTH_BLINK_DELAY;
> +
> +       if (!trig)
> +               return;
> +       led_trigger_blink_oneshot(trig, &led_delay, &led_delay, 0);
> +}
> +
>  static struct led_trigger *led_allocate_basic(struct hci_dev *hdev,
>                         void (*activate)(struct led_classdev *led_cdev),
>                         const char *name)
> @@ -71,4 +82,8 @@ void hci_leds_init(struct hci_dev *hdev)
>  {
>         /* initialize power_led */
>         hdev->power_led = led_allocate_basic(hdev, power_activate, "power");
> +       /* initialize tx_led */
> +       hdev->tx_led = led_allocate_basic(hdev, NULL, "tx");
> +       /* initialize rx_led */
> +       hdev->rx_led = led_allocate_basic(hdev, NULL, "rx");
>  }
> diff --git a/net/bluetooth/leds.h b/net/bluetooth/leds.h
> index a9c4d6e..9b1cccd 100644
> --- a/net/bluetooth/leds.h
> +++ b/net/bluetooth/leds.h
> @@ -9,8 +9,10 @@
>  #if IS_ENABLED(CONFIG_BT_LEDS)
>  void hci_leds_update_powered(struct hci_dev *hdev, bool enabled);
>  void hci_leds_init(struct hci_dev *hdev);
> +void hci_leds_blink_oneshot(struct led_trigger *trig);
>  #else
>  static inline void hci_leds_update_powered(struct hci_dev *hdev,
>                                            bool enabled) {}
>  static inline void hci_leds_init(struct hci_dev *hdev) {}
> +static inline void hci_leds_blink_oneshot(struct led_trigger *trig) {}
>  #endif
> --
> 1.9.1
>
