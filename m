From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Bluetooth: hci_smd: Qualcomm WCNSS HCI driver
Date: Sat, 3 Oct 2015 18:55:21 +0200
Message-ID: <31CC1992-41BB-484C-9784-3A54D0EF6FF3@holtmann.org>
References: <1443654180-29416-1-git-send-email-bjorn.andersson@sonymobile.com> <036E1E75-8E6A-4116-A648-A188A8458416@holtmann.org> <20151001203338.GW24668@usrtlx11787.corpusers.net>
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fengwei Yin <fengwei.yin@linaro.org>,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20151001203338.GW24668@usrtlx11787.corpusers.net>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

>>> The Qualcomm WCNSS chip provides two SMD channels to the BT core; one
>>> for command and one for event packets. This driver exposes the two
>>> channels as a hci device.
>>> 
> [..]
>>> diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
>>> index 07c9cf381e5a..43c7dc8641ff 100644
>>> --- a/drivers/bluetooth/Makefile
>>> +++ b/drivers/bluetooth/Makefile
>>> @@ -14,6 +14,7 @@ obj-$(CONFIG_BT_HCIBTUART)	+= btuart_cs.o
>>> 
>>> obj-$(CONFIG_BT_HCIBTUSB)	+= btusb.o
>>> obj-$(CONFIG_BT_HCIBTSDIO)	+= btsdio.o
>>> +obj-$(CONFIG_BT_HCISMD)		+= hci_smd.o
>> 
>> I wonder if choosing a name like btqcomsmd.ko would not be better
>> here. For now I am fine with keeping hci_smd.ko since there are other
>> issues here to be fixed first.
> 
> I had some problems figuring out the naming scheme here, but btqcomsmd
> does seem reasonable, I'll update it in the next set.
> 
>> Especially the kbuild test robot complained loudly.
>> 
> 
> Sorry, I forgot to mention in the patch that the patch depends on the
> qcom_smd_id patch - that's available in linux-next. I will take another
> look, but I think that was the cause of all the issues.

which means, I can only merge this driver when this other patch has hit net-next tree. Unless I take the qcom_smd_id through bluetooth-next tree which doesn't look like a good idea.

>>> obj-$(CONFIG_BT_INTEL)		+= btintel.o
>>> obj-$(CONFIG_BT_ATH3K)		+= ath3k.o
>>> diff --git a/drivers/bluetooth/hci_smd.c b/drivers/bluetooth/hci_smd.c
> [..]
>>> +#include <net/bluetooth/hci.h>
>> 
>> The hci.h include is not needed. If you do, then you are doing
>> something fishy.
>> 
> 
> Nothing fishy going on here, so I'll drop it.
> 
>>> +
>>> +static struct {
>>> +	struct qcom_smd_channel *acl_channel;
>>> +	struct qcom_smd_channel *cmd_channel;
>>> +
>>> +	struct hci_dev *hci;
>>> +} smd_hci;
>> 
>> A driver that only supports a single instance of a device and uses a
>> global variable to do so is not a good idea. There should be no reason
>> for this. Why is this done this way.
>> 
> 
> There's two channels coming up, each probing the associated driver that
> combines these into 1 hci device.
> 
> So I have two options;
> 
> * the original idea was to implement multi-channel-per-device support in
>  SMD, but as this is the only known case where that's needed I really
>  don't want to add all the extra complexity to SMD.
> 
> * I can accept the fact that this is silicon inside the MSM SoC and
>  should never exist in more than one instance and make this hack. The
>  first version I implemented had this structure allocated on the first
>  probe, but that didn't really add any value to the static struct.
> 
> I picked the second option due to the fact that the patch to SMD was way
> bigger then this patch, and full of nasty logic.

Writing a driver that assume it is a single instance of a given device is never a good idea. While you might find some instances in the kernel if you look hard enough, but that doesn't mean we should keep doing this. So this needs addressing.

> 
>>> +
>>> +static int smd_hci_recv(unsigned type, const void *data, size_t count)
>>> +{
>>> +	struct sk_buff *skb;
>>> +	void *buf;
>>> +	int ret;
>>> +
>>> +	skb = bt_skb_alloc(count, GFP_ATOMIC);
>> 
>> Is it required that this is GFP_ATOMIC or can this actually be
>> GFP_KERNEL?
>> 
> 
> This is being called from IRQ context upon receiving data on the
> channels.

I wonder why that is needed, but seems an issue in the SMD subsystem. So this is fine, might want to add a comment above the bt_skb_alloc to remind us.

> 
>>> +	if (!skb)
>>> +		return -ENOMEM;
>>> +
>>> +	buf = skb_put(skb, count);
>>> +	memcpy_fromio(buf, data, count);
>> 
>> Why is this a memcpy_fromio here?
>> 
> 
> A memcpy here doesn't seem to work on ARM64, probably because the
> pointer references ioremapped memory. We are discussing either marking
> the data __iomem or perhaps using memremap rather then ioremap.

I would add a comment here as well to remind everybody why this is used. And marking up the pointers is a good idea as well.

>>> +
>>> +	skb->dev = (void *)smd_hci.hci;
>> 
>> This is no longer needed.
>> 
> 
> Thanks
> 
>>> +	bt_cb(skb)->pkt_type = type;
>>> +	skb_orphan(skb);
>>> +
>>> +	ret = hci_recv_frame(smd_hci.hci, skb);
>>> +	if (ret < 0)
>>> +		kfree_skb(skb);
>> 
>> This is a double kfree_skb here. The hci_recv_frame will consume the
>> skb no matter what.
>> 
> 
> Thanks
> 
>>> +
>>> +	return ret;
>>> +}
>>> +
> [..]
>>> +
>>> +static int smd_hci_send(struct hci_dev *hdev, struct sk_buff *skb)
>>> +{
>>> +	int ret;
>>> +
>>> +	switch (bt_cb(skb)->pkt_type) {
>>> +	case HCI_ACLDATA_PKT:
>>> +	case HCI_SCODATA_PKT:
>>> +		ret = qcom_smd_send(smd_hci.acl_channel, skb->data, skb->len);
>>> +		break;
>>> +	case HCI_COMMAND_PKT:
>>> +		ret = qcom_smd_send(smd_hci.cmd_channel, skb->data, skb->len);
>>> +		break;
>>> +	default:
>>> +		ret = -ENODEV;
>>> +		break;
>>> +	}
>>> +
>>> +	kfree_skb(skb);
> 
>> 
>> If you return an error, then the caller of hdev->send will free the
>> skb.
>> 
> 
> Must have looked in the wrong kernel tree :(
> 
> Thanks.
> 
>>> +
>>> +	return ret;
>>> +}
>>> +
>>> +static int smd_hci_open(struct hci_dev *hci)
>>> +{
>>> +	return 0;
>>> +}
>>> +
>>> +static int smd_hci_close(struct hci_dev *hci)
>>> +{
>>> +	return 0;
>>> +}
>> 
>> These two need to at least handling the HCI_RUNNING flag setting and
>> clearing like all the other drivers do.
>> 
> 
> I'm puzzled to the purpose of this, is this only for indication to user
> space or am I missing something?
> 
> I found a couple of others that does nothing but set and clear this bit
> in their open and close. Would you be open for a framework patch that
> provides this functionality to drivers that doesn't need anything else?

This has been in the drivers for as long as the Bluetooth subsystem has been merged upstream. So Linux 2.4.6 to be precise. I had plans to move this code into the core, but that has not happened yet. So until then, lets just include the HCI_RUNNING part.

If there are drivers not doing this, then that is a bug and needs to be fixed. Please point them out to me.

>>> +
>>> +static int smd_hci_set_bdaddr(struct hci_dev *hci,
>>> +			      const bdaddr_t *bdaddr)
>>> +{
>>> +	u8 buf[12];
>>> +
>>> +	buf[0] = 0x0b;
>>> +	buf[1] = 0xfc;
>>> +	buf[2] = 0x9;
>>> +	buf[3] = 0x1;
>>> +	buf[4] = 0x2;
>> 
>> Use full 0x00 syntax here.
>> 
> 
> Ok
> 
>>> +	buf[5] = sizeof(bdaddr_t);
>>> +	memcpy(buf + 6, bdaddr, sizeof(bdaddr_t));
>> 
>> We also need to be sure that this command only changes the BD_ADDR in
>> RAM. It can not be persistent. When resetting / power cycle the
>> controller it will fallback to its default.
>> 
> 
> There seems to be no persistent storage at all in this chip, the BD_ADDR
> being used comes from one of the firmware files, so this just adjust the
> in-memory configuration.
> 
>>> +
>>> +	return qcom_smd_send(smd_hci.cmd_channel, buf, sizeof(buf));
>> 
>> Use __hci_cmd_sync since that is what is suppose to be used in this
>> callback. See the other drivers on how this is done.
>> 
> 
> I did see this, and I first implemented it like that. Unfortunately the
> firmware does not ack the command and __hci_cmd_sync() just times out.
> 
> I didn't manage to find a way around this.

What to you mean by this? It does not send a Command Complete? Does it send a Vendor Event instead?

The real problem is that this callback is on purpose synchronous. The core relies on the fact that you only return when it actually completed.

>> I wonder if qca_set_bdaddr_rome is not actually the same command and
>> you could just use that instead.
>> 
> 
> Looks to be exactly the same thing and gives insight in what those first
> 5 bytes are. I'll update the magics based on this information.
> 
> If I didn't have the issue of the timeout it seems like I should be able
> to just call it.

Has something tried to talk to Qualcomm why that timeout happens? They have something like this for the UART speed change which is changed in NVRAM. Maybe this is a more generic way on how they handle things. It would be good if guys from Qualcomm could give some insights here. However in case of their UART driver, this seems to work as it should. Maybe just a newer firmware is needed.

>>> +}
>>> +
>>> +static int smd_hci_register(void)
>>> +{
>>> +	struct hci_dev *hci;
>>> +	int ret;
>>> +
>>> +	if (smd_hci.hci)
>>> +		return 0;
>>> +
>>> +	/* Wait for both channels to probe before registering */
>>> +	if (!smd_hci.acl_channel || !smd_hci.cmd_channel)
>>> +		return 0;
>>> +
>>> +	hci = hci_alloc_dev();
>>> +	if (!hci)
>>> +		return -ENOMEM;
>>> +
>>> +	hci->bus = HCI_SMD;
>>> +	hci->open = smd_hci_open;
>>> +	hci->close = smd_hci_close;
>>> +	hci->send = smd_hci_send;
>>> +	hci->set_bdaddr = smd_hci_set_bdaddr;
>>> +
>>> +	ret = hci_register_dev(hci);
>>> +	if (ret < 0) {
>>> +		hci_free_dev(hci);
>>> +		return ret;
>>> +	}
>>> +
>>> +	smd_hci.hci = hci;
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static void smd_hci_unregister(void)
>>> +{
>>> +	/* Only unregister on the first remove call */
>>> +	if (!smd_hci.hci)
>>> +		return;
>>> +
>>> +	hci_unregister_dev(smd_hci.hci);
>>> +	hci_free_dev(smd_hci.hci);
>>> +	smd_hci.hci = NULL;
>>> +}
>>> +
>>> +static int smd_hci_acl_probe(struct qcom_smd_device *sdev)
>>> +{
>>> +	smd_hci.acl_channel = sdev->channel;
>>> +	smd_hci_register();
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static int smd_hci_cmd_probe(struct qcom_smd_device *sdev)
>>> +{
>>> +	smd_hci.cmd_channel = sdev->channel;
>>> +	smd_hci_register();
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static void smd_hci_acl_remove(struct qcom_smd_device *sdev)
>>> +{
>>> +	smd_hci.acl_channel = NULL;
>>> +	smd_hci_unregister();
>>> +}
>>> +
>>> +static void smd_hci_cmd_remove(struct qcom_smd_device *sdev)
>>> +{
>>> +	smd_hci.cmd_channel = NULL;
>>> +	smd_hci_unregister();
>>> +}
>>> +
>>> +static const struct qcom_smd_id smd_hci_acl_match[] = {
>>> +	{ .name = "APPS_RIVA_BT_ACL" },
>>> +	{}
>>> +};
>>> +
>>> +static const struct qcom_smd_id smd_hci_cmd_match[] = {
>>> +	{ .name = "APPS_RIVA_BT_CMD" },
>>> +	{}
>>> +};
>>> +
>>> +static struct qcom_smd_driver smd_hci_acl_driver = {
>>> +	.probe = smd_hci_acl_probe,
>>> +	.remove = smd_hci_acl_remove,
>>> +	.callback = smd_hci_acl_callback,
>>> +	.smd_match_table = smd_hci_acl_match,
>>> +	.driver  = {
>>> +		.name  = "qcom_smd_hci_acl",
>>> +		.owner = THIS_MODULE,
>>> +	},
>>> +};
>>> +
>>> +static struct qcom_smd_driver smd_hci_cmd_driver = {
>>> +	.probe = smd_hci_cmd_probe,
>>> +	.remove = smd_hci_cmd_remove,
>>> +	.callback = smd_hci_cmd_callback,
>>> +	.smd_match_table = smd_hci_cmd_match,
>>> +	.driver  = {
>>> +		.name  = "qcom_smd_hci_cmd",
>>> +		.owner = THIS_MODULE,
>>> +	},
>>> +};
>>> +
>>> +module_qcom_smd_driver(smd_hci_acl_driver);
>>> +module_qcom_smd_driver(smd_hci_cmd_driver);
> 
>> 
>> This is not going to fly. This turns it into two module_{init,exit}
>> calls. That really does not work this way.
>> 
> 
> Right, I would need to at least fill in my own init and exit functions
> with the two registers/unregisters calls...
> 
>> I mean why do you need two different drivers in the first place. I
>> should be matching via a single qcom_smd_id in the first place. And
>> you handle everything else in the probe() callback.
>> 
> 
> The first iteration had 1 probe, 1 remove and 1 callback. I pulled the
> match-data in probe and made the rest use this information by drvdata.
> It was the same blocks of code as now, but accessed via the wrapper
> drvdata object - so although one shouldn't do like this, this is much
> cleaner.
> 
>> For me this is similar to the USB case where you actually have to
>> claim to interfaces. We just lookup the other interface and claim it.
>> It looks like SMD core functionality needs the same feature.
>> 
> 
> Indeed, as I said above the plan was to implement something where I
> either only probe when all channels where up (turned out to be a mess to
> implement) or have some accessor function that can be called from probe
> to open a second channel.
> 
> The latter seems reasonable to do, but it will be way more code than
> there's in this driver - which seems to be the only case where that
> feature would be needed.

That is what USB does when claiming a second interface. I would do exactly that and especially be able to make sure that both channels have the same struct device as parent.

Regards

Marcel
