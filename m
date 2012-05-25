From: Liu ping fan <kernelfans@gmail.com>
Subject: Re: [RFC:kvm] export host NUMA info to guest & make emulated device
 NUMA attr
Date: Fri, 25 May 2012 12:05:02 +0800
Message-ID: <CAFgQCTsA_7-DJJfSuftzrCXa3D4gs_5oF3NtfJAuRuO+RSuJsg@mail.gmail.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
	<1337357675.12999.31.camel@oc3660625478.ibm.com>
	<CAFgQCTsdXqitVGKm5jQjtC--yvZy6x04zRduJ+_tXqUnkncdog@mail.gmail.com>
	<4FBCF99F.4070409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <mashirle@us.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qemu-devel@nongnu.org, Avi Kivity <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ryan Harper <ryanh@us.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>
To: Andrew Theurer <habanero@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55908 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab2EYEFD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 00:05:03 -0400
In-Reply-To: <4FBCF99F.4070409@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 23, 2012 at 10:52 PM, Andrew Theurer
<habanero@linux.vnet.ibm.com> wrote:
> On 05/22/2012 04:28 AM, Liu ping fan wrote:
>>
>> On Sat, May 19, 2012 at 12:14 AM, Shirley Ma<mashirle@us.ibm.com> =C2=
=A0wrote:
>>>
>>> On Thu, 2012-05-17 at 17:20 +0800, Liu Ping Fan wrote:
>>>>
>>>> Currently, the guest can not know the NUMA info of the vcpu, which
>>>> will
>>>> result in performance drawback.
>>>>
>>>> This is the discovered and experiment by
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Shirley Ma<xma@us.ibm.com>
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Krishna Kumar<krkumar2@in.ibm.com>
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tom Lendacky<toml@us.ibm.com>
>>>> Refer to -
>>>> http://www.mail-archive.com/kvm@vger.kernel.org/msg69868.html
>>>> we can see the big perfermance gap between NUMA aware and unaware.
>>>>
>>>> Enlightened by their discovery, I think, we can do more work -- th=
at
>>>> is to
>>>> export NUMA info of host to guest.
>>>
>>>
>>> There three problems we've found:
>>>
>>> 1. KVM doesn't support NUMA load balancer. Even there are no other
>>> workloads in the system, and the number of vcpus on the guest is sm=
aller
>>> than the number of cpus per node, the vcpus could be scheduled on
>>> different nodes.
>>>
>>> Someone is working on in-kernel solution. Andrew Theurer has a work=
ing
>>> user-space NUMA aware VM balancer, it requires libvirt and cgroups
>>> (which is default for RHEL6 systems).
>>>
>> Interesting, and I found that "sched/numa: Introduce
>> sys_numa_{t,m}bind()" committed by Peter and Ingo may help.
>> But I think from the guest view, it can not tell whether the two vcp=
us
>> are on the same host node. For example,
>> vcpu-a in node-A is not vcpu-b in node-B, the guest lb will be more
>> expensive if it pull_task from vcpu-a and
>> choose vcpu-b to push. =C2=A0And my idea is to export such info to g=
uest,
>> still working on it.
>
>
> The long term solution is to two-fold:
> 1) Guests that are quite large (in that they cannot fit in a host NUM=
A node)
> must have static mulit-node NUMA topology implemented by Qemu. That i=
s here
> today, but we do not do it automatically, which is probably going to =
be a VM
> management responsibility.
> 2) Host scheduler and NUMA code must be enhanced to get better placem=
ent of
> Qemu memory and threads. =C2=A0For single-node vNUMA guests, this is =
easy, put it
> all in one node. =C2=A0For mulit-node vNUMA guests, the host must und=
erstand that
> some Qemu memory belongs with certain vCPU threads (which make up one=
 of the
> guests vNUMA nodes), and then place that memory/threads in a specific=
 host
> node (and continue for other memory/threads for each Qemu vNUMA node)=
=2E
>
> Note that even if a guest's memory/threads for a vNUMA node are reloc=
ated to
> another host node (which will be necessary) the NUMA characteristics =
of
> guest are still maintained (as all those vCPUs and memory are still "=
close"
> to each other).
>
Yeah, I see Peter's work on tip/sched/numa
> The problem with exposing the host's NUMA info directly to the guest =
is that
> (1) vCPUs will get relocated, so their topology info in the guest wil=
l have
> to change over time. IMO that is a bad idea. =C2=A0We have a hard eno=
ugh time
> getting applications to work with a static NUMA info. =C2=A0To get ap=
plications

I original think that vCPUS get relocated only on user demand. And
this can happen on hotplug, not happen frequently, otherwise user will
deserve the drawback.
But forget it, Peter has said no to dynamic-NUMA.
> to react to changing NUMA topology is not going to turn out well. (2)=
 Every
> single guest would have to have the same number of NUMA nodes defined=
 as the
> host. =C2=A0That is overkill, especially for small guests.
>
Thanks for your comment
pingfan
>>
>>
>>> 2. The host scheduler is not aware the relationship between guest v=
CPUs
>>> and vhost. So it's possible for host scheduler to schedule per-devi=
ce
>>> vhost thread on the same cpu on which the vCPU kick a TX packet, or
>>> schecule vhost thread on different node than the vCPU for; For RX p=
acket
>>> it's possible for vhost delivers RX packet on the vCPU running on
>>> different node too.
>>>
>> Yes. I notice this point in your original patch.
>>
>>> 3. per-device vhost thread is not scaled.
>>>
>> What about the scale-ability of per-vm * host_NUMA_NODE? When we mak=
e
>> advantage of multi-core, =C2=A0we produce mulit vcpu threads for one=
 VM.
>> So what about the emulated device? Is it acceptable to scale to take
>> advantage of host NUMA attr. =C2=A0After all, how many nodes on whic=
h the
>> VM
>> can be run on are the user's control. =C2=A0It is a balance of
>> scale-ability and performance.
>>
>>> So the problems are in host scheduling and vhost thread scalability=
=2E I
>>> am not sure how much help from exposing NUMA info from host to gues=
t.
>>>
>>> Have you tested these patched? How much performance gain here?
>>>
>> Sorry, not yet. =C2=A0As you have mentioned, the vhost thread scalab=
ility
>> is a big problem. So I want to see others' opinion before going on.
>>
>> Thanks and regards,
>> pingfan
>>
>>
>>> Thanks
>>> Shirley
>>>
>>>> So here comes the idea:
>>>> 1. export host numa info through guest's sched domain to its sched=
uler
>>>> =C2=A0 Export vcpu's NUMA info to guest scheduler(I think mem NUMA=
 problem
>>>> =C2=A0 has been handled by host). =C2=A0So the guest's lb will con=
sider the
>>>> cost.
>>>> =C2=A0 I am still working on this, and my original idea is to expo=
rt these
>>>> info
>>>> =C2=A0 through "static struct sched_domain_topology_level
>>>> *sched_domain_topology"
>>>> =C2=A0 to guest.
>>>>
>>>> 2. Do a better emulation of virt mach exported to guest.
>>>> =C2=A0 In real world, the devices are limited by kinds of reasons =
to own
>>>> the NUMA
>>>> =C2=A0 property. But as to Qemu, the device is emulated by thread,=
 which
>>>> inherit
>>>> =C2=A0 the NUMA attr in nature. =C2=A0We can implement the device =
as components
>>>> of many
>>>> =C2=A0 logic units, each of the unit is backed by a thread in diff=
erent
>>>> host node.
>>>> =C2=A0 Currently, I want to start the work on vhost. But I think, =
maybe in
>>>> =C2=A0 future, the iothread in Qemu can also has such attr.
>>>>
>>>>
>>>> Forgive me, for the limited time, I can not have more better
>>>> understand of
>>>> vhost/virtio_net drivers. These patches are just draft, _FAR_, _FA=
R_
>>>> from work.
>>>> I will do more detail work for them in future.
>>>>
>>>> To easy the review, the following is the sum up of the 2nd point o=
f
>>>> the idea.
>>>> As for the 1st point of the idea, it is not reflected in the patch=
es.
>>>>
>>>> --spread/shrink the vhost_workers over the host nodes as demanded =
from
>>>> Qemu.
>>>> =C2=A0 And we can consider each vhost_worker as an independent net=
 logic
>>>> device
>>>> =C2=A0 embeded in physical device "vhost_net". =C2=A0At the meanwh=
ile, we spread
>>>> vcpu
>>>> =C2=A0 threads over the host node.
>>>> =C2=A0 The vrings on guest are allocated PAGE_SIZE align separatel=
y, so
>>>> they can
>>>> =C2=A0 will only be mapped into different host node, so vhost_work=
er in the
>>>> same
>>>> =C2=A0 node can access it with the least cost. So does the vq on g=
uest.
>>>>
>>>> --virtio_net driver will changes and talk with the logic device. A=
nd
>>>> which
>>>> =C2=A0 logic device it will talk to is determined by on which vcpu=
 it is
>>>> scheduled.
>>>>
>>>> --the binding of vcpus and vhost_worker is implemented by:
>>>> =C2=A0 for call direction, vq-a in the node-A will have a dedicate=
d irq-a.
>>>> And
>>>> =C2=A0 we set the irq-a's affinity to vcpus in node-A.
>>>> =C2=A0 for kick direction, kick register-b trigger different event=
fd-b
>>>> which wake up
>>>> =C2=A0 vhost_worker-b.
>>>>
> -Andrew Theurer
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
