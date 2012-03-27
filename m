From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 0/1] NUMA aware scheduling per vhost thread patch
Date: Tue, 27 Mar 2012 10:43:03 -0700
Message-ID: <1332870183.6496.31.camel@oc3660625478.ibm.com>
References: <1332460109.7730.18.camel@oc3660625478.ibm.com>
	 <4F7191ED.80402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, tahm@linux.vnet.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:40250 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab2C0RnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 13:43:18 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Tue, 27 Mar 2012 13:43:17 -0400
In-Reply-To: <4F7191ED.80402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-27 at 18:09 +0800, Jason Wang wrote:
> Hi:
> 
> Thanks for the work and it looks very reasonable, some questions
> below.
> 
> On 03/23/2012 07:48 AM, Shirley Ma wrote:
> > Sorry for being late to submit this patch. I have spent lots of time
> > trying to find the best approach. This effort is still going on...
> >
> > This patch is built against net-next tree.
> >
> > This is an experimental RFC patch. The purpose of this patch is to
> > address KVM networking scalability and NUMA scheduling issue.
> 
> Need also test for non-NUMA machine, I see that you just choose the
> cpu 
> that initiates the work for non-numa machine which seems sub optimal.

Good suggestions. I don't have any non-numa systems. But KK run some
tests on non-numa system. He could see around 20% performance gain for
single VMs local host to guest. I hope we can run a full test on
non-numa system.

On non-numa system, the same per vhost-cpu thread will be always picked
up consistently for a particular vq since all cores are on same cpu
socket. So there will be two per-cpu vhost threads handle TX/RX
simultaneously.

> > The existing implementation of vhost creats a vhost thread
> per-device
> > (virtio_net) based. RX and TX work of a VMs per-device is handled by
> > same vhost thread.
> >
> > One of the limitation of this implementation is with increasing the
> > number VMs or the number of virtio-net interfces, more vhost threads
> are
> > created, it will consume more kernel resources, and induce more
> threads
> > context switches/scheduling overhead. We noticed that the KVM
> network
> > performance doesn't scale with increasing number of VMs.
> >
> > The other limitation is to have single vhost thread to process both
> RX
> > and TX, the work will be blocked. So we create this per cpu vhost
> thread
> > implementation. The number of vhost cpu threads is limited to the
> number
> > of cpus on the host.
> >
> > To address these limitations, we are propsing a per-cpu vhost thread
> > model where the number of vhost threads are limited and equal to the
> > number of online cpus on the host.
> 
> The number of vhost thread needs more consideration. Consider that we 
> have a 1024 cores host with a card have 16 tx/rx queues, do we really 
> need 1024 vhost threads?

In this case, we could add a module parameter to limit the number of
cores/sockets to be used.

> >
> > Based on our testing experience, the vcpus can be scheduled across
> cpu
> > sockets even when the number of vcpus is smaller than the number of
> > cores per cpu socket and there is no other  activities besides KVM
> > networking workload. We found that if vhost thread is scheduled on
> the
> > same socket as the work is received, the performance will be better.
> >
> > So in this per cpu vhost thread implementation, a vhost thread is
> > selected dynamically based on where the TX/RX work is initiated. A
> vhost
> > thread on the same cpu socket is selected but not on the same cpu as
> the
> > vcpu/interrupt thread that initizated the TX/RX work.
> >
> > When we test this RFC patch, the other interesting thing we found is
> the
> > performance results also seem related to NIC flow steering. We are
> > spending time on evaluate different NICs flow director
> implementation
> > now. We will enhance this patch based on our findings later.
> >
> > We have tried different scheduling: per-device based, per vq based
> and
> > per work type (tx_kick, rx_kick, tx_net, rx_net) based vhost
> scheduling,
> > we found that so far the per vq based scheduling is good enough for
> now.
> 
> Could you please explain more about those scheduling strategies? Does 
> per-device based means let a dedicated vhost thread to handle all
> work 
> from that vhost device? As you mentioned, maybe an improvement of the 
> scheduling to take flow steering info (queue mapping, rxhash etc.) of 
> skb in host into account.

Yes, per-device scheduling means one per-cpu vhost theads handle all
works from one particular vhost-device.

Yes, we think scheduling to take flow steering info would help
performance. I am studying this now.

> >
> > We also tried different algorithm to select which cpu vhost thread
> will
> > running on a specific cpu socket: avg_load balance, and randomly...
> 
> May worth to account the out-of-oder packet during the test as for a 
> single stream as different cpu/vhost/physical queue may be chose to
> do 
> the packet transmission/reception?

Good point. I haven't gone through all data yet. netstat output might
tell us something.

We used Intel 10G NIC to run all test. For a single steam test, Intel
NIC receiving irq steers with same irq/queue which TX packets have been
sent. So when we mask vcpus from same VM on one socket, we shouldn't hit
packet out-of-order case. We might hit packet out of order when vcpus
run across sockets.

> >
> > > From our test results, we found that the scalability has been
> > significantly improved. And this patch is also helpful for small
> packets
> > performance.
> >
> > Hoever, we are seeing some regressions in a local guest to guest
> > scenario on a 8 cpu NUMA system.
> >
> > In one case, 24 VMs 256 bytes tcp_stream test shows it has improved
> from
> > 810Mb/s to 9.1Gb/s. :)
> > (We created two local VMs, and each VM has 2 vcpus. W/o this patch,
> the
> > number of threads is 4 vcpus + 2 vhosts = 6, w/i this patch is 4
> vcpus +
> > 8 vhosts = 12. It causes more context switches. When I change the
> > scheduling to use 2-4 vhost threads, the regressions are gone. I am
> > continue investigation on how to make small number of VMs, local
> guest
> > to gues performance better. Once I find the clue, I will share
> here.)
> >
> > The cpu hotplug support hasn't in place yet. I will post it later.
> 
> Another question is why not just using workqueue? It has full support 
> for cpu hotplug and allow more polices.

Yes, it's good to use workqueue. I just did everything on top of current
implementation so it's easy to compare/analyze the performance data.

I remembered the vhost implementation changed from workqueue to thread
for some reason. I couldn't recall the reason.

> >
> > Since we have per cpu vhost thread, each vhost thread will handle
> > multiple vqs, so we will be able to reduce/remove vq notification
> when
> > the work is heavy loaded in future.
> 
> Does this issue still exist if event index is used? If vhost does not 
> publish new used index, guest would not kick again.

Since the vhost model has been changed to handle multiple VMs' vqs work,
then it's not necessary to enable these VMs' vqs notification (published
new used idex) where these vqs' future work will be processed on the
same per-cpu vhost thread, as long as the per-cpu vhost thread is still
running.

> >
> > Here is my test results for remote host to guest test: tcp_rrs,
> udp_rrs,
> > tcp_stream with guest has 2 vpus, host has two cpu socket, each
> socket
> > has 4 cores.
> >
> > TCP_STREAM    256     512     1K      2K      4K      8K      16K
> > --------------------------------------------------------------------
> > Original
> >
> H->Guest      2501    4238    4744    5256    7203    6975    5799            Patch
> >
> H->Guest      1676    2290    3149    8026    8439    8283    8216    
> >                                                               
> > Original
> >
> Guest->H      744     1773    5675    1397    8207    7296    8117    
> > Patch
> > Guest->Host   1041    1386    5407    7057    8298    8127    8241
> 
> Looks like there's some noise in the result, the throughput of
> "original 
> guest -> Host 2K" looks too low. And some strange is that I see 
> regressions of packet transmission of guest when testing this patch.
> ( 
> Guest to Local Host TCP_STREAM in a NUMA machine).

Yes, since I didn't mask the vcpus on the same socket, it might come
from packets out of order. I will rerun the test w/i masking vcpus on
the same socket to see any difference.

You can reference Tom's results. His test is more formal than mine.

> >
> > 60 instances TCP_RRs: Patch 150K trans/s vs. 91K trans/sec
> > 65%  improved with taskset vcpus on the same socket
> > 60 instances UDP_RRs: Patch 172K trans/s vs. 103K trans/s
> > 67%  improved with taskset vcpus on the same socket
> >
> > Tom has run 1VM to 24 VMs test for different work. He will post it
> here
> > soon.
> >
> > If the host scheduler ensures that the VM's vcpus are not scheduled
> to
> > another socket (i.e. cpu mask the vcpus on same socket) then the
> > performance will be better.
> >
> > Signed-off-by: Shirley Ma<xma@us.ibm.com>
> > Signed-off-by: Krishna Kumar<krkumar2@in.ibm.com>
> > Tested-by: Tom Lendacky<toml@us.ibm.com>
> > ---
> >
> >   drivers/vhost/net.c                  |   26 ++-
> >   drivers/vhost/vhost.c                |  289
> > +++++++++++++++++++++++----------
> >   drivers/vhost/vhost.h                |   16 ++-
> >   3 files changed, 232 insertions(+), 103 deletions(-)
> >
> > Thanks
> > Shirley
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
