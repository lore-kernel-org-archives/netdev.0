From: Anthony Liguori <anthony@codemonkey.ws>
Subject: =?UTF-8?Q?Re=3A_Is_fallback_vhost=5Fnet_to_qemu_for_live_migrate_a?=
	=?UTF-8?Q?vailable=EF=BC=9F?=
Date: Thu, 29 Aug 2013 11:08:24 -0500
Message-ID: <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
References: <521C1DCF.5090202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, jasowang@redhat.com,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	qianhuibin@huawei.com,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:43221 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938Ab3H2QIZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 12:08:25 -0400
Received: by mail-ob0-f172.google.com with SMTP id er7so691746obc.17
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 09:08:24 -0700 (PDT)
In-Reply-To: <521C1DCF.5090202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Qin,

On Mon, Aug 26, 2013 at 10:32 PM, Qin Chuanyu <qinchuanyu@huawei.com> w=
rote:
> Hi all
>
> I am participating in a project which try to port vhost_net on Xen=E3=
=80=82

Neat!

> By change the memory copy and notify mechanism =EF=BC=8Ccurrently vir=
tio-net with
> vhost_net could run on Xen with good performance=E3=80=82

I think the key in doing this would be to implement a property
ioeventfd and irqfd interface in the driver domain kernel.  Just
hacking vhost_net with Xen specific knowledge would be pretty nasty
IMHO.

Did you modify the front end driver to do grant table mapping or is
this all being done by mapping the domain's memory?

> TCP receive throughput of
> single vnic from 2.77Gbps up to 6Gps=E3=80=82In VM receive side=EF=BC=
=8CI instead grant_copy
> with grant_map + memcopy=EF=BC=8Cit efficiently reduce the cost of gr=
ant_table
> spin_lock of dom0=EF=BC=8CSo the hole server TCP performance from 5.3=
3Gps up to
> 9.5Gps=E3=80=82
>
> Now I am consider the live migrate of vhost_net on Xen=EF=BC=8Cvhost_=
net use
> vhost_log for live migrate on Kvm=EF=BC=8Cbut qemu on Xen havn't mana=
ge the hole
> memory of VM=EF=BC=8CSo I am trying to fallback datapath from vhost_n=
et to qemu when
> doing live migrate =EF=BC=8Cand fallback datapath from qemu to
> vhost_net again after vm migrate to new server=E3=80=82

KVM and Xen represent memory in a very different way.  KVM can only
track when guest mode code dirties memory.  It relies on QEMU to track
when guest memory is dirtied by QEMU.  Since vhost is running outside
of QEMU, vhost also needs to tell QEMU when it has dirtied memory.

I don't think this is a problem with Xen though.  I believe (although
could be wrong) that Xen is able to track when either the domain or
dom0 dirties memory.

So I think you can simply ignore the dirty logging with vhost and it
should Just Work.

>
> My question is=EF=BC=9A
>         why didn't vhost_net do the same fallback operation for live =
migrate
> on KVM=EF=BC=8Cbut use vhost_log to mark the dirty page=EF=BC=9F
>         Is there any mechanism fault for the idea of fallback datapat=
h from
> vhost_net to qemu for live migrate=EF=BC=9F

No, we don't have a mechanism to fallback  to QEMU for the datapath.
It would be possible but I think it's a bad idea to mix and match the
two.

Regards,

Anthony Liguori

> any question about the detail of vhost_net on Xen is welcome=E3=80=82
>
> Thanks
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
