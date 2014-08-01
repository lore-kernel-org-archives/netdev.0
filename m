From: Jason Wang <jasowang@redhat.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and virtio_net
 during migration?
Date: Fri, 01 Aug 2014 19:14:49 +0800
Message-ID: <53DB76A9.8010305@redhat.com>
References: <53DA2CCC.1040606@huawei.com> <20140731143100.GA3834@redhat.com> <20140731143725.GA3875@redhat.com> <53DB705F.2000405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qinchuanyu@huawei.com,
	liuyongan@huawei.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>,
	"Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbaHALPB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 07:15:01 -0400
In-Reply-To: <53DB705F.2000405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 06:47 PM, Jason Wang wrote:
> On 07/31/2014 10:37 PM, Michael S. Tsirkin wrote:
>> > On Thu, Jul 31, 2014 at 04:31:00PM +0200, Michael S. Tsirkin wrote:
>>>> >> > On Thu, Jul 31, 2014 at 07:47:24PM +0800, Zhangjie (HZ) wrote:
>>>>>> >>> > > [The test scenario]:
>>>>>> >>> > > 
>>>>>> >>> > > Doing migration between two Hosts roundly(A->B, B->A) ,after about 20 times, network of the VM is unreachable.
>>>>>> >>> > > There are other 20 VMs in each Host, and they send ipv4 or ipv6 and multicast packets to each other.
>>>>>> >>> > > Sometimes the CPU idle of the Host maybe 0;
>>>>>> >>> > > 
>>>>>> >>> > > [Problem description]:
>>>>>> >>> > > 
>>>>>> >>> > > I wonder if it was interrupts missing that cause the network unreachable.
>>>>>> >>> > > In the migration process of kvm, source end should suspend, which include steps as follows:
>>>>>> >>> > > 1.	do_vm_stop->pause_all_vcpus
>>>>>> >>> > > 2.	vm_state_notify-> vhost_net_stop->set_guest_notifiers->kvm_virtio_pci_vq_vector_release
>>>>>> >>> > > 3.	vm_state_notify-> vhost_net_stop-> vhost_net_stop_one->OST_NET_SET_BACKEND-> vhost_net_flush_vq-> vhost_work_flush
>>>>>> >>> > > This may cause interrupts missing. Supose the scene that, virtqueue_notify() is called in virtio_net,
>>>>>> >>> > > then the VM is paused. And, just before the portiowrite being handled, eventfd of kvm is released.
>>>>>> >>> > > Then, vhost could not sense the notify, and the tx notify is lost.
>>>>>> >>> > > On the other side, if eventfd of kvm is released just after vhost_notify(), and before eventfd_signal(), then rx signal by vhost is lost.
>>>> >> > 
>>>> >> > Could be a bug in userspace: should should cleanups notifiers
>>>> >> > after it stops vhost.
>>>> >> > 
>>>> >> > Could you please send this to appropriate mailing lists?
>>>> >> > I have a policy against off-list discussions.
>> > Also, Jason, could you take a look please?
>> > Looks like your patch a9f98bb5ebe6fb1869321dcc58e72041ae626ad8
>> > changed the order of stopping the device.
>> > Previously vhost_dev_stop would disable backend and only afterwards,
>> > unset guest notifiers.  You now unset guest notifiers while vhost is still
>> > active. Looks like this can lose events?
> Not sure it will really cause the issue. Since during guest notifier
> deassign in virtio_queue_set_guest_notifier_fd_handler() it will test
> the notifier and trigger callback if set. Looks like this can guarantee
> the interrupt was not lost.

More thought on this, looks like it was still a window between guest
notifiers disabling and vhost_net stopping.

Please Zhang Jie test the patch of changing its order and if it works,
sends a formal patch to qemu-devel.

btw, vhost_scsi may need the fix as well since it may meet the same issue.

Thanks
