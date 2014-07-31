From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and
 virtio_net during migration?
Date: Thu, 31 Jul 2014 16:37:25 +0200
Message-ID: <20140731143725.GA3875@redhat.com>
References: <53DA2CCC.1040606@huawei.com>
 <20140731143100.GA3834@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com, qinchuanyu@huawei.com,
	liuyongan@huawei.com, davem@davemloft.net
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbaGaOhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 10:37:23 -0400
Content-Disposition: inline
In-Reply-To: <20140731143100.GA3834@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2014 at 04:31:00PM +0200, Michael S. Tsirkin wrote:
> On Thu, Jul 31, 2014 at 07:47:24PM +0800, Zhangjie (HZ) wrote:
> > [The test scenario]:
> > 
> > Doing migration between two Hosts roundly(A->B, B->A) ,after about 20 times, network of the VM is unreachable.
> > There are other 20 VMs in each Host, and they send ipv4 or ipv6 and multicast packets to each other.
> > Sometimes the CPU idle of the Host maybe 0;
> > 
> > [Problem description]:
> > 
> > I wonder if it was interrupts missing that cause the network unreachable.
> > In the migration process of kvm, source end should suspend, which include steps as follows:
> > 1.	do_vm_stop->pause_all_vcpus
> > 2.	vm_state_notify-> vhost_net_stop->set_guest_notifiers->kvm_virtio_pci_vq_vector_release
> > 3.	vm_state_notify-> vhost_net_stop-> vhost_net_stop_one->OST_NET_SET_BACKEND-> vhost_net_flush_vq-> vhost_work_flush
> > This may cause interrupts missing. Supose the scene that, virtqueue_notify() is called in virtio_net,
> > then the VM is paused. And, just before the portiowrite being handled, eventfd of kvm is released.
> > Then, vhost could not sense the notify, and the tx notify is lost.
> > On the other side, if eventfd of kvm is released just after vhost_notify(), and before eventfd_signal(), then rx signal by vhost is lost.
> 
> Could be a bug in userspace: should should cleanups notifiers
> after it stops vhost.
> 
> Could you please send this to appropriate mailing lists?
> I have a policy against off-list discussions.

Also, Jason, could you take a look please?
Looks like your patch a9f98bb5ebe6fb1869321dcc58e72041ae626ad8
changed the order of stopping the device.
Previously vhost_dev_stop would disable backend and only afterwards,
unset guest notifiers.  You now unset guest notifiers while vhost is still
active. Looks like this can lose events?



> -- 
> MST
