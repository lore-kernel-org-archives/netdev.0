From: Avi Kivity <avi@redhat.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 05 May 2010 20:59:51 +0300
Message-ID: <4BE1B217.80600@redhat.com>
References: <20100504230225.GP8323@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pv-drivers@vmware.com,
	sbhatewara@vmware.com
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100504230225.GP8323@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/05/2010 02:02 AM, Pankaj Thakkar wrote:
> 2. Hypervisor control: All control operations from the guest such as programming
> MAC address go through the hypervisor layer and hence can be subjected to
> hypervisor policies. The PF driver can be further used to put policy decisions
> like which VLAN the guest should be on.
>    

Is this enforced?  Since you pass the hardware through, you can't rely 
on the guest actually doing this, yes?

> The plugin image is provided by the IHVs along with the PF driver and is
> packaged in the hypervisor. The plugin image is OS agnostic and can be loaded
> either into a Linux VM or a Windows VM. The plugin is written against the Shell
> API interface which the shell is responsible for implementing. The API
> interface allows the plugin to do TX and RX only by programming the hardware
> rings (along with things like buffer allocation and basic initialization). The
> virtual machine comes up in paravirtualized/emulated mode when it is booted.
> The hypervisor allocates the VF and other resources and notifies the shell of
> the availability of the VF. The hypervisor injects the plugin into memory
> location specified by the shell. The shell initializes the plugin by calling
> into a known entry point and the plugin initializes the data path. The control
> path is already initialized by the PF driver when the VF is allocated. At this
> point the shell switches to using the loaded plugin to do all further TX and RX
> operations. The guest networking stack does not participate in these operations
> and continues to function normally. All the control operations continue being
> trapped by the hypervisor and are directed to the PF driver as needed. For
> example, if the MAC address changes the hypervisor updates its internal state
> and changes the state of the embedded switch as well through the PF control
> API.
>    

This is essentially a miniature network stack with a its own mini 
bonding layer, mini hotplug, and mini API, except s/API/ABI/.  Is this a 
correct view?

If so, the Linuxy approach would be to use the ordinary drivers and the 
Linux networking API, and hide the bond setup using namespaces.  The 
bond driver, or perhaps a new, similar, driver can be enhanced to 
propagate ethtool commands to its (hidden) components, and to have a 
control channel with the hypervisor.

This would make the approach hypervisor agnostic, you're just pairing 
two devices and presenting them to the rest of the stack as a single device.

> We have reworked our existing Linux vmxnet3 driver to accomodate NPA by
> splitting the driver into two parts: Shell and Plugin. The new split driver is
>    

So the Shell would be the reworked or new bond driver, and Plugins would 
be ordinary Linux network drivers.


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.
