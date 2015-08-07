From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/2] net, thunder, bgx: Add support for ACPI binding.
Date: Fri, 7 Aug 2015 18:53:53 +0100
Message-ID: <20150807175353.GA31122@leverpostej>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>
 <1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com>
 <20150807140106.GE7646@leverpostej>
 <55C4ECC6.7050908@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney.cavm@gmail.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"rob.herring@linaro.org" <rob.herring@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
	David Daney <david.daney@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Robert Richter <rrichter@cavium.com>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55C4ECC6.7050908@caviumnetworks.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Correcting the devicetree list address, which I typo'd in my original
reply]

[resending to _really_ correct the address, apologies for the spam]

> >> +static const char * const addr_propnames[] = {
> >> +	"mac-address",
> >> +	"local-mac-address",
> >> +	"address",
> >> +};
> >
> > If these are going to be generally necessary, then we should get them
> > adopted as standardised _DSD properties (ideally just one of them).
> 
> As far as I can tell, and please correct me if I am wrong, ACPI-6.0 
> doesn't contemplate MAC addresses.
> 
> Today we are using "mac-address", which is an Integer containing the MAC 
> address in its lowest order 48 bits in Little-Endian byte order.
> 
> The hardware and ACPI tables are here today, and we would like to 
> support it.  If some future ACPI specification specifies a standard way 
> to do this, we will probably adapt the code to do this in a standard manner.
> 
> 
> >
> > [...]
> >
> >> +static acpi_status bgx_acpi_register_phy(acpi_handle handle,
> >> +					 u32 lvl, void *context, void **rv)
> >> +{
> >> +	struct acpi_reference_args args;
> >> +	const union acpi_object *prop;
> >> +	struct bgx *bgx = context;
> >> +	struct acpi_device *adev;
> >> +	struct device *phy_dev;
> >> +	u32 phy_id;
> >> +
> >> +	if (acpi_bus_get_device(handle, &adev))
> >> +		goto out;
> >> +
> >> +	SET_NETDEV_DEV(&bgx->lmac[bgx->lmac_count].netdev, &bgx->pdev->dev);
> >> +
> >> +	acpi_get_mac_address(adev, bgx->lmac[bgx->lmac_count].mac);
> >> +
> >> +	bgx->lmac[bgx->lmac_count].lmacid = bgx->lmac_count;
> >> +
> >> +	if (acpi_dev_get_property_reference(adev, "phy-handle", 0, &args))
> >> +		goto out;
> >> +
> >> +	if (acpi_dev_get_property(args.adev, "phy-channel", ACPI_TYPE_INTEGER, &prop))
> >> +		goto out;
> >
> > Likewise for any inter-device properties, so that we can actually handle
> > them in a generic fashion, and avoid / learn from the mistakes we've
> > already handled with DT.
> 
> This is the fallacy of the ACPI is superior to DT argument.  The 
> specification of PHY topology and MAC addresses is well standardized in 
> DT, there is no question about what the proper way to specify it is. 
> Under ACPI, it is the Wild West, there is no specification, so each 
> system design is forced to invent something, and everybody comes up with 
> an incompatible implementation.

Indeed.

If ACPI is going to handle it, it should handle it properly. I really
don't see the point in bodging properties together in a less standard
manner than DT, especially for inter-device relationships.

Doing so is painful for _everyone_, and it's extremely unlikely that
other ACPI-aware OSs will actually support these custom descriptions,
making this Linux-specific, and breaking the rationale for using ACPI in
the first place -- a standard that says "just do non-standard stuff" is
not a usable standard.

For intra-device properties, we should standardise what we can, but
vendor-specific stuff is ok -- this can be self-contained within a
driver.

For inter-device relationships ACPI _must_ gain a better model of
componentised devices. It's simply unworkable otherwise, and as you
point out it's fallacious to say that because ACPI is being used that
something is magically industry standard, portable, etc.

This is not your problem in particular; the entire handling of _DSD so
far is a joke IMO.

Thanks,
Mark.
