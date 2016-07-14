From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Thu, 14 Jul 2016 10:42:16 +0100
Message-ID: <3C106ED5-5F2C-4EAC-8E60-D915D2AD027A@holtmann.org>
References: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org> <D2545F6D-7100-4B59-A19D-7CF878902BAA@holtmann.org> <CAFGCpxwuOH83hdPc-c0DV5A_cKMp-0rjxg+3tMwOPTukHGd6vA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Xu Wei <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Haojian Zhuang <haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFGCpxwuOH83hdPc-c0DV5A_cKMp-0rjxg+3tMwOPTukHGd6vA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Guodong,

>>> Two LED triggers are defined: tx_led and rx_led. Upon frames
>>> available in HCI core layer, for tx or for rx, the combined LED
>>> can blink.
>>> 
>>> Verified on HiKey, 96boards. It uses hi6220 SoC and TI WL1835 combo
>>> chip.
>>> 
>>> Signed-off-by: Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>> ---
>>> include/net/bluetooth/hci_core.h |  1 +
>>> net/bluetooth/hci_core.c         |  3 +++
>>> net/bluetooth/leds.c             | 15 +++++++++++++++
>>> net/bluetooth/leds.h             |  2 ++
>>> 4 files changed, 21 insertions(+)
>>> 
>>> diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
>>> index dc71473..37b8dd9 100644
>>> --- a/include/net/bluetooth/hci_core.h
>>> +++ b/include/net/bluetooth/hci_core.h
>>> @@ -398,6 +398,7 @@ struct hci_dev {
>>>      bdaddr_t                rpa;
>>> 
>>>      struct led_trigger      *power_led;
>>> +     struct led_trigger      *tx_led, *rx_led;
>>> 
>>>      int (*open)(struct hci_dev *hdev);
>>>      int (*close)(struct hci_dev *hdev);
>>> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
>>> index 45a9fc6..c6e1210 100644
>>> --- a/net/bluetooth/hci_core.c
>>> +++ b/net/bluetooth/hci_core.c
>>> @@ -3248,6 +3248,7 @@ int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb)
>>>      skb_queue_tail(&hdev->rx_q, skb);
>>>      queue_work(hdev->workqueue, &hdev->rx_work);
>>> 
>>> +     hci_leds_blink_oneshot(hdev->rx_led);
>>>      return 0;
>>> }
>>> EXPORT_SYMBOL(hci_recv_frame);
>>> @@ -3325,6 +3326,8 @@ static void hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
>>>              BT_ERR("%s sending frame failed (%d)", hdev->name, err);
>>>              kfree_skb(skb);
>>>      }
>>> +
>>> +     hci_leds_blink_oneshot(hdev->tx_led);
>>> }
>> 
>> so I am not convinced that this is the right way of doing TX/RX activity leds. This would have them purely based on HCI traffic and this would include control frames.
>> 
> 
> Hi, Marcel
> 
> +       if (hci_skb_pkt_type(skb) == HCI_ACLDATA_PKT ||
> +           hci_skb_pkt_type(skb) == HCI_SCODATA_PKT)
> +               hci_leds_blink_oneshot(hdev->rx_led);
> +
> 
> By adding pkt_type checks, we can limit LED blinks only at ACL/SCO
> DATA_PKT. Similar checks can be added for tx_led too.
> 
> Does this look good to you? If you agree, I can send v2 to include this change.

we are not going to keep comparing packet types over and over again. The code is already doing that. So functions like hci_sched_acl and hci_acldata_packet are already present in the code.

>> I think that we want activity leds for actual radio activity. Meaning that when we have an active connection and ACL packets are exchanged or when we are scanning.
>> 
> 
> Radio is controlled in Bluetooth module side, not Host. So I'm afraid
> actual radio activity cannot be captured in its exact form in Host
> side. The purpose of this patch is not for radio, it is for
> incoming/outgoing data. For example, it can give user a blinking
> indicator on RX frames after a Bluetooth mouse is connected. Another
> example, it can blink at bluetooth streamed audio (TX).

So radio activity is caused by RX/TX meaning ACL/SCO packets for sure. There is also other radio activity caused by scanning, inquiry, create connection etc. And the question is if this should be there as well.

Regards

Marcel
