From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: provide vhost thread per virtqueue for forwarding scenario
Date: Wed, 22 May 2013 13:10:48 +0300
Message-ID: <20130522101048.GA32671@redhat.com>
References: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com>
 <20130520074300.GA27848@redhat.com>
 <519C96E7.2030704@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, Qinchuanyu <qinchuanyu@huawei.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"nab@linux-iscsi.org" <nab@linux-iscsi.org>,
	"(netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	"(kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	"Zhangjie (HZ)" <zhang.zhangjie@huawei.com>
To: Zang Hongyong <zanghongyong@huawei.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <519C96E7.2030704@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 05:59:03PM +0800, Zang Hongyong wrote:
> On 2013/5/20 15:43, Michael S. Tsirkin wrote:
> >On Mon, May 20, 2013 at 02:11:19AM +0000, Qinchuanyu wrote:
> >>Vhost thread provide both tx and rx ability for virtio-net.
> >>In the forwarding scenarios, tx and rx share the vhost thread, and throughput is limited by single thread.
> >>
> >>So I did a patch for provide vhost thread per virtqueue, not per vhost_net.
> >>
> >>Of course, multi-queue virtio-net is final solution, but it require new version of virtio-net working in guest.
> >>If you have to work with suse10,11, redhat 5.x as guest, and want to improve the forward throughput,
> >>using vhost thread per queue seems to be the only solution.
> >Why is it? If multi-queue works well for you, just update the drivers in
> >the guests that you care about. Guest driver backport is not so hard.
> >
> >In my testing, performance of thread per vq varies: some workloads might
> >gain throughput but you get more IPIs and more scheduling overhead, so
> >you waste more host CPU per byte. As you create more VMs, this stops
> >being a win.
> >
> >>I did the test with kernel 3.0.27 and qemu-1.4.0, guest is suse11-sp2, and then two vhost thread provide
> >>double tx/rx forwarding performance than signal vhost thread.
> >>The virtqueue of vhost_blk is 1, so it still use one vhost thread without change.
> >>
> >>Is there something wrong in this solution? If not, I would list patch later.
> >>
> >>Best regards
> >>King
> >Yes, I don't think we want to create threads even more aggressively
> >in all cases. I'm worried about scalability as it is.
> >I think we should explore a flexible approach, use a thread pool
> >(for example, a wq) to share threads between virtqueues,
> >switch to a separate thread only if there's free CPU and existing
> >threads are busy. Hopefully share threads between vhost instances too.
> On Xen platform, network backend pv driver model has evolved to this
> way. Netbacks from all DomUs share a thread pool,
> and thread number eaqual to cpu core number.
> Is there any plan for kvm paltform?

Shirley Ma had a patchset like this. Look it up:
'NUMA aware scheduling per vhost thread patch'

Unfortunately I don't think we can fix the thread number: if a thread
gets blocked because its accessing a swapped out memory for guest 1, we
must allow guest 2 to make progress.

But it shouldn't be too hard to fix: detect that
a thread is blocked and spawn a new one,
or pre-create a per-guest thread and bounce the work there.

> >
> 
