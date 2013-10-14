From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: =?UTF-8?B?UmU6IElzIGZhbGxiYWNrIHZob3N0X25ldCB0byBxZW11IGZvciBsaXY=?=
 =?UTF-8?B?ZSBtaWdyYXRlIGF2YWlsYWJsZe+8nw==?=
Date: Mon, 14 Oct 2013 16:19:57 +0800
Message-ID: <525BA92D.6050609@huawei.com>
References: <521C1DCF.5090202@huawei.com> <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	<wangfuhai@huawei.com>, <liuyongan@huawei.com>
To: Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:46160 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab3JNIVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 04:21:07 -0400
In-Reply-To: <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/30 0:08, Anthony Liguori wrote:
> Hi Qin,
>
> KVM and Xen represent memory in a very different way.  KVM can only
> track when guest mode code dirties memory.  It relies on QEMU to trac=
k
> when guest memory is dirtied by QEMU.  Since vhost is running outside
> of QEMU, vhost also needs to tell QEMU when it has dirtied memory.
>
> I don't think this is a problem with Xen though.  I believe (although
> could be wrong) that Xen is able to track when either the domain or
> dom0 dirties memory.
>
> So I think you can simply ignore the dirty logging with vhost and it
> should Just Work.
>
Xen track guest's memory when live migrating as what KVM did (I guess i=
t=20
rely on EPT)=EF=BC=8Cit couldn't mark dom0's dirty memory automatically=
=2E

I did the same dirty log with vhost_net but instead of KVM's api with=20
Xen's dirty memory interface=EF=BC=8Cthen live migration work.

--------------------------------------------------------------------
There is a bug on the Xen live migration when using qemu emulate=20
nic(such as virtio_net).
current flow:
     xc_save->dirty memory copy->suspend->stop_vcpu->last memory copy
     stop_qemu->stop_virtio_net
     save_qemu->save_virtio_net
it means virtio_net would dirty memory after the last memory copy.

I have test it both vhost_on_qemu and virtio_net in qemu,there are same=
=20
problem, the update of vring_index would be mistake and lead network=20
unreachable. my solution is:
     xc_save->dirty memory copy->suspend->stop_vcpu->stop_qemu
			->stop_virtio_net->last memory copy
     save_qemu->save_virtio_net

Xen's netfront and netback disconnect and flush IO-ring when live=20
migrate=EF=BC=8Cso it is OK.
