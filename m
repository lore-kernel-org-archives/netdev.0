From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v8 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Wed, 9 Jul 2014 15:39:45 -0700
Message-ID: <CAKh23Fmxv887dje8r5xF7sQwPumCm15ZWxL7cdpRSZJeBh1FjQ@mail.gmail.com>
References: <1403306296-26198-1-git-send-email-isubramanian@apm.com>
	<1403306296-26198-5-git-send-email-isubramanian@apm.com>
	<CALdTtnvHt5mYMC3619E4F3KK0jPOw7mCpKE6bTn0Um6fdZ4rbw@mail.gmail.com>
	<20140625230450.GO32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dann Frazier <dann.frazier@canonical.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"jcm@redhat.com" <jcm@redhat.com>, netdev <netdev@vger.kernel.org>,
	patches <patches@apm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Keyur Chudgar <kchudgar@apm.com>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Ravi Patel <rapatel@apm.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140625230450.GO32514@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 4:04 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Jun 24, 2014 at 10:29:48PM -0600, Dann Frazier wrote:
>> On Fri, Jun 20, 2014 at 5:18 PM, Iyappan Subramanian
>> <isubramanian@apm.com> wrote:
>> > +       ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
>> > +                                             GFP_KERNEL);
>>
>> Iyappan,
>> When testing this driver on a 3.16-rc2 base, I'm finding that
>> desc_addr gets assigned to NULL here, which results in an oops later
>> on (see below).
>
> Note that on failure here...
>
>> > +       if (!ring->desc_addr)
>> > +               goto err;
>
> we jump to 'err'.
>
>> > +err:
>> > +       dma_free_coherent(dev, size, ring->desc_addr, ring->dma);
>
> which then tries to call dma_free_coherent on a NULL pointer, and
> possibly undefined ring->dma value.  That's not a nice thing to do,
> and will probably lead to problems.  I know that none of the ARM
> flavours of this function will handle this gracefully, and neither
> does x86's version either.  So this is very probably illegal.

I will fix this.

>
>> > +static int xgene_enet_create_desc_rings(struct net_device *ndev)
>> > +{
>> > +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> > +       struct device *dev = &pdata->pdev->dev;
>> > +       struct xgene_enet_desc_ring *rx_ring, *tx_ring, *cp_ring;
>> > +       struct xgene_enet_desc_ring *buf_pool = NULL;
>> > +       u8 cpu_bufnum = 0, eth_bufnum = 0;
>> > +       u8 bp_bufnum = 0x20;
>> > +       u16 ring_id, ring_num = 0;
>> > +       int ret;
>> > +
>> > +       /* allocate rx descriptor ring */
>> > +       ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU, cpu_bufnum++);
>> > +       rx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
>> > +                                             RING_CFGSIZE_16KB, ring_id);
>> > +       if (IS_ERR_OR_NULL(rx_ring)) {
>> > +               ret = PTR_ERR(rx_ring);
>> > +               goto err;
>> > +       }
>>
>> Here we test for IS_ERR_OR_NULL. In the oops I'm hitting, rx_ring is
>> NULL here - but PTR_ERR() apparently returns 0 in that case. So this
>> function ends up returning no error.
>
> Yes, IS_ERR_OR_NULL is evil for this very reason and should be avoided
> where possible.  There were discussions a while back about removing it,
> or at least deprecating it because it causes more bugs (exactly of this
> type) than it solves.

Thanks for pointing it out.  I will redesign IS_ERR_OR_NULL usage.

>
> --
> FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
> improving, and getting towards what was expected from it.
