From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up.
Date: Wed, 4 Dec 2013 11:23:40 +0000
Message-ID: <1386156220.17466.29.camel@kazak.uk.xensource.com>
References: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
	   <1386149848.13256.86.camel@kazak.uk.xensource.com>
	   <alpine.DEB.2.02.1312041049310.7093@kaball.uk.xensource.com>
	  <1386154783.17466.14.camel@kazak.uk.xensource.com>
	  <alpine.DEB.2.02.1312041104110.7093@kaball.uk.xensource.com>
	 <1386155291.17466.19.camel@kazak.uk.xensource.com>
	 <alpine.DEB.2.02.1312041116230.7093@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<leosilva@linux.vnet.ibm.com>, <ashley@ashleylai.com>,
	<peterhuewe@gmx.de>, <mail@srajiv.net>, <tpmdd@selhorst.net>,
	<tpmdd@sirrix.com>, <dmitry.torokhov@gmail.com>,
	<bhelgaas@google.com>, <plagnioj@jcrosoft.com>,
	<tomi.valkeinen@ti.com>, <tpmdd-devel@lists.sourceforge.net>,
	<linux-input@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-fbdev@vger.kernel.org>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1312041116230.7093@kaball.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-12-04 at 11:18 +0000, Stefano Stabellini wrote:
> On Wed, 4 Dec 2013, Ian Campbell wrote:
> > On Wed, 2013-12-04 at 11:05 +0000, Stefano Stabellini wrote:
> > > On Wed, 4 Dec 2013, Ian Campbell wrote:
> > > > On Wed, 2013-12-04 at 10:51 +0000, Stefano Stabellini wrote:
> > > > > On Wed, 4 Dec 2013, Ian Campbell wrote:
> > > > > > > +bool xen_has_pv_devices(void)
> > > > > > > +{
> > > > > > > +	if (!xen_domain())
> > > > > > > +		return false;
> > > > > > > +
> > > > > > > +	if (xen_hvm_domain()) {
> > > > > > > +		/* User requested no unplug, so no PV drivers. */
> > > > > > > +		if (xen_emul_unplug & XEN_UNPLUG_NEVER)
> > > > > > > +			return false;
> > > > > > 
> > > > > > I think you need
> > > > > > 		if (xen_emul_unpug & XEN_UNPLUG_UNNECESSARY)
> > > > > > 			return true;
> > > > > > don't you?
> > > > > 
> > > > > XEN_UNPLUG_UNNECESSARY was introduced to enable the platform PCI device
> > > > > even if it didn't respond properly to the unplug protocol.
> > > > > The corresponding parameter is called "unnecessary" because if you pass
> > > > > it to the kernel you mean that it is unnecessary to unplug the emulated
> > > > > devices but you can use the pv devices anyway.
> > > > > 
> > > > > So no, we shouldn't check for XEN_UNPLUG_UNNECESSARY here.
> > > > 
> > > > Oh, we will eventually fall through to the return true, so it does
> > > > actually work out OK.
> > > > 
> > > > I'd still be in favour of handling each option explicitly, for clarity.
> > > > Which means checking for XEN_UNPLUG_UNNECESSARY.
> > > 
> > > I think is wrong to check for any xen_emul_unpug options in this function.
> > > The xen_emul_unpug options should be used to set the right value of
> > > xen_platform_pci_unplug. (See my other reply.)
> > 
> > Whichever one we check we should still be checking explicitly for the
> > "unnecessary" case, for clarity if nothing else.
> 
> Sure, that is OK for me.
> In that case should we check for the full list of possible options?

We probably should. That probably means an extra
xen_has_pv_{disk,nic}_devices() which is the existing one plus the
specific checks?

> 
>             ide-disks -- unplug primary master IDE devices
> 			aux-ide-disks -- unplug non-primary-master IDE devices
> 			nics -- unplug network devices
> 			all -- unplug all emulated devices (NICs and IDE disks)
> 			unnecessary -- unplugging emulated devices is
> 				unnecessary even if the host did not respond to
> 				the unplug protocol
> 			never -- do not unplug even if version check succeeds
