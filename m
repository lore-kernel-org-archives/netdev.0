From: Guodong Xu <guodong.xu@linaro.org>
Subject: Re: [PATCH v2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Tue, 16 Aug 2016 10:37:23 +0800
Message-ID: <CAFGCpxxXW0d=6GP1F4byEQBoR+YF-W6fX4bC6=13wKTt_NumkA@mail.gmail.com>
References: <1469939084-15603-1-git-send-email-guodong.xu@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Guodong Xu <guodong.xu@linaro.org>
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469939084-15603-1-git-send-email-guodong.xu@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping. :)  Would you give me some review opinions on this?

In this revision, I chose to limit LED blinking to tx/rx traffic
packets only. For other types of over-the-air packets, like scanning,
it's not covered.

Thank you.

-Guodong


On 31 July 2016 at 12:24, Guodong Xu <guodong.xu@linaro.org> wrote:
> Two LED triggers are added into hci_dev: tx_led and rx_led. Upon ACL/SCO
> packets available in tx or rx, the LEDs will blink.
>
> For each hci registration, two triggers are added into LED subsystem:
> [hdev->name]-tx and [hdev-name]-rx.
> Refer to Documentation/leds/leds-class.txt for usage.
>
> Verified on HiKey 96boards, which uses HiSilicon hi6220 SoC and TI
> WL1835 WiFi/BT combo chip.
>
> Signed-off-by: Guodong Xu <guodong.xu@linaro.org>
> ---
>  include/net/bluetooth/hci_core.h |  1 +
>  net/bluetooth/hci_core.c         |  6 ++++++
>  net/bluetooth/leds.c             | 17 +++++++++++++++++
>  net/bluetooth/leds.h             |  2 ++
>  4 files changed, 26 insertions(+)
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
> index 45a9fc6..956dce1 100644
> --- a/net/bluetooth/hci_core.c
> +++ b/net/bluetooth/hci_core.c
> @@ -3833,6 +3833,7 @@ static void hci_sched_acl(struct hci_dev *hdev)
>         if (!hci_conn_num(hdev, AMP_LINK) && hdev->dev_type == HCI_AMP)
>                 return;
>
> +       hci_leds_blink_oneshot(hdev->tx_led);
>         switch (hdev->flow_ctl_mode) {
>         case HCI_FLOW_CTL_MODE_PACKET_BASED:
>                 hci_sched_acl_pkt(hdev);
> @@ -3856,6 +3857,7 @@ static void hci_sched_sco(struct hci_dev *hdev)
>         if (!hci_conn_num(hdev, SCO_LINK))
>                 return;
>
> +       hci_leds_blink_oneshot(hdev->tx_led);
>         while (hdev->sco_cnt && (conn = hci_low_sent(hdev, SCO_LINK, &quote))) {
>                 while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
>                         BT_DBG("skb %p len %d", skb, skb->len);
> @@ -3879,6 +3881,7 @@ static void hci_sched_esco(struct hci_dev *hdev)
>         if (!hci_conn_num(hdev, ESCO_LINK))
>                 return;
>
> +       hci_leds_blink_oneshot(hdev->tx_led);
>         while (hdev->sco_cnt && (conn = hci_low_sent(hdev, ESCO_LINK,
>                                                      &quote))) {
>                 while (quote-- && (skb = skb_dequeue(&conn->data_q))) {
> @@ -3911,6 +3914,7 @@ static void hci_sched_le(struct hci_dev *hdev)
>                         hci_link_tx_to(hdev, LE_LINK);
>         }
>
> +       hci_leds_blink_oneshot(hdev->tx_led);
>         cnt = hdev->le_pkts ? hdev->le_cnt : hdev->acl_cnt;
>         tmp = cnt;
>         while (cnt && (chan = hci_chan_sent(hdev, LE_LINK, &quote))) {
> @@ -3990,6 +3994,7 @@ static void hci_acldata_packet(struct hci_dev *hdev, struct sk_buff *skb)
>
>         if (conn) {
>                 hci_conn_enter_active_mode(conn, BT_POWER_FORCE_ACTIVE_OFF);
> +               hci_leds_blink_oneshot(hdev->rx_led);
>
>                 /* Send to upper protocol */
>                 l2cap_recv_acldata(conn, skb, flags);
> @@ -4022,6 +4027,7 @@ static void hci_scodata_packet(struct hci_dev *hdev, struct sk_buff *skb)
>         hci_dev_unlock(hdev);
>
>         if (conn) {
> +               hci_leds_blink_oneshot(hdev->rx_led);
>                 /* Send to upper protocol */
>                 sco_recv_scodata(conn, skb);
>                 return;
> diff --git a/net/bluetooth/leds.c b/net/bluetooth/leds.c
> index 8319c84..ae10c5d 100644
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
> @@ -37,6 +39,17 @@ static void power_activate(struct led_classdev *led_cdev)
>         led_trigger_event(led_cdev->trigger, powered ? LED_FULL : LED_OFF);
>  }
>
> +void hci_leds_blink_oneshot(struct led_trigger *trig)
> +{
> +       unsigned long led_delay = BLUETOOTH_BLINK_DELAY;
> +
> +       if (!trig)
> +               return;
> +
> +       BT_DBG("led_trig %p", trig);
> +       led_trigger_blink_oneshot(trig, &led_delay, &led_delay, 0);
> +}
> +
>  static struct led_trigger *led_allocate_basic(struct hci_dev *hdev,
>                         void (*activate)(struct led_classdev *led_cdev),
>                         const char *name)
> @@ -71,4 +84,8 @@ void hci_leds_init(struct hci_dev *hdev)
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
