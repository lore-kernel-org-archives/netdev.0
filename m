From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] vhost: net: switch to use data copy if pending DMAs
	exceed the limit
Date: Wed, 26 Feb 2014 11:23:40 +0200
Message-ID: <20140226092340.GB5236@redhat.com>
References: <1393311238-7750-1-git-send-email-jasowang@redhat.com>
	<20140225135738.GA15274@redhat.com> <530D814E.2080708@redhat.com>
	<530D8A91.6080206@huawei.com> <530D9399.4050306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Qin Chuanyu <qinchuanyu@huawei.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <530D9399.4050306@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 03:11:21PM +0800, Jason Wang wrote:
> On 02/26/2014 02:32 PM, Qin Chuanyu wrote:
> >On 2014/2/26 13:53, Jason Wang wrote:
> >>On 02/25/2014 09:57 PM, Michael S. Tsirkin wrote:
> >>>On Tue, Feb 25, 2014 at 02:53:58PM +0800, Jason Wang wrote:
> >>>>We used to stop the handling of tx when the number of pending DMAs
> >>>>exceeds VHOST_MAX_PEND. This is used to reduce the memory occupation
> >>>>of both host and guest. But it was too aggressive in some cases, since
> >>>>any delay or blocking of a single packet may delay or block the guest
> >>>>transmission. Consider the following setup:
> >>>>
> >>>>     +-----+        +-----+
> >>>>     | VM1 |        | VM2 |
> >>>>     +--+--+        +--+--+
> >>>>        |              |
> >>>>     +--+--+        +--+--+
> >>>>     | tap0|        | tap1|
> >>>>     +--+--+        +--+--+
> >>>>        |              |
> >>>>     pfifo_fast   htb(10Mbit/s)
> >>>>        |              |
> >>>>     +--+--------------+---+
> >>>>     |     bridge          |
> >>>>     +--+------------------+
> >>>>        |
> >>>>     pfifo_fast
> >>>>        |
> >>>>     +-----+
> >>>>     | eth0|(100Mbit/s)
> >>>>     +-----+
> >>>>
> >>>>- start two VMs and connect them to a bridge
> >>>>- add an physical card (100Mbit/s) to that bridge
> >>>>- setup htb on tap1 and limit its throughput to 10Mbit/s
> >>>>- run two netperfs in the same time, one is from VM1 to VM2.
> >>>>Another is
> >>>>   from VM1 to an external host through eth0.
> >>>>- result shows that not only the VM1 to VM2 traffic were throttled but
> >>>>   also the VM1 to external host through eth0 is also
> >>>>throttled somehow.
> >>>>
> >>>>This is because the delay added by htb may lead the delay the finish
> >>>>of DMAs and cause the pending DMAs for tap0 exceeds the limit
> >>>>(VHOST_MAX_PEND). In this case vhost stop handling tx request until
> >>>>htb send some packets. The problem here is all of the packets
> >>>>transmission were blocked even if it does not go to VM2.
> >>>>
> >>>>We can solve this issue by relaxing it a little bit: switching to use
> >>>>data copy instead of stopping tx when the number of pending DMAs
> >>>>exceed the VHOST_MAX_PEND. This is safe because:
> >>>>
> >>>>- The number of pending DMAs were still limited by VHOST_MAX_PEND
> >>>>- The out of order completion during mode switch can make sure that
> >>>>   most of the tx buffers were freed in time in guest.
> >>>>
> >>>>So even if about 50% packets were delayed in zero-copy case, vhost
> >>>>could continue to do the transmission through data copy in this case.
> >>>>
> >>>>Test result:
> >>>>
> >>>>Before this patch:
> >>>>VM1 to VM2 throughput is 9.3Mbit/s
> >>>>VM1 to External throughput is 40Mbit/s
> >>>>
> >>>>After this patch:
> >>>>VM1 to VM2 throughput is 9.3Mbit/s
> >>>>Vm1 to External throughput is 93Mbit/s
> >>>Would like to see CPU utilization #s as well.
> >>>
> >>
> >>Will measure this.
> >>>>Simple performance test on 40gbe shows no obvious changes in
> >>>>throughput after this patch.
> >>>>
> >>>>The patch only solve this issue when unlimited sndbuf. We still need a
> >>>>solution for limited sndbuf.
> >>>>
> >>>>Cc: Michael S. Tsirkin<mst@redhat.com>
> >>>>Cc: Qin Chuanyu<qinchuanyu@huawei.com>
> >>>>Signed-off-by: Jason Wang<jasowang@redhat.com>
> >>>I think this needs some thought.
> >>>
> >>>In particular I think this works because VHOST_MAX_PEND
> >>>is much smaller than the ring size.
> >>>Shouldn't max_pend then be tied to the ring size if it's small?
> >>>
> >>
> >>Yes it should. I just reuse the VHOST_MAX_PEND since it was there for a
> >>long time.
> >>>Another question is about stopping vhost:
> >>>ATM it's waiting for skbs to complete.
> >>>Should we maybe hunt down skbs queued and destroy them
> >>>instead?
> >>>I think this happens when a device is removed.
> >>>
> >>>Thoughts?
> >>>
> >>
> >>Agree, vhost net removal should not be blocked by a skb. But since the
> >>skbs could be queued may places, just destroy them may need extra locks.
> >>
> >>Haven't thought this deeply, but another possible sloution is to rcuify
> >>destructor_arg and assign it to NULL during vhost_net removing.
> >
> >Xen treat it by a timer, for those skbs which has been delivered for a
> >while, netback would exchange page of zero_copy's skb with dom0's page.
> >
> >but there is still a race between host's another process handle the skb
> >and netback exchange its page. (This problem has been proved by testing)
> >
> >and Xen hasn't solved this problem yet, because if anyone want to solve
> >this problem completely, a page lock is necessary, but it would be
> >complex and expensive.
> >
> >rcuify destructor arg and assign it to NULL couldn't solve the problem
> >of page release that has been reserved by host's another process.
> >
> 
> There're two issues:
> 
> 1) if a zerocopy skb won't be freed or frags orphaned in time,
> vhost_net removal will be blocked since it was waiting for the
> refcnt of ubuf to zero.
> 2) whether or not we should free all pending skbs during vhost_net removing.

all pending *zero copy* skbs.

> My proposal is for issue 1. Another idea is not wait for the refcnt
> to be zero and then we can defer the freeing of vhost_net during the
> release method of kref_put().

It's not freeing that's at issue. We must not access guest memory
after vhost stop, too.

> For issue 2, I'm still not sure we should do this or not. Looks like
> there's a similar issue for the packets sent by tcp_sendpage() was
> blocked or delayed.

What's the issue exactly? How would you trigger it?

> >The key problem is how to release the memory of zero_copy's skb while
> >been reserved.
