From: Liu ping fan <kernelfans@gmail.com>
Subject: Re: [RFC:kvm] export host NUMA info to guest & make
 emulated device NUMA attr
Date: Fri, 25 May 2012 11:29:42 +0800
Message-ID: <CAFgQCTuKh2=xkzW594SuV6++xXKojionOk2=y-O8MzXRM1WHKQ@mail.gmail.com>
References: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
	<1337357675.12999.31.camel@oc3660625478.ibm.com>
	<CAFgQCTsdXqitVGKm5jQjtC--yvZy6x04zRduJ+_tXqUnkncdog@mail.gmail.com>
	<4FBCF99F.4070409@linux.vnet.ibm.com>
	<20120523151604.GB30542@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Krishna Kumar <krkumar2@in.ibm.com>,
	Andrew Theurer <habanero@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Shirley Ma <xma@us.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Shirley Ma <mashirle@us.ibm.com>,
	qemu-devel@nongnu.org, linux-kernel@vger.kernel.org,
	Tom Lendacky <toml@us.ibm.com>, Ryan Harper <ryanh@us.ibm.com>,
	Avi Kivity <avi@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20120523151604.GB30542@redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2012 at 11:16 PM, Michael S. Tsirkin <mst@redhat.com> wrote=
:
> On Wed, May 23, 2012 at 09:52:15AM -0500, Andrew Theurer wrote:
>> On 05/22/2012 04:28 AM, Liu ping fan wrote:
>> >On Sat, May 19, 2012 at 12:14 AM, Shirley Ma<mashirle@us.ibm.com> =C2=
=A0wrote:
>> >>On Thu, 2012-05-17 at 17:20 +0800, Liu Ping Fan wrote:
>> >>>Currently, the guest can not know the NUMA info of the vcpu, which
>> >>>will
>> >>>result in performance drawback.
>> >>>
>> >>>This is the discovered and experiment by
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Shirley Ma<xma@us.ibm.com>
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Krishna Kumar<krkumar2@in.ibm.com>
>> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tom Lendacky<toml@us.ibm.com>
>> >>>Refer to -
>> >>>http://www.mail-archive.com/kvm@vger.kernel.org/msg69868.html
>> >>>we can see the big perfermance gap between NUMA aware and unaware.
>> >>>
>> >>>Enlightened by their discovery, I think, we can do more work -- that
>> >>>is to
>> >>>export NUMA info of host to guest.
>> >>
>> >>There three problems we've found:
>> >>
>> >>1. KVM doesn't support NUMA load balancer. Even there are no other
>> >>workloads in the system, and the number of vcpus on the guest is small=
er
>> >>than the number of cpus per node, the vcpus could be scheduled on
>> >>different nodes.
>> >>
>> >>Someone is working on in-kernel solution. Andrew Theurer has a working
>> >>user-space NUMA aware VM balancer, it requires libvirt and cgroups
>> >>(which is default for RHEL6 systems).
>> >>
>> >Interesting, and I found that "sched/numa: Introduce
>> >sys_numa_{t,m}bind()" committed by Peter and Ingo may help.
>> >But I think from the guest view, it can not tell whether the two vcpus
>> >are on the same host node. For example,
>> >vcpu-a in node-A is not vcpu-b in node-B, the guest lb will be more
>> >expensive if it pull_task from vcpu-a and
>> >choose vcpu-b to push. =C2=A0And my idea is to export such info to gues=
t,
>> >still working on it.
>>
>> The long term solution is to two-fold:
>> 1) Guests that are quite large (in that they cannot fit in a host
>> NUMA node) must have static mulit-node NUMA topology implemented by
>> Qemu. That is here today, but we do not do it automatically, which
>> is probably going to be a VM management responsibility.
>> 2) Host scheduler and NUMA code must be enhanced to get better
>> placement of Qemu memory and threads. =C2=A0For single-node vNUMA guests=
,
>> this is easy, put it all in one node. =C2=A0For mulit-node vNUMA guests,
>> the host must understand that some Qemu memory belongs with certain
>> vCPU threads (which make up one of the guests vNUMA nodes), and then
>> place that memory/threads in a specific host node (and continue for
>> other memory/threads for each Qemu vNUMA node).
>
> And for IO, we need multiqueue devices such that each
> node can have its own queue in its local memory.
>
Yes, my patches include such solution. Independent device sub logic
units are seated in different NUMA node, "subdev" in the patches
stands for the logic unit. And each of they are backed by a
vhost-thread.  On the other hand, for virtio-guest, the vqs(including
vrings) are allocated align at the PAGE_SIZE, so their NUMA problem
will be resolved automatically by KVM(maybe a little more effort
needed here).

I had thought to export the real host NUMA info to virtio layer (not
scheduler,that is another topic). So we can create the exact num of
logic unit as needed.
And we even can increase/decrease the logic unit.

But what hesitate me to move on is that is it acceptable to create
independent vhost-thread for each node as the user's demand?
And the scalability is perVM *demand_node_num.  Object?


Thanks,
pingfan



> --
> MST
