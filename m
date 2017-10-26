From: Wei Xu <wexu@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Thu, 26 Oct 2017 17:44:15 +0800
Message-ID: <20171026094415.uyogf2iw7yoavnoc@Wei-Dev>
References: <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
 <1173ab1f-e2b6-26b3-8c3c-bd5ceaa1bd8e@redhat.com>
 <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
 <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
 <c0b42b27-56f6-c2f9-9476-28d25678808a@linux.vnet.ibm.com>
 <376f8939-1990-abf6-1f5f-57b3822f94fe@redhat.com>
 <c117c0c5-7fc0-013b-6f54-2e722d115101@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
        netdev@vger.kernel.org, davem@davemloft.net
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53570 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751160AbdJZJX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 05:23:28 -0400
Content-Disposition: inline
In-Reply-To: <c117c0c5-7fc0-013b-6f54-2e722d115101@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 04:21:26PM -0400, Matthew Rosato wrote:
> On 10/22/2017 10:06 PM, Jason Wang wrote:
> > 
> > 
> > On 2017年10月19日 04:17, Matthew Rosato wrote:
> >>> 2. It might be useful to short the traffic path as a reference, What
> >>> I am running
> >>> is briefly like:
> >>>      pktgen(host kernel) -> tap(x) -> guest(DPDK testpmd)
> >>>
> >>> The bridge driver(br_forward(), etc) might impact performance due to
> >>> my personal
> >>> experience, so eventually I settled down with this simplified testbed
> >>> which fully
> >>> isolates the traffic from both userspace and host kernel stack(1 and
> >>> 50 instances,
> >>> bridge driver, etc), therefore reduces potential interferences.
> >>>
> >>> The down side of this is that it needs DPDK support in guest, has
> >>> this ever be
> >>> run on s390x guest? An alternative approach is to directly run XDP
> >>> drop on
> >>> virtio-net nic in guest, while this requires compiling XDP inside
> >>> guest which needs
> >>> a newer distro(Fedora 25+ in my case or Ubuntu 16.10, not sure).
> >>>
> >> I made an attempt at DPDK, but it has not been run on s390x as far as
> >> I'm aware and didn't seem trivial to get working.
> >>
> >> So instead I took your alternate suggestion & did:
> >> pktgen(host) -> tap(x) -> guest(xdp_drop)
> >>
> >> When running this setup, I am not able to reproduce the regression.  As
> >> mentioned previously, I am also unable to reproduce when running one end
> >> of the uperf connection from the host - I have only ever been able to
> >> reproduce when both ends of the uperf connection are running within a
> >> guest.
> >>
> > 
> > Thanks for the test. Looking at the code, the only obvious difference
> > when BATCH is 1 is that one spinlock which was previously called by
> > tun_peek_len() was avoided since we can do it locally. I wonder whether
> > or not this speeds up handle_rx() a little more then leads more wakeups
> > during some rates/sizes of TCP stream. To prove this, maybe you can try:
> > 
> > - enable busy polling, using poll-us=1000, and to see if we can still
> > get the regression
> 
> Enabled poll-us=1000 for both guests - drastically reduces throughput,
> but can still see the regression between host 4.12->4.13 running the
> uperf workload
> 
> 
> > - measure the pps pktgen(vm1) -> tap1 -> bridge -> tap2 -> vm2
> > 
> 
> I'm getting apparent stalls when I run pktgen from the guest in this
> manner...  (pktgen thread continues spinning after the first 5000
> packets make it to vm2, but no further packets get sent).  Not sure why yet.
> 


Are you using the same binding as mentioned in previous mail sent by you? it
might be caused by cpu convention between pktgen and vhost, could you please
try to run pktgen from another idle cpu by adjusting the binding? 
 
BTW, did you see any improvement when running pktgen from the host if no 
regression was found? Since this can be reproduced with only 1 vcpu for
guest, may you try this bind? This might help simplify the problem.
  vcpu0  -> cpu2
  vhost  -> cpu3
  pktgen -> cpu1 

Wei
