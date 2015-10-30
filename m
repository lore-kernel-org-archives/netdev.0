From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Fri, 30 Oct 2015 22:03:07 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
References: <20151030150344.GG9312@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
 <20151030192437.GE32759@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151030192437.GE32759@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Friday, October 30, 2015 12:25 PM
> 
> On (10/30/15 18:57), Nelson, Shannon wrote:
> > > >
> > > > Going along with this being the equivalent of the ixgbe patch, I'd
> > > > prefer the new code to be in i40e_main.c, rather than in i40e_common.c.
> > > > In the design of our drivers, the common file is essentially a device
> > > > specific layer, and the OS and platform related stuff should stay in
> > > > i40e_main.c.  That would also take care of one of the include file nits
> > > > that Andy mentioned.
>        :
> > I'm not sure about any deeper wisdom, but the HW/FW model that this
> > device uses is rather different from our previous devices, so our SW
> > abstractions are a little different from ixgbe and igb.
> 
> Ok, in that case I can make i40e_main.c to do something like
> 
> static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> {
>    :
>    if (i40e_get_platform_mac_addr(..) != I40E_SUCCESS)
> 	i40e_get_mac_addr(..);
>    :
> }
> 
> and i agree that doing this from i40e_main will simplify a lot of the
> other stuff around getting the pdev etc.

The more common idiom in our driver would be

	err = i40e_get_platform_mac_addr(..);
	if (err) {
		...
	}

> 
> [Discussion about ndo_set_mac_address..]
> 
> > In the cases in which I'm aware, the platform manufacturer normally will
> > burn a different mac-address into the device's eeprom at manufacturing
> > time if they want something other than what came from Intel.  I suppose a
> > Device Tree oriented platform could have a different address in the DT,
> > but somehow that needs to get communicated to the device driver so that
> > it can tell the HW.
> >
> > My question to you remains: does this ndo_set_mac_address happen from
> > the stack above the driver or not?
> 
> I'm probably even less clued in to the DT arch than you in this case,
> so input from the intel experts would be useful here.

This worries me - if you're not clued into the DT architecture, why are you making these changes?  Have you tested this beyond a compile?  Do you have a DT model to try this against?

> 
> But both in this case, and for the ixgbe template on which I tried
> to model this, the OF/idprom probing happens from the ->probe when the
> driver comes up, and ndo_set_mac_address is not involved.
> 
> I dont know if it is easier (or even feasible to do this from ->probe)
> to just call the i40e_set_mac to make sure all the state-bits in
> the driver are correctly set.
> 
> --Sowmini

In looking at a couple other drivers, I see the difference being that they typically are writing the primary mac filter on probe (and any other reset), whereas the i40e "knows" that the default mac address is already set up as the filter and doesn't bother with a redundant write.  If you want to add this Open Filter code, you'll need to arrange for this write to happen.  You can't call i40e_set_mac() to do it, but you can see the i40e_aq_mac_address_write() code there that is involved in updating the mac address as an example.  You probably will want to look at section 4.2.1.5.3 of the XL710 data sheet in order to know how to use i40e_aq_mac_address_write() for your situation.

sln
