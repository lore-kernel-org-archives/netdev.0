From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Tue, 07 Oct 2014 08:55:23 -0700
Message-ID: <54340CEB.204@intel.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <CA+FuTSfwTBtZLu7CXh4bPxUtVubOvpCPo+O38BsnSiLdvV_KEA@mail.gmail.com> <DFDF335405C17848924A094BC35766CF0A953308@SHSMSX104.ccr.corp.intel.com> <CA+FuTSe=vo1-Xpk+318SNc-mCH_c0WQadXo3usiA_dRBNx_fEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Willem de Bruijn <willemb@google.com>,
	"Zhou, Danny" <danny.zhou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46425 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189AbaJGPzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 11:55:49 -0400
In-Reply-To: <CA+FuTSe=vo1-Xpk+318SNc-mCH_c0WQadXo3usiA_dRBNx_fEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2014 08:46 AM, Willem de Bruijn wrote:
>>>> Typically in an af_packet interface a packet_type handler is
>>>> registered and used to filter traffic to the socket and do other
>>>> things such as fan out traffic to multiple sockets. In this case the
>>>> networking stack is being bypassed so this code is not run. So the
>>>> hardware must push the correct traffic to the queues obtained from
>>>> the ndo callback ndo_split_queue_pairs().
>>>
>>> Why does the interface work at the level of queue_pairs instead of
>>> individual queues?
>>
>> The user mode "slave" driver(I call it slave driver because it is only responsible for packet I/O
>> on certain queue pairs) needs at least take over one rx queue and one tx queue for ingress and
>> egress traffics respectively, although the flow director only applies to ingress traffics.
> 
> That requirement of co-allocation is absent in existing packet
> rings. Many applications only receive or transmit. For
> receive-only, it would even be possible to map descriptor
> rings read-only, if the kernel remains responsible for posting
> buffers -- but I see below that that is not the case, so that's
> not very relevant here.
> 
> Still, some workloads want asymmetric sets of rx and tx rings.
> For instance, instead of using RSS, a process may want to
> receive on as few rings as possible, load balance across
> workers in software, but still give each worker thread its own
> private transmit ring.
> 

We can build this into the interface by having the setsockopt
provide both the number of tx rings and number of rx rings. It
might not be immediately available in any drivers because at
least ixgbe is pretty dependent on tx/rx pairing.

I would have to look through the other drivers to see how
much work it would be to support this on them. If I can't find
a good candidate we might leave it out until we can fix up the
drivers.

> 
>>>
>>>>         /* Get the layout of ring space offset, page_sz, cnt */
>>>>         getsockopt(fd, SOL_PACKET, PACKET_DEV_QPAIR_MAP_REGION_INFO,
>>>>                    &info, &optlen);
>>>>
>>>>         /* request some queues from the driver */
>>>>         setsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
>>>>                    &qpairs_info, sizeof(qpairs_info));
>>>>
>>>>         /* if we let the driver pick us queues learn which queues
>>>>          * we were given
>>>>          */
>>>>         getsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
>>>>                    &qpairs_info, sizeof(qpairs_info));
>>>
>>> If ethtool -U is used to steer traffic to a specific descriptor queue,
>>> then the setsockopt can pass the exact id of that queue and there
>>> is no need for a getsockopt follow-up.
>>
>> Very good point, it supports pass "-1" as queue id(following by number of qpairs needed) via
>> setsockopt to af_packet and NIC kernel driver to ask the driver dynamically allocate free and
>> available qpairs for this socket, so getsockopt() is needed to return the actually assigned queue pair indexes.
>> Initially, we had a implementation that calls getsockopt once and af_packet treats qpairs_info
>> as a IN/OUT parameter, but it is semantic wrong, so we think above implementation is most suitable.
>> But I agree with you, if setsockopt can pass the exact id with a valid queue pair index, there is no need
>> to call getsocketopt.
> 
> One step further would be to move the entire configuration behind
> the packet socket interface. It's perhaps out of scope of this patch,
> but the difference between using `ethtool -U` and passing the same
> expression through the packet socket is that in the latter case the
> kernel can automatically rollback the configuration change when the
> process dies.
> 

hmm might be interesting I think  this is a follow on path to
investigate after the initial support.

>>
>>>
>>>>         /* And mmap queue pairs to user space */
>>>>         mmap(NULL, info.tp_dev_bar_sz, PROT_READ | PROT_WRITE,
>>>>              MAP_SHARED, fd, 0);
>>>
>>> How will packet data be mapped and how will userspace translate
>>> from paddr to vaddr? Is the goal to maintain long lived mappings
>>> and instruct drivers to allocate from this restricted range (to
>>> avoid per-packet system calls and vma operations)?
>>>
>>
>> Once qpairs split-off is done, the user space driver, as a slave driver, will re-initialize those queues
>> completely in user space by using paddr(in the case of DPDK, vaddr of DPDK used huge pages
>> are translated to paddr) to fill in the packet descriptors.
> 
> Ah, userspace is responsible for posting buffers and translation
> from vaddr to paddr is straightforward. Yes that makes sense.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
