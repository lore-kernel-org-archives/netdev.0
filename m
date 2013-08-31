From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: =?UTF-8?B?UmU6IElzIGZhbGxiYWNrIHZob3N0X25ldCB0byBxZW11IGZvciBsaXY=?=
 =?UTF-8?B?ZSBtaWdyYXRlIGF2YWlsYWJsZe+8nw==?=
Date: Sat, 31 Aug 2013 12:45:11 +0800
Message-ID: <522174D7.6080903@huawei.com>
References: <521C1DCF.5090202@huawei.com> <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, <jasowang@redhat.com>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	<wangfuhai@huawei.com>, <likunyun@huawei.com>,
	<liuyongan@huawei.com>, <liuyingdong@huawei.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42157 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190Ab3HaEpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 00:45:54 -0400
In-Reply-To: <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/30 0:08, Anthony Liguori wrote:
> Hi Qin,

>> By change the memory copy and notify mechanism =EF=BC=8Ccurrently vi=
rtio-net with
>> vhost_net could run on Xen with good performance=E3=80=82
>
> I think the key in doing this would be to implement a property
> ioeventfd and irqfd interface in the driver domain kernel.  Just
> hacking vhost_net with Xen specific knowledge would be pretty nasty
> IMHO.
>
Yes, I add a kernel module which persist virtio-net pio_addr and msix=20
address as what kvm module did. Guest wake up vhost thread by adding a=20
hook func in evtchn_interrupt.

> Did you modify the front end driver to do grant table mapping or is
> this all being done by mapping the domain's memory?
>
There is nothing changed in front end driver. Currently I use=20
alloc_vm_area to get address space=EF=BC=8C and map the domain's memory=
 as what=20
what qemu did.

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
Thanks for your advice, I have tried it, without ping, it could migrate=
=20
successfully, but if there has skb been received, domU would crash. I=20
guess that because though Xen track domU memory, but it could only trac=
k=20
memory that changed in DomU. memory changed by Dom0 is out of control.

>
> No, we don't have a mechanism to fallback  to QEMU for the datapath.
> It would be possible but I think it's a bad idea to mix and match the
> two.
>
Next I would try to fallback datapath to qemu for three reason:
1: memory translate mechanism has been changed for vhost_net on Xen=EF=BC=
=8Cso=20
there would be some necessary changed needed for vhost_log in kernel.

2: I also maped IOREQ_PFN page(which is used for communication between=20
qemu and Xen) in kernel notify module, so it also needed been marked as=
=20
dirty when tx/rx exist in migrate period.

3: Most important of all=EF=BC=8C Michael S. Tsirkin said that he hadn'=
t=20
considered about vhost_net migrate on Xen=EF=BC=8Cso there would be som=
e=20
changed needed in vhost_log for qemu.

fallback to qemu seems to much easier, isn't it.

Regards
Qin chuanyu
