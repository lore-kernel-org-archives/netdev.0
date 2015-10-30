From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Fri, 30 Oct 2015 18:57:26 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
References: <20151030150344.GG9312@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
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
In-Reply-To: <20151030183645.GD32759@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: Friday, October 30, 2015 11:37 AM
> To: 
> Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
> IDPROM
> 
> On (10/30/15 18:28), Nelson, Shannon wrote:
> >
> > Going along with this being the equivalent of the ixgbe patch, I'd
> > prefer the new code to be in i40e_main.c, rather than in i40e_common.c.
> > In the design of our drivers, the common file is essentially a device
> > specific layer, and the OS and platform related stuff should stay in
> > i40e_main.c.  That would also take care of one of the include file nits
> > that Andy mentioned.
> 
> ok, and that was my initial instinct as well, except that I noticed
> that the existing i40e code tries interesting variations from the
> typical intel driver model by calling i40e_get_mac_addr() which lives in
> (for reasons not obvious to me) i40e_common.c
> 
> So I assumed there must be some other deeper wisdom at work here.

I'm not sure about any deeper wisdom, but the HW/FW model that this device uses is rather different from our previous devices, so our SW abstractions are a little different from ixgbe and igb.

> 
> > At the risk of flying my Device Tree ignorance for all to see, I have
> > a couple questions on how this is used.
> >
> > Since the mac address is specific to the individual device, how does it
> > get into the device tree?  I thought the device tree was compiled ahead
> > of time for the platform it is used on.  Is this a generic DT pattern
> > just in case some platform actually has the mac-address?  Or does the
> > device mac-address get saved into the DT on the first time through this
> > path so it can be found next time?
> >
> > If the Device Tree has a different mac address than the HW, when
> > does the kernel tell the HW to use a different mac address?  Does the
> > DT management eventually call the ndo_set_mac_address call so the HW
> > knows to use a different mac address?
> 
> yes, and here I was hoping for some feedback from the intel folks as
> well. Commit c762dff24c06 sets hw->mac.perm_addr. I dont know
> if there is some similar i40e state that needs to be set.
> 
> Please share insights.
> 
> --Sowmini

Forgive me if you're already up with this, I just want to be sure we're thinking along the same lines.

The HW has a mac address burned into its own eeprom which it will use by default.  The driver merely queries the HW to find out what that mac address is and report it to the OS so it can be registered correctly in the netdev.

If a different mac address is desired, perhaps from the user issuing an "ip link" or ifconfig command, the OS will call the netdev's ndo_set_mac_address to tell the driver.  In our case, the driver then tells the HW device to filter for the new mac address rather than the eeprom'd address.  This remains until a reset when the HW goes back to its eeprom'd address.

In the cases in which I'm aware, the platform manufacturer normally will burn a different mac-address into the device's eeprom at manufacturing time if they want something other than what came from Intel.  I suppose a Device Tree oriented platform could have a different address in the DT, but somehow that needs to get communicated to the device driver so that it can tell the HW.

My question to you remains: does this ndo_set_mac_address happen from the stack above the driver or not?

Thanks,
sln
