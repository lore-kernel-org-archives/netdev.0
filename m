From: Guodong Xu <guodong.xu@linaro.org>
Subject: Re: [PATCH 1/2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Fri, 15 Jul 2016 20:08:43 +0800
Message-ID: <CAFGCpxxbmgmbadE5oGctOzu33hhoiOf29DeEqZWCFYAiVBFLdA@mail.gmail.com>
References: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org>
 <D2545F6D-7100-4B59-A19D-7CF878902BAA@holtmann.org> <CAFGCpxwuOH83hdPc-c0DV5A_cKMp-0rjxg+3tMwOPTukHGd6vA@mail.gmail.com>
 <3C106ED5-5F2C-4EAC-8E60-D915D2AD027A@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xu Wei <xuwei5@hisilicon.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Haojian Zhuang <haojian.zhuang@linaro.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Tony Lindgren <tony@atomide.com>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	devicetree@vger.kernel.org,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:35470 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932897AbcGOMIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 08:08:50 -0400
Received: by mail-yw0-f180.google.com with SMTP id l125so99625624ywb.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 05:08:44 -0700 (PDT)
In-Reply-To: <3C106ED5-5F2C-4EAC-8E60-D915D2AD027A@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 July 2016 at 17:42, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Guodong,
>
>>>> Two LED triggers are defined: tx_led and rx_led. Upon frames
>>>> available in HCI core layer, for tx or for rx, the combined LED
>>>> can blink.
>>>>
>>>> Verified on HiKey, 96boards. It uses hi6220 SoC and TI WL1835 combo
>>>> chip.
>>>>
>>>> Signed-off-by: Guodong Xu <guodong.xu@linaro.org>
>>>> ---
>>>> include/net/bluetooth/hci_core.h |  1 +
>>>> net/bluetooth/hci_core.c         |  3 +++
>>>> net/bluetooth/leds.c             | 15 +++++++++++++++
>>>> net/bluetooth/leds.h             |  2 ++
>>>> 4 files changed, 21 insertions(+)
>>>>
>>>> diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
>>>> index dc71473..37b8dd9 100644
>>>> --- a/include/net/bluetooth/hci_core.h
>>>> +++ b/include/net/bluetooth/hci_core.h
>>>> @@ -398,6 +398,7 @@ struct hci_dev {
>>>>      bdaddr_t                rpa;
>>>>
>>>>      struct led_trigger      *power_led;
>>>> +     struct led_trigger      *tx_led, *rx_led;
>>>>
>>>>      int (*open)(struct hci_dev *hdev);
>>>>      int (*close)(struct hci_dev *hdev);
>>>> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
>>>> index 45a9fc6..c6e1210 100644
>>>> --- a/net/bluetooth/hci_core.c
>>>> +++ b/net/bluetooth/hci_core.c
>>>> @@ -3248,6 +3248,7 @@ int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb)
>>>>      skb_queue_tail(&hdev->rx_q, skb);
>>>>      queue_work(hdev->workqueue, &hdev->rx_work);
>>>>
>>>> +     hci_leds_blink_oneshot(hdev->rx_led);
>>>>      return 0;
>>>> }
>>>> EXPORT_SYMBOL(hci_recv_frame);
>>>> @@ -3325,6 +3326,8 @@ static void hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
>>>>              BT_ERR("%s sending frame failed (%d)", hdev->name, err);
>>>>              kfree_skb(skb);
>>>>      }
>>>> +
>>>> +     hci_leds_blink_oneshot(hdev->tx_led);
>>>> }
>>>
>>> so I am not convinced that this is the right way of doing TX/RX activity leds. This would have them purely based on HCI traffic and this would include control frames.
>>>
>>
>> Hi, Marcel
>>
>> +       if (hci_skb_pkt_type(skb) == HCI_ACLDATA_PKT ||
>> +           hci_skb_pkt_type(skb) == HCI_SCODATA_PKT)
>> +               hci_leds_blink_oneshot(hdev->rx_led);
>> +
>>
>> By adding pkt_type checks, we can limit LED blinks only at ACL/SCO
>> DATA_PKT. Similar checks can be added for tx_led too.
>>
>> Does this look good to you? If you agree, I can send v2 to include this change.
>
> we are not going to keep comparing packet types over and over again. The code is already doing that. So functions like hci_sched_acl and hci_acldata_packet are already present in the code.
>
>>> I think that we want activity leds for actual radio activity. Meaning that when we have an active connection and ACL packets are exchanged or when we are scanning.
>>>
>>
>> Radio is controlled in Bluetooth module side, not Host. So I'm afraid
>> actual radio activity cannot be captured in its exact form in Host
>> side. The purpose of this patch is not for radio, it is for
>> incoming/outgoing data. For example, it can give user a blinking
>> indicator on RX frames after a Bluetooth mouse is connected. Another
>> example, it can blink at bluetooth streamed audio (TX).
>
> So radio activity is caused by RX/TX meaning ACL/SCO packets for sure. There is also other radio activity caused by scanning, inquiry, create connection etc. And the question is if this should be there as well.
>

I wouldn't suggest to cover scanning, inquiry, etc. Scanning, for
example, Host sends a scan command to Bluetooth module (in an
asynchronous way). After a given interval, Host receives inquiry
results. Over this period, at host side, we don't know what kind of
radio activity is happening in BT module side.

Let's say this patch provide LED indicators to only data packets
activity (ACL and SCO). Can we?

-Guodong

> Regards
>
> Marcel
>
