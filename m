From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 2/5] stmmac: pci: use managed resources
Date: Wed, 22 Oct 2014 11:36:33 +0300
Message-ID: <1413966993.2396.26.camel@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
	 <5446C827.2040801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36367 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754564AbaJVIge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 04:36:34 -0400
In-Reply-To: <5446C827.2040801@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 00:55 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 10/21/2014 08:35 PM, Andy Shevchenko wrote:
> 
> > Migrate pci driver to managed resources to reduce boilerplate error handling
> > code.
> 
> > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > ---
> >   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 46 +++++-------------------
> >   1 file changed, 8 insertions(+), 38 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> > index 5459a4e..f8d4ce2 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> > @@ -65,45 +65,29 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
> >   			    const struct pci_device_id *id)
> >   {
> >   	int ret = 0;
> > -	void __iomem *addr = NULL;
> >   	struct stmmac_priv *priv = NULL;
> > -	int i;
> > +	int pci_bar = 0;
> 
>     I don't see this variable changing anywhere...

See my comment below.

> 
> >   	/* Enable pci device */
> > -	ret = pci_enable_device(pdev);
> > +	ret = pcim_enable_device(pdev);
> >   	if (ret) {
> >   		pr_err("%s : ERROR: failed to enable %s device\n", __func__,
> >   		       pci_name(pdev));
> >   		return ret;
> >   	}
> > -	if (pci_request_regions(pdev, STMMAC_RESOURCE_NAME)) {
> > -		pr_err("%s: ERROR: failed to get PCI region\n", __func__);
> > -		ret = -ENODEV;
> > -		goto err_out_req_reg_failed;
> > -	}
> > +	ret = pcim_iomap_regions(pdev, BIT(pci_bar), pci_name(pdev));
> > +	if (ret)
> > +		return ret;
> >
> > -	/* Get the base address of device */
> > -	for (i = 0; i <= 5; i++) {
> > -		if (pci_resource_len(pdev, i) == 0)
> > -			continue;
> > -		addr = pci_iomap(pdev, i, 0);
> > -		if (addr == NULL) {
> > -			pr_err("%s: ERROR: cannot map register memory aborting",
> > -			       __func__);
> > -			ret = -EIO;
> > -			goto err_out_map_failed;
> > -		}
> > -		break;
> > -	}
> 
>     It's not an equivalent change: the old code mapped a first existing BAR, 
> you always map BAR0. Are you sure that's what you meant? If so, wouldn't hurt 
> to describe this in the changelog...

So, I was trying to find any specification on public regarding to boards
that have this IP, no luck so far. I guess that that code was created
due to XILINX FPGA usage which probably can provide any BAR user wants
to. Thus, I imply that in real applications the BAR most probably will
be 0. However, I left variable which can be overridden in future
(regarding to PCI ID).

It would be nice to hear someone from ST about this. Giuseppe?


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
