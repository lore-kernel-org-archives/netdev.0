From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 12:44:17 -0700
Message-ID: <20100505194417.GV8323@vmware.com>
References: <20100504230225.GP8323@vmware.com>
 <4BE1B217.80600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BE1B217.80600@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 05, 2010 at 10:59:51AM -0700, Avi Kivity wrote:
> Date: Wed, 5 May 2010 10:59:51 -0700
> From: Avi Kivity <avi@redhat.com>
> To: Pankaj Thakkar <pthakkar@vmware.com>
> CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
> 	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
> 	"virtualization@lists.linux-foundation.org"
>  <virtualization@lists.linux-foundation.org>,
> 	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
> 	Shreyas Bhatewara <sbhatewara@vmware.com>
> Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
> 
> On 05/05/2010 02:02 AM, Pankaj Thakkar wrote:
> > 2. Hypervisor control: All control operations from the guest such as programming
> > MAC address go through the hypervisor layer and hence can be subjected to
> > hypervisor policies. The PF driver can be further used to put policy decisions
> > like which VLAN the guest should be on.
> >    
> 
> Is this enforced?  Since you pass the hardware through, you can't rely 
> on the guest actually doing this, yes?

We don't pass the whole VF to the guest. Only the BAR which is responsible for
TX/RX/intr is mapped into guest space. The interface between the shell and
plugin only allows to do operations related to TX and RX such as send a packet
to the VF, allocate RX buffers, indicate a packet upto the shell. All control
operations are handled by the shell and the shell does what the existing
vmxnet3 drivers does (touch a specific register and let the device emulation do
the work). When a VF is mapped to the guest the hypervisor knows this and
programs the h/w accordingly on behalf of the shell. So for example if the VM
does a MAC address change inside the guest, the shell would write to
VMXNET3_REG_MAC{L|H} registers which would trigger the device emulation to read
the new mac address and update its internal virtual port information for the
virtual switch and if the VF is mapped it would also program the embedded
switch RX filters to reflect the new mac address.

> 
> > The plugin image is provided by the IHVs along with the PF driver and is
> > packaged in the hypervisor. The plugin image is OS agnostic and can be loaded
> > either into a Linux VM or a Windows VM. The plugin is written against the Shell
> > API interface which the shell is responsible for implementing. The API
> > interface allows the plugin to do TX and RX only by programming the hardware
> > rings (along with things like buffer allocation and basic initialization). The
> > virtual machine comes up in paravirtualized/emulated mode when it is booted.
> > The hypervisor allocates the VF and other resources and notifies the shell of
> > the availability of the VF. The hypervisor injects the plugin into memory
> > location specified by the shell. The shell initializes the plugin by calling
> > into a known entry point and the plugin initializes the data path. The control
> > path is already initialized by the PF driver when the VF is allocated. At this
> > point the shell switches to using the loaded plugin to do all further TX and RX
> > operations. The guest networking stack does not participate in these operations
> > and continues to function normally. All the control operations continue being
> > trapped by the hypervisor and are directed to the PF driver as needed. For
> > example, if the MAC address changes the hypervisor updates its internal state
> > and changes the state of the embedded switch as well through the PF control
> > API.
> >    
> 
> This is essentially a miniature network stack with a its own mini 
> bonding layer, mini hotplug, and mini API, except s/API/ABI/.  Is this a 
> correct view?

To some extent yes but there is no complicated bonding nor there is any thing
like a PCI hotplug. The shell interface is small and the OS always interacts
with the shell as the main driver. Based on the underlying VF the plugin
changes and this plugin as well is really small. Our vmxnet3 s/w plugin is
about 1300 lines with whitespaces and comments and the Intel Kawela plugin is
about 1100 lines with whitspaces and comments. The design principle is to put
more of the complexity related to initialization/control into the PF driver
rather than in plugin.

> 
> If so, the Linuxy approach would be to use the ordinary drivers and the 
> Linux networking API, and hide the bond setup using namespaces.  The 
> bond driver, or perhaps a new, similar, driver can be enhanced to 
> propagate ethtool commands to its (hidden) components, and to have a 
> control channel with the hypervisor.
> 
> This would make the approach hypervisor agnostic, you're just pairing 
> two devices and presenting them to the rest of the stack as a single device.
> 
> > We have reworked our existing Linux vmxnet3 driver to accomodate NPA by
> > splitting the driver into two parts: Shell and Plugin. The new split driver is
> >    
> 
> So the Shell would be the reworked or new bond driver, and Plugins would 
> be ordinary Linux network drivers.

In NPA we do not rely on the guest OS to provide any of these services like
bonding or PCI hotplug. We don't rely on the guest OS to unmap a VF and switch
a VM out of passthrough. In a bonding approach that becomes an issue you can't
just yank a device from underneath, you have to wait for the OS to process the
request and switch from using VF to the emulated device and this makes the
hypervisor dependent on the guest OS. Also we don't rely on the presence of all
the drivers inside the guest OS (be it Linux or Windows), the ESX hypervisor
carries all the plugins and the PF drivers and injects the right one as needed.
These plugins are guest agnostic and the IHVs do not have to write plugins for
different OS.


Thanks,

-pankaj

 
