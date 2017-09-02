From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/2] Bluetooth: btqcomsmd: BD address setup
Date: Sat, 2 Sep 2017 08:38:26 +0200
Message-ID: <60FC7975-BB1B-4CFF-9C63-A901F70D7A5B@holtmann.org>
References: <20170901204118.17123-1-bjorn.andersson@linaro.org>
 <20170901204118.17123-3-bjorn.andersson@linaro.org>
 <5EC41247-54CD-4F1D-84EC-E94F80A67805@holtmann.org>
 <20170901221503.GA1165@minitux>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-arm-msm@vger.kernel.org,
        Loic Poulain <loic.poulain@linaro.org>,
        Rob Herring <robh@kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170901221503.GA1165@minitux>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

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
>>> 	struct hci_dev *hdev;
>>> 
>>> +	const bdaddr_t *addr;
>>> 	struct rpmsg_endpoint *acl_channel;
>>> 	struct rpmsg_endpoint *cmd_channel;
>>> };
>>> @@ -100,6 +101,27 @@ static int btqcomsmd_close(struct hci_dev *hdev)
>>> 	return 0;
>>> }
>>> 
>>> +static int btqcomsmd_setup(struct hci_dev *hdev)
>>> +{
>>> +	struct btqcomsmd *btq = hci_get_drvdata(hdev);
>>> +	struct sk_buff *skb;
>>> +
>>> +	skb = __hci_cmd_sync(hdev, HCI_OP_RESET, 0, NULL, HCI_INIT_TIMEOUT);
>>> +	if (IS_ERR(skb))
>>> +		return PTR_ERR(skb);
>>> +	kfree_skb(skb);
>>> +
>>> +	if (btq->addr) {
>>> +		bdaddr_t bdaddr;
>>> +
>>> +		/* btq->addr stored with most significant byte first */
>>> +		baswap(&bdaddr, btq->addr);
>>> +		return qca_set_bdaddr_rome(hdev, &bdaddr);
>>> +	}
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> static int btqcomsmd_probe(struct platform_device *pdev)
>>> {
>>> 	struct btqcomsmd *btq;
>>> @@ -123,6 +145,11 @@ static int btqcomsmd_probe(struct platform_device *pdev)
>>> 	if (IS_ERR(btq->cmd_channel))
>>> 		return PTR_ERR(btq->cmd_channel);
>>> 
>>> +	btq->addr = of_get_property(pdev->dev.of_node, "local-mac-address",
>>> +				    &ret);
>>> +	if (ret != sizeof(bdaddr_t))
>>> +		btq->addr = NULL;
>>> +
>>> 	hdev = hci_alloc_dev();
>>> 	if (!hdev)
>>> 		return -ENOMEM;
>>> @@ -135,6 +162,7 @@ static int btqcomsmd_probe(struct platform_device *pdev)
>>> 	hdev->open = btqcomsmd_open;
>>> 	hdev->close = btqcomsmd_close;
>>> 	hdev->send = btqcomsmd_send;
>>> +	hdev->setup = btqcomsmd_setup;
>>> 	hdev->set_bdaddr = qca_set_bdaddr_rome;
>> 
>> I do not like this patch. Why not just set HCI_QUIRK_INVALID_BDADDR
>> and let a userspace tool deal with reading the BD_ADDR from some
>> storage.
>> 
> 
> That's what we currently have, but we regularly get complaints from
> developers using our board (DB410c).

at least not in the upstream driver. It does not use HCI_QUIRK_INVALID_BDADDR to tell the system that its BD_ADDR is not valid. Which is something you still need to do if local-mac-address would not be found.

What BD_ADDR is actually returned by default. Can someone send me a “btmon -w trace.log” for an init procedure of this chip?

> We're maintaining a Debian-based and an OpenEmbedded-based build and at
> least in the past btmgmt was not available in these - so we would have
> to maintain both a custom BlueZ package and then some scripts to inject
> the appropriate mac address.
> 
> Beyond these reference builds our users tend to build their own system
> images and I was hoping that they would not be forced to have a custom
> hook running each time hci0 is registered.

Frankly this has never been about btmgmt usage. That tool is really just for us to test the interface. What was needed is that we create a small daemon that can have backends for accessing the various OTPs. Or in dev mode just generate a random OUI from an unused OUI range. I would have put that into bluetoothd, but it seemed not a good idea since many companies were secret about their OTP access. So I assumed they build there own quick solution since mgmt API is fully documented and you only need to listen for Unconfigured Index event, send Set Public Address and leave. So something super simple.

For a LE only controller without a BD_ADDR, we recently added a pool of static addresses that it will generate and program. However that is specific since LE is capable of operating without a public address.

We could actually downgrade a dual-mode controller without a BD_ADDR into a single mode controller. That will automatically start using static addresses and be fully operational. That might be useful for people who get a dual-mode controller, but only care about LE. I have seen devices that only use the LE portion.

>> Frankly I do not get this WiFI MAC address or BD_ADDR stored in DT. I
>> assumed the DT is suppose to describe hardware and not some value that
>> is normally retrieved for OTP or alike.
>> 
> 
> While I share your skepticism here I find it way superior over the
> various cases where this information is hard coded in some firmware file
> that has to be patched for each device - in particular when considering
> the out-of-tree workarounds that follow when said firmware file is not
> allowed to be modified on the device (e.g. in Android).

That I full agree. Storing the BD_ADDR in the firmware file is utterly pointless. That is just insane way of operation and that is why we added the ability to make interfaces clearly as unconfigured when they miss the BD_ADDR. And have one way to userspace to configure it.

The DT file is nothing better if it is something that is generated statically once. It has the same problem. You are just papering over it and telling someone else to deal with it.

When the bootloader dynamically generated the DT and inserts a local-mac-address field based on its own OTP, then I can see that this is possible, but for static DT that for example the kernel ships, this is a super bad idea. As bad as the BD_ADDR in the firmware file itself.

> And note that it's not _stored_ in DT, it's passed from the boot loader
> in DT - and it's still optional, so if an OEM has other means to
> provision the BD_ADDR they can still handle this in user space.

That is really not clear to me and I do not even think the documentation has all the needed warnings. The Bluetooth devices is super critical for having its unique BD_ADDR for Bluetooth Classic operation. Things will really go bonkers. And they will since I had to already fly half around the world to debug issues with wrong mac addresses.

If we now all want to blame the bootloader, then so be it. Nevertheless you are still not using HCI_QUIRK_INVALID_BDADDR if the bootloader can’t be blamed. That is actually a bad idea since now also userspace thinks it is all fine.

And I did write a lengthy email about this about 3 years ago:

http://linux-bluetooth.vger.kernel.narkive.com/9JnHPGAf/some-notes-about-device-provisioning

So since I think this is actually dangerous to have the BD_ADDR come from DT, I think these needs a few extra bits of documentation on the usage of local-mac-address in the DT documentation, in addition we might want to print that the Bluetooth address comes from DT and which one in dmesg. So that at least there is some chance of debugging if you get this fully wrong. And you need to use HCI_QUIRK_INVALID_BDADDR. That is actually a real bug right now if the hardware never has a valid address.

Regards

Marcel
