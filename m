From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: Query: Is it possible  to lose interrupts between vhost and virtio_net
 during migration?
Date: Thu, 31 Jul 2014 19:47:24 +0800
Message-ID: <53DA2CCC.1040606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jasowang@redhat.com>, <mst@redhat.com>, <qinchuanyu@huawei.com>,
	<liuyongan@huawei.com>, <zhangjie14@huawei.com>,
	<davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:1241 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaGaLsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 07:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[The test scenario]:

Doing migration between two Hosts roundly(A->B, B->A) ,after about 20 times, network of the VM is unreachable.
There are other 20 VMs in each Host, and they send ipv4 or ipv6 and multicast packets to each other.
Sometimes the CPU idle of the Host maybe 0;

[Problem description]:

I wonder if it was interrupts missing that cause the network unreachable.
In the migration process of kvm, source end should suspend, which include steps as follows:
1.	do_vm_stop->pause_all_vcpus
2.	vm_state_notify-> vhost_net_stop->set_guest_notifiers->kvm_virtio_pci_vq_vector_release
3.	vm_state_notify-> vhost_net_stop-> vhost_net_stop_one->OST_NET_SET_BACKEND-> vhost_net_flush_vq-> vhost_work_flush
This may cause interrupts missing. Supose the scene that, virtqueue_notify() is called in virtio_net,
then the VM is paused. And, just before the portiowrite being handled, eventfd of kvm is released.
Then, vhost could not sense the notify, and the tx notify is lost.
On the other side, if eventfd of kvm is released just after vhost_notify(), and before eventfd_signal(), then rx signal by vhost is lost.
