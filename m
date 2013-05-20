From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: provide vhost thread per virtqueue for forwarding scenario
Date: Mon, 20 May 2013 10:43:00 +0300
Message-ID: <20130520074300.GA27848@redhat.com>
References: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"nab@linux-iscsi.org" <nab@linux-iscsi.org>,
	" (netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	" (kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	Zanghongyong <zanghongyong@huawei.com>,
	"Zhangjie (HZ)" <zhang.zhangjie@huawei.com>
To: Qinchuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240Ab3ETHoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 03:44:25 -0400
Content-Disposition: inline
In-Reply-To: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 02:11:19AM +0000, Qinchuanyu wrote:
> Vhost thread provide both tx and rx ability for virtio-net. 
> In the forwarding scenarios, tx and rx share the vhost thread, and throughput is limited by single thread.
> 
> So I did a patch for provide vhost thread per virtqueue, not per vhost_net.
> 
> Of course, multi-queue virtio-net is final solution, but it require new version of virtio-net working in guest.
> If you have to work with suse10,11, redhat 5.x as guest, and want to improve the forward throughput,
> using vhost thread per queue seems to be the only solution.

Why is it? If multi-queue works well for you, just update the drivers in
the guests that you care about. Guest driver backport is not so hard.

In my testing, performance of thread per vq varies: some workloads might
gain throughput but you get more IPIs and more scheduling overhead, so
you waste more host CPU per byte. As you create more VMs, this stops
being a win.

> 
> I did the test with kernel 3.0.27 and qemu-1.4.0, guest is suse11-sp2, and then two vhost thread provide 
> double tx/rx forwarding performance than signal vhost thread. 
> The virtqueue of vhost_blk is 1, so it still use one vhost thread without change.
> 
> Is there something wrong in this solution? If not, I would list patch later.
> 
> Best regards
> King

Yes, I don't think we want to create threads even more aggressively
in all cases. I'm worried about scalability as it is.
I think we should explore a flexible approach, use a thread pool
(for example, a wq) to share threads between virtqueues,
switch to a separate thread only if there's free CPU and existing
threads are busy. Hopefully share threads between vhost instances too.

-- 
MST
