From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH 2/2] Bluetooth: btqcomsmd: BD address setup
Date: Fri, 1 Sep 2017 15:15:03 -0700
Message-ID: <20170901221503.GA1165@minitux>
References: <20170901204118.17123-1-bjorn.andersson@linaro.org>
 <20170901204118.17123-3-bjorn.andersson@linaro.org>
 <5EC41247-54CD-4F1D-84EC-E94F80A67805@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-arm-msm@vger.kernel.org,
        Loic Poulain <loic.poulain@linaro.org>,
        Rob Herring <robh@kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5EC41247-54CD-4F1D-84EC-E94F80A67805@holtmann.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 01 Sep 13:47 PDT 2017, Marcel Holtmann wrote:

> Hi Bjorn,
> 
> > Bluetooth BD address can be retrieved in the same way as
> > for wcnss-wlan MAC address. This patch mainly stores the
> > local-mac-address property and sets the BD address during
> > hci device setup.
> > 
> > Signed-off-by: Loic Poulain <loic.poulain@linaro.org>
> > Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> > ---
> > drivers/bluetooth/btqcomsmd.c | 28 ++++++++++++++++++++++++++++
> > 1 file changed, 28 insertions(+)
> > 
> > diff --git a/drivers/bluetooth/btqcomsmd.c b/drivers/bluetooth/btqcomsmd.c
> > index d00c4fdae924..443bb2099329 100644
> > --- a/drivers/bluetooth/btqcomsmd.c
> > +++ b/drivers/bluetooth/btqcomsmd.c
> > @@ -26,6 +26,7 @@
> > struct btqcomsmd {
> > 	struct hci_dev *hdev;
> > 
> > +	const bdaddr_t *addr;
> > 	struct rpmsg_endpoint *acl_channel;
> > 	struct rpmsg_endpoint *cmd_channel;
> > };
> > @@ -100,6 +101,27 @@ static int btqcomsmd_close(struct hci_dev *hdev)
> > 	return 0;
> > }
> > 
> > +static int btqcomsmd_setup(struct hci_dev *hdev)
> > +{
> > +	struct btqcomsmd *btq = hci_get_drvdata(hdev);
> > +	struct sk_buff *skb;
> > +
> > +	skb = __hci_cmd_sync(hdev, HCI_OP_RESET, 0, NULL, HCI_INIT_TIMEOUT);
> > +	if (IS_ERR(skb))
> > +		return PTR_ERR(skb);
> > +	kfree_skb(skb);
> > +
> > +	if (btq->addr) {
> > +		bdaddr_t bdaddr;
> > +
> > +		/* btq->addr stored with most significant byte first */
> > +		baswap(&bdaddr, btq->addr);
> > +		return qca_set_bdaddr_rome(hdev, &bdaddr);
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > static int btqcomsmd_probe(struct platform_device *pdev)
> > {
> > 	struct btqcomsmd *btq;
> > @@ -123,6 +145,11 @@ static int btqcomsmd_probe(struct platform_device *pdev)
> > 	if (IS_ERR(btq->cmd_channel))
> > 		return PTR_ERR(btq->cmd_channel);
> > 
> > +	btq->addr = of_get_property(pdev->dev.of_node, "local-mac-address",
> > +				    &ret);
> > +	if (ret != sizeof(bdaddr_t))
> > +		btq->addr = NULL;
> > +
> > 	hdev = hci_alloc_dev();
> > 	if (!hdev)
> > 		return -ENOMEM;
> > @@ -135,6 +162,7 @@ static int btqcomsmd_probe(struct platform_device *pdev)
> > 	hdev->open = btqcomsmd_open;
> > 	hdev->close = btqcomsmd_close;
> > 	hdev->send = btqcomsmd_send;
> > +	hdev->setup = btqcomsmd_setup;
> > 	hdev->set_bdaddr = qca_set_bdaddr_rome;
> 
> I do not like this patch. Why not just set HCI_QUIRK_INVALID_BDADDR
> and let a userspace tool deal with reading the BD_ADDR from some
> storage.
> 

That's what we currently have, but we regularly get complaints from
developers using our board (DB410c).

We're maintaining a Debian-based and an OpenEmbedded-based build and at
least in the past btmgmt was not available in these - so we would have
to maintain both a custom BlueZ package and then some scripts to inject
the appropriate mac address.

Beyond these reference builds our users tend to build their own system
images and I was hoping that they would not be forced to have a custom
hook running each time hci0 is registered.

> Frankly I do not get this WiFI MAC address or BD_ADDR stored in DT. I
> assumed the DT is suppose to describe hardware and not some value that
> is normally retrieved for OTP or alike.
> 

While I share your skepticism here I find it way superior over the
various cases where this information is hard coded in some firmware file
that has to be patched for each device - in particular when considering
the out-of-tree workarounds that follow when said firmware file is not
allowed to be modified on the device (e.g. in Android).

And note that it's not _stored_ in DT, it's passed from the boot loader
in DT - and it's still optional, so if an OEM has other means to
provision the BD_ADDR they can still handle this in user space.

Regards,
Bjorn
