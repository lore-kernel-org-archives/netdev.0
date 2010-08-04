From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 06/11] rt2x00: do not use PCI resources before
	pci_enable_device()
Date: Wed, 4 Aug 2010 08:59:31 +0200
Message-ID: <AANLkTi=y0Ka9+jKFCvS0_Pbku=bTrsyU3LMCSOX2VwLs@mail.gmail.com>
References: <1280850203-5532-1-git-send-email-segooon@gmail.com>
	<AANLkTinzvwP74oNaS+mWRnostnGrZZ-iY2SsjMzo=CW4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Alban Browaeys <prahal@yahoo.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Gertjan van Wingerde <gwingerde@gmail.com>
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinzvwP74oNaS+mWRnostnGrZZ-iY2SsjMzo=CW4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 3, 2010 at 6:14 PM, Gertjan van Wingerde
<gwingerde@gmail.com> wrote:
> On Tue, Aug 3, 2010 at 5:43 PM, Kulikov Vasiliy <segooon@gmail.com> w=
rote:
>> IRQ and resource[] may not have correct values until
>> after PCI hotplug setup occurs at pci_enable_device() time.
>>
>> The semantic match that finds this problem is as follows:
>>
>> // <smpl>
>> @@
>> identifier x;
>> identifier request ~=3D "pci_request.*|pci_resource.*";
>> @@
>>
>> (
>> * x->irq
>> |
>> * x->resource
>> |
>> * request(x, ...)
>> )
>> =A0...
>> *pci_enable_device(x)
>> // </smpl>
>>
>> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
>
> Good catch.
>
> Acked-by: Gertjan van Wingerde <gwingerde@gmail.com>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

>> ---
>> =A0drivers/net/wireless/rt2x00/rt2x00pci.c | =A0 21 ++++++++++------=
-----
>> =A01 files changed, 10 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/w=
ireless/rt2x00/rt2x00pci.c
>> index 19b262e..63c2cc4 100644
>> --- a/drivers/net/wireless/rt2x00/rt2x00pci.c
>> +++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
>> @@ -240,16 +240,16 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, c=
onst struct pci_device_id *id)
>> =A0 =A0 =A0 =A0struct rt2x00_dev *rt2x00dev;
>> =A0 =A0 =A0 =A0int retval;
>>
>> - =A0 =A0 =A0 retval =3D pci_request_regions(pci_dev, pci_name(pci_d=
ev));
>> + =A0 =A0 =A0 retval =3D pci_enable_device(pci_dev);
>> =A0 =A0 =A0 =A0if (retval) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ERROR_PROBE("PCI request regions faile=
d.\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ERROR_PROBE("Enable device failed.\n")=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
>> =A0 =A0 =A0 =A0}
>>
>> - =A0 =A0 =A0 retval =3D pci_enable_device(pci_dev);
>> + =A0 =A0 =A0 retval =3D pci_request_regions(pci_dev, pci_name(pci_d=
ev));
>> =A0 =A0 =A0 =A0if (retval) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ERROR_PROBE("Enable device failed.\n")=
;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit_release_regions;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ERROR_PROBE("PCI request regions faile=
d.\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit_disable_device;
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0pci_set_master(pci_dev);
>> @@ -260,14 +260,14 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, c=
onst struct pci_device_id *id)
>> =A0 =A0 =A0 =A0if (dma_set_mask(&pci_dev->dev, DMA_BIT_MASK(32))) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ERROR_PROBE("PCI DMA not supported.\n=
");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D -EIO;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit_disable_device;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit_release_regions;
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0hw =3D ieee80211_alloc_hw(sizeof(struct rt2x00_dev), =
ops->hw);
>> =A0 =A0 =A0 =A0if (!hw) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ERROR_PROBE("Failed to allocate hardw=
are.\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D -ENOMEM;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit_disable_device;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto exit_release_regions;
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0pci_set_drvdata(pci_dev, hw);
>> @@ -300,13 +300,12 @@ exit_free_reg:
>> =A0exit_free_device:
>> =A0 =A0 =A0 =A0ieee80211_free_hw(hw);
>>
>> -exit_disable_device:
>> - =A0 =A0 =A0 if (retval !=3D -EBUSY)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_disable_device(pci_dev);
>> -
>> =A0exit_release_regions:
>> =A0 =A0 =A0 =A0pci_release_regions(pci_dev);
>>
>> +exit_disable_device:
>> + =A0 =A0 =A0 pci_disable_device(pci_dev);
>> +
>> =A0 =A0 =A0 =A0pci_set_drvdata(pci_dev, NULL);
>>
>> =A0 =A0 =A0 =A0return retval;
>> --
>> 1.7.0.4
>>
>>
>
