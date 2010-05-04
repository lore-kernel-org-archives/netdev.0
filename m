From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Tue, 4 May 2010 16:02:25 -0700
Message-ID: <20100504230225.GP8323@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pv-drivers@vmware.com, sbhatewara@vmware.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:47202 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760246Ab0EDXCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 19:02:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device passthrough technology allows a guest to bypass the hypervisor and drive
the underlying physical device. VMware has been exploring various ways to
deliver this technology to users in a manner which is easy to adopt. In this
process we have prepared an architecture along with Intel - NPA (Network Plugin
Architecture). NPA allows the guest to use the virtualized NIC vmxnet3 to
passthrough to a number of physical NICs which support it. The document below
provides an overview of NPA.

We intend to upgrade the upstreamed vmxnet3 driver to implement NPA so that
Linux users can exploit the benefits provided by passthrough devices in a
seamless manner while retaining the benefits of virtualization. The document
below tries to answer most of the questions which we anticipated. Please let us
know your comments and queries.

Thank you.

Signed-off-by: Pankaj Thakkar <pthakkar@vmware.com>


Network Plugin Architecture
---------------------------

VMware has been working on various device passthrough technologies for the past
few years. Passthrough technology is interesting as it can result in better
performance/cpu utilization for certain demanding applications. In our vSphere
product we support direct assignment of PCI devices like networking adapters to
a guest virtual machine. This allows the guest to drive the device using the
device drivers installed inside the guest. This is similar to the way KVM
allows for passthrough of PCI devices to the guests. The hypervisor is bypassed
for all I/O and control operations and hence it can not provide any value add
features such as live migration, suspend/resume, etc.

Network Plugin Architecture (NPA) is an approach which VMware has developed in
joint partnership with Intel which allows us to retain the best of passthrough
technology and virtualization. NPA allows for passthrough of the fast data
(I/O) path and lets the hypervisor deal with the slow control path using
traditional emulation/paravirtualization techniques. Through this splitting of
data and control path the hypervisor can still provide the above mentioned
value add features and exploit the performance benefits of passthrough.

NPA requires SR-IOV hardware which allows for sharing of one single NIC adapter
by multiple guests. SR-IOV hardware has many logically separate functions
called virtual functions (VF) which can be independently assigned to the guest
OS. They also have one or more physical functions (PF) (managed by a PF driver)
which are used by the hypervisor to control certain aspects of the VFs and the
rest of the hardware. NPA splits the guest driver into two components called
the Shell and the Plugin. The shell is responsible for interacting with the
guest networking stack and funneling the control operations to the hypervisor.
The plugin is responsible for driving the data path of the virtual function
exposed to the guest and is specific to the NIC hardware. NPA also requires an
embedded switch in the NIC to allow for switching traffic among the virtual
functions. The PF is also used as an uplink to provide connectivity to other
VMs which are in emulation mode. The figure below shows the major components in
a block diagram.

        +------------------------------+
        |         Guest VM             |
        |                              |
        |      +----------------+      |
        |      | vmxnet3 driver |      |
        |      |     Shell      |      |
        |      | +============+ |      |
        |      | |   Plugin   | |      |
        +------+-+------------+-+------+
                |           .
               +---------+  .
               | vmxnet3 |  .
               |___+-----+  .
                     |      .
                     |      .
                +----------------------------+
                |                            |
                |       virtual switch       |
                +----------------------------+
                  |         .               \
                  |         .                \
           +=============+  .                 \
           | PF control  |  .                  \
           |             |  .                   \
           |  L2 driver  |  .                    \
           +-------------+  .                     \
                  |         .                      \
                  |         .                       \
                +------------------------+     +------------+
                | PF   VF1 VF2 ...   VFn |     |            |
                |                        |     |  regular   |
                |       SR-IOV NIC       |     |    nic     |
                |    +--------------+    |     |   +--------+
                |    |   embedded   |    |     +---+
                |    |    switch    |    |
                |    +--------------+    |
                |        +---------------+
                +--------+

NPA offers several benefits:
1. Performance: Critical performance sensitive paths are not trapped and the
guest can directly drive the hardware without incurring virtualization
overheads.

2. Hypervisor control: All control operations from the guest such as programming
MAC address go through the hypervisor layer and hence can be subjected to
hypervisor policies. The PF driver can be further used to put policy decisions
like which VLAN the guest should be on.

3. Guest Management: No hardware specific drivers need to be installed in the
guest virtual machine and hence no overheads are incurred for guest management.
All software for the driver (including the PF driver and the plugin) is
installed in the hypervisor.

4. IHV independence: The architecture provides guidelines for splitting the
functionality between the VFs and PF but does not dictate how the hardware
should be implemented. It gives the IHV the freedom to do asynchronous updates
either to the software or the hardware to work around any defects.

The fundamental tenet in NPA is to let the hypervisor control the passthrough
functionality with minimal guest intervention. This gives a lot of flexibility
to the hypervisor which can then treat passthrough as an offload feature (just
like TSO, LRO, etc) which is offered to the guest virtual machine when there
are no conflicting features present. For example, if the hypervisor wants to
migrate the virtual machine from one host to another, the hypervisor can switch
the virtual machine out of passthrough mode into paravirtualized/emulated mode
and it can use existing technique to migrate the virtual machine. Once the
virtual machine is migrated to the destination host the hypervisor can switch
the virtual machine back to passthrough mode if a supporting SR-IOV nic is
present. This may involve reloading of a different plugin corresponding to the
new SR-IOV hardware.

Internally we have explored various other options before settling on the NPA
approach. For example there are approaches which create a bonding driver on top
of a complete passthrough of a NIC device and an emulated/paravirtualized
device. Though this approach allows for live migration to work it adds a lot of
complexity and dependency. First the hypervisor has to rely on a guest with
hot-add support. Second the hypervisor has to depend on the guest networking
stack to cooperate to perform migration. Third the guest has to carry the
driver images for all possible hardware to which the guest may migrate to.
Fourth the hypervisor does not get full control for all the policy decisions.
Another approach we have considered is to have a uniform interface for the data
path between the emulated/paravirtualized device and the hardware device which
allows the hypervisor to seamlessly switch from the emulated interface to the
hardware interface. Though this approach is very attractive and can work
without any guest involvement it is not acceptable to the IHVs as it does not
give them the freedom to fix bugs/erratas and differentiate from each other. We
believe NPA approach provides the right level of control and flexibility to the
hypervisors while letting the guest exploit the benefits of passthrough.

The plugin image is provided by the IHVs along with the PF driver and is
packaged in the hypervisor. The plugin image is OS agnostic and can be loaded
either into a Linux VM or a Windows VM. The plugin is written against the Shell
API interface which the shell is responsible for implementing. The API
interface allows the plugin to do TX and RX only by programming the hardware
rings (along with things like buffer allocation and basic initialization). The
virtual machine comes up in paravirtualized/emulated mode when it is booted.
The hypervisor allocates the VF and other resources and notifies the shell of
the availability of the VF. The hypervisor injects the plugin into memory
location specified by the shell. The shell initializes the plugin by calling
into a known entry point and the plugin initializes the data path. The control
path is already initialized by the PF driver when the VF is allocated. At this
point the shell switches to using the loaded plugin to do all further TX and RX
operations. The guest networking stack does not participate in these operations
and continues to function normally. All the control operations continue being
trapped by the hypervisor and are directed to the PF driver as needed. For
example, if the MAC address changes the hypervisor updates its internal state
and changes the state of the embedded switch as well through the PF control
API.

We have reworked our existing Linux vmxnet3 driver to accomodate NPA by
splitting the driver into two parts: Shell and Plugin. The new split driver is
backwards compatible and continues to work on old/existing vmxnet3 device
emulations. The shell implements the API interface and contains code to do the
bookkeeping for TX/RX buffers along with interrupt management. The shell code
also handles the loading of the plugin and verifying the license of the loaded
plugin. The plugin contains the code specific to vmxnet3 ring and descriptor
management. The plugin uses the same Shell API interface which would be used by
other IHVs. This vmxnet3 plugin is compiled statically along with the shell as
this is needed to provide connectivity when there is no underlying SR-IOV
device present. The IHV plugins are required to be distributed under GPL
license and we are currently looking at ways to verify this both within the
hypervisor and within the shell.
