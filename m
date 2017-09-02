From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/2] Bluetooth: btqcomsmd: BD address setup
Date: Sat, 2 Sep 2017 08:12:17 +0200
Message-ID: <CD710538-22CB-45E5-B54E-ACB97E84D42E@holtmann.org>
References: <20170901204118.17123-1-bjorn.andersson@linaro.org>
 <20170901204118.17123-3-bjorn.andersson@linaro.org>
 <5EC41247-54CD-4F1D-84EC-E94F80A67805@holtmann.org>
 <CAL_JsqK7skzd1c4Y2nxfspA-CeyK4dqjJB2L3tZztT=w8y4==w@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-arm-msm <linux-arm-msm@vger.kernel.org>,
        Loic Poulain <loic.poulain@linaro.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:33056 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdIBGMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 02:12:19 -0400
In-Reply-To: <CAL_JsqK7skzd1c4Y2nxfspA-CeyK4dqjJB2L3tZztT=w8y4==w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

>>> Bluetooth BD address can be retrieved in the same way as
>>> for wcnss-wlan MAC address. This patch mainly stores the
>>> local-mac-address property and sets the BD address during
>>> hci device setup.
>>> 
>>> Signed-off-by: Loic Poulain <loic.poulain@linaro.org>
>>> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
>>> ---
>>> drivers/bluetooth/btqcomsmd.c | 28 ++++++++++++++++++++++++++++
>>> 1 file changed, 28 insertions(+)
>>> 
>>> diff --git a/drivers/bluetooth/btqcomsmd.c b/drivers/bluetooth/btqcomsmd.c
>>> index d00c4fdae924..443bb2099329 100644
>>> --- a/drivers/bluetooth/btqcomsmd.c
>>> +++ b/drivers/bluetooth/btqcomsmd.c
>>> @@ -26,6 +26,7 @@
>>> struct btqcomsmd {
>>>      struct hci_dev *hdev;
>>> 
>>> +     const bdaddr_t *addr;
>>>      struct rpmsg_endpoint *acl_channel;
>>>      struct rpmsg_endpoint *cmd_channel;
>>> };
>>> @@ -100,6 +101,27 @@ static int btqcomsmd_close(struct hci_dev *hdev)
>>>      return 0;
>>> }
>>> 
>>> +static int btqcomsmd_setup(struct hci_dev *hdev)
>>> +{
>>> +     struct btqcomsmd *btq = hci_get_drvdata(hdev);
>>> +     struct sk_buff *skb;
>>> +
>>> +     skb = __hci_cmd_sync(hdev, HCI_OP_RESET, 0, NULL, HCI_INIT_TIMEOUT);
>>> +     if (IS_ERR(skb))
>>> +             return PTR_ERR(skb);
>>> +     kfree_skb(skb);
>>> +
>>> +     if (btq->addr) {
>>> +             bdaddr_t bdaddr;
>>> +
>>> +             /* btq->addr stored with most significant byte first */
>>> +             baswap(&bdaddr, btq->addr);
>>> +             return qca_set_bdaddr_rome(hdev, &bdaddr);
>>> +     }
>>> +
>>> +     return 0;
>>> +}
>>> +
>>> static int btqcomsmd_probe(struct platform_device *pdev)
>>> {
>>>      struct btqcomsmd *btq;
>>> @@ -123,6 +145,11 @@ static int btqcomsmd_probe(struct platform_device *pdev)
>>>      if (IS_ERR(btq->cmd_channel))
>>>              return PTR_ERR(btq->cmd_channel);
>>> 
>>> +     btq->addr = of_get_property(pdev->dev.of_node, "local-mac-address",
>>> +                                 &ret);
>>> +     if (ret != sizeof(bdaddr_t))
>>> +             btq->addr = NULL;
>>> +
>>>      hdev = hci_alloc_dev();
>>>      if (!hdev)
>>>              return -ENOMEM;
>>> @@ -135,6 +162,7 @@ static int btqcomsmd_probe(struct platform_device *pdev)
>>>      hdev->open = btqcomsmd_open;
>>>      hdev->close = btqcomsmd_close;
>>>      hdev->send = btqcomsmd_send;
>>> +     hdev->setup = btqcomsmd_setup;
>>>      hdev->set_bdaddr = qca_set_bdaddr_rome;
>> 
>> I do not like this patch. Why not just set HCI_QUIRK_INVALID_BDADDR and let a userspace tool deal with reading the BD_ADDR from some storage.
>> 
>> Frankly I do not get this WiFI MAC address or BD_ADDR stored in DT. I assumed the DT is suppose to describe hardware and not some value that is normally retrieved for OTP or alike.
> 
> Use of "local-mac-address" for ethernet at least has existed as long
> at OpenFirmware I think. For some platforms, DT is the only OTP. And
> sometimes, the bootloader (like u-boot) stores MAC addresses and then
> populates them on boot.
> 
> Seems like if we just let userspace deal with it, then we're back to a
> btattach tool with every platform's specific way of reading the MAC
> address.

for Bluetooth that is not true. We have Set Public Address command that is uniquely handling this and the HCI_QUIRK_INVALID_BDADDR address does the right magic to allow userspace to identify a missing address. It is done nicely and correctly and works fine.

Mind you this is even used when there actually is a BD_ADDR, but the device manufacturer wants to have one from its own OUI range compared to the chip manufacturer’s OUI range.

If DT is really the only place for the BD_ADDR and the bootloader kinda does add / merge it into the DT, then by all means that is fine. However if it is not, then this feature is dangerous since it can lead to multiple devices with the same address. I rather have these devices leave the kernel in unconfigured mode. And then force a userspace tool to use Set Public Address to bring it into configured mode.

Regards

Marcel
