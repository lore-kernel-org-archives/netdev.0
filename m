From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC:kvm] export host NUMA info to guest & make emulated
 device NUMA attr
Date: Fri, 18 May 2012 09:14:35 -0700
Message-ID: <1337357675.12999.31.camel@oc3660625478.ibm.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qemu-devel@nongnu.org,
	Avi Kivity <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ryan Harper <ryanh@us.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>
To: Liu Ping Fan <kernelfans@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-17 at 17:20 +0800, Liu Ping Fan wrote:
> Currently, the guest can not know the NUMA info of the vcpu, which
> will
> result in performance drawback.
> 
> This is the discovered and experiment by
>         Shirley Ma <xma@us.ibm.com>
>         Krishna Kumar <krkumar2@in.ibm.com>
>         Tom Lendacky <toml@us.ibm.com>
> Refer to -
> http://www.mail-archive.com/kvm@vger.kernel.org/msg69868.html
> we can see the big perfermance gap between NUMA aware and unaware.
> 
> Enlightened by their discovery, I think, we can do more work -- that
> is to
> export NUMA info of host to guest.

There three problems we've found:

1. KVM doesn't support NUMA load balancer. Even there are no other
workloads in the system, and the number of vcpus on the guest is smaller
than the number of cpus per node, the vcpus could be scheduled on
different nodes. 

Someone is working on in-kernel solution. Andrew Theurer has a working
user-space NUMA aware VM balancer, it requires libvirt and cgroups
(which is default for RHEL6 systems).

2. The host scheduler is not aware the relationship between guest vCPUs
and vhost. So it's possible for host scheduler to schedule per-device
vhost thread on the same cpu on which the vCPU kick a TX packet, or
schecule vhost thread on different node than the vCPU for; For RX packet
it's possible for vhost delivers RX packet on the vCPU running on
different node too.

3. per-device vhost thread is not scaled.

So the problems are in host scheduling and vhost thread scalability. I
am not sure how much help from exposing NUMA info from host to guest.

Have you tested these patched? How much performance gain here?

Thanks
Shirley 

> So here comes the idea:
> 1. export host numa info through guest's sched domain to its scheduler
>   Export vcpu's NUMA info to guest scheduler(I think mem NUMA problem
>   has been handled by host).  So the guest's lb will consider the
> cost.
>   I am still working on this, and my original idea is to export these
> info
>   through "static struct sched_domain_topology_level
> *sched_domain_topology"
>   to guest.
> 
> 2. Do a better emulation of virt mach exported to guest.
>   In real world, the devices are limited by kinds of reasons to own
> the NUMA
>   property. But as to Qemu, the device is emulated by thread, which
> inherit
>   the NUMA attr in nature.  We can implement the device as components
> of many
>   logic units, each of the unit is backed by a thread in different
> host node.
>   Currently, I want to start the work on vhost. But I think, maybe in
>   future, the iothread in Qemu can also has such attr.
> 
> 
> Forgive me, for the limited time, I can not have more better
> understand of
> vhost/virtio_net drivers. These patches are just draft, _FAR_, _FAR_
> from work.
> I will do more detail work for them in future.
> 
> To easy the review, the following is the sum up of the 2nd point of
> the idea.
> As for the 1st point of the idea, it is not reflected in the patches.
> 
> --spread/shrink the vhost_workers over the host nodes as demanded from
> Qemu.
>   And we can consider each vhost_worker as an independent net logic
> device
>   embeded in physical device "vhost_net".  At the meanwhile, we spread
> vcpu
>   threads over the host node. 
>   The vrings on guest are allocated PAGE_SIZE align separately, so
> they can 
>   will only be mapped into different host node, so vhost_worker in the
> same
>   node can access it with the least cost. So does the vq on guest.
> 
> --virtio_net driver will changes and talk with the logic device. And
> which
>   logic device it will talk to is determined by on which vcpu it is
> scheduled.
> 
> --the binding of vcpus and vhost_worker is implemented by: 
>   for call direction, vq-a in the node-A will have a dedicated irq-a.
> And 
>   we set the irq-a's affinity to vcpus in node-A.
>   for kick direction, kick register-b trigger different eventfd-b
> which wake up
>   vhost_worker-b.
> 
> 
> 

