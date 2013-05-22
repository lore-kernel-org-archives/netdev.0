From: Zang Hongyong <zanghongyong@huawei.com>
Subject: Re: provide vhost thread per virtqueue for forwarding scenario
Date: Wed, 22 May 2013 17:59:03 +0800
Message-ID: <519C96E7.2030704@huawei.com>
References: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com> <20130520074300.GA27848@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Qinchuanyu <qinchuanyu@huawei.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"nab@linux-iscsi.org" <nab@linux-iscsi.org>,
	"(netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	"(kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	"Zhangjie (HZ)" <zhang.zhangjie@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3891 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab3EVKBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 06:01:05 -0400
In-Reply-To: <20130520074300.GA27848@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/5/20 15:43, Michael S. Tsirkin wrote:
> On Mon, May 20, 2013 at 02:11:19AM +0000, Qinchuanyu wrote:
>> Vhost thread provide both tx and rx ability for virtio-net.
>> In the forwarding scenarios, tx and rx share the vhost thread, and throughput is limited by single thread.
>>
>> So I did a patch for provide vhost thread per virtqueue, not per vhost_net.
>>
>> Of course, multi-queue virtio-net is final solution, but it require new version of virtio-net working in guest.
>> If you have to work with suse10,11, redhat 5.x as guest, and want to improve the forward throughput,
>> using vhost thread per queue seems to be the only solution.
> Why is it? If multi-queue works well for you, just update the drivers in
> the guests that you care about. Guest driver backport is not so hard.
>
> In my testing, performance of thread per vq varies: some workloads might
> gain throughput but you get more IPIs and more scheduling overhead, so
> you waste more host CPU per byte. As you create more VMs, this stops
> being a win.
>
>> I did the test with kernel 3.0.27 and qemu-1.4.0, guest is suse11-sp2, and then two vhost thread provide
>> double tx/rx forwarding performance than signal vhost thread.
>> The virtqueue of vhost_blk is 1, so it still use one vhost thread without change.
>>
>> Is there something wrong in this solution? If not, I would list patch later.
>>
>> Best regards
>> King
> Yes, I don't think we want to create threads even more aggressively
> in all cases. I'm worried about scalability as it is.
> I think we should explore a flexible approach, use a thread pool
> (for example, a wq) to share threads between virtqueues,
> switch to a separate thread only if there's free CPU and existing
> threads are busy. Hopefully share threads between vhost instances too.
On Xen platform, network backend pv driver model has evolved to this 
way. Netbacks from all DomUs share a thread pool,
and thread number eaqual to cpu core number.
Is there any plan for kvm paltform?
>
