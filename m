From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: Is fallback vhost_net to =?utf-8?Q?qem?=
 =?utf-8?Q?u_for_live_migrate_available=EF=BC=9F?=
Date: Tue, 3 Sep 2013 10:15:57 +0100
Message-ID: <20130903091557.GG14104@zion.uk.xensource.com>
References: <521C1DCF.5090202@huawei.com>
 <CA+aC4kv66bvt5mREv-YXVddD9wdgAiT=heo9xhdkkVmuLOyrBw@mail.gmail.com>
 <522174D7.6080903@huawei.com>
 <20130902075722.GZ15729@zion.uk.xensource.com>
 <52253B2B.6050909@huawei.com>
 <20130903084047.GF14104@zion.uk.xensource.com>
 <20130903085556.GD18901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Liu <wei.liu2@citrix.com>, Qin Chuanyu <qinchuanyu@huawei.com>,
	Anthony Liguori <anthony@codemonkey.ws>, <jasowang@redhat.com>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	<qianhuibin@huawei.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	<wangfuhai@huawei.com>, <likunyun@huawei.com>,
	<liuyongan@huawei.com>, <liuyingdong@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53760 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759809Ab3ICJP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 05:15:59 -0400
Content-Disposition: inline
In-Reply-To: <20130903085556.GD18901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 11:55:56AM +0300, Michael S. Tsirkin wrote:
> On Tue, Sep 03, 2013 at 09:40:48AM +0100, Wei Liu wrote:
> > On Tue, Sep 03, 2013 at 09:28:11AM +0800, Qin Chuanyu wrote:
> > > On 2013/9/2 15:57, Wei Liu wrote:
> > > >On Sat, Aug 31, 2013 at 12:45:11PM +0800, Qin Chuanyu wrote:
> > > >>On 2013/8/30 0:08, Anthony Liguori wrote:
> > > >>>Hi Qin,
> > > >>
> > > >>>>By change the memory copy and notify mechanism =EF=BC=8Ccurre=
ntly virtio-net with
> > > >>>>vhost_net could run on Xen with good performance=E3=80=82
> > > >>>
> > > >>>I think the key in doing this would be to implement a property
> > > >>>ioeventfd and irqfd interface in the driver domain kernel.  Ju=
st
> > > >>>hacking vhost_net with Xen specific knowledge would be pretty =
nasty
> > > >>>IMHO.
> > > >>>
> > > >>Yes, I add a kernel module which persist virtio-net pio_addr an=
d
> > > >>msix address as what kvm module did. Guest wake up vhost thread=
 by
> > > >>adding a hook func in evtchn_interrupt.
> > > >>
> > > >>>Did you modify the front end driver to do grant table mapping =
or is
> > > >>>this all being done by mapping the domain's memory?
> > > >>>
> > > >>There is nothing changed in front end driver. Currently I use
> > > >>alloc_vm_area to get address space=EF=BC=8C and map the domain'=
s memory as
> > > >>what what qemu did.
> > > >>
> > > >
> > > >You mean you're using xc_map_foreign_range and friends in the ba=
ckend to
> > > >map guest memory? That's not very desirable as it violates Xen's
> > > >security model. It would not be too hard to pass grant reference=
s
> > > >instead of guest physical memory address IMHO.
> > > >
> > > In fact, I did what virtio-net have done in Qemu. I think securit=
y
> > > is a pseudo question because Dom0 is under control.
> > >=20
> >=20
> > Consider that you might have driver domains. Not every domain is un=
der
> > control or trusted.
>=20
> I don't see anything that will prevent using driver domains here.
>=20

There is nothing technically stopping driver domains to work. It's abou=
t
the boundary of trust.

> > Also consider that security model like XSM can be
> > used to audit operations to enhance security so your foreign mappin=
g
> > approach might not always work.
>=20
> It could be nice to have as an option, sure.
> XSM is disabled by default though so I don't think lack of support fo=
r
> that makes it a prototype.
>=20

XSM is there already, someone in a while might just want to give it a
shot despite it's not well supported. Then all of a sudden they find ou=
t
something works before (the foreign mapping backend) would not work
anymore. That would just lead to confusion. It's like a cycle of bad
things. Users try something lack of support -> it doesn't work -> users
won't use it anymore -> less support because nobody seems to be
interested.

> > In short term foreign mapping can save you some time implementing t=
he
> > prototype.
> > In long term using grant table is the proper way to go. And
> > IMHO the benifit outweights the cost.
> >=20
> > Wei.
>=20
> I'm guessing direct access could be quite a bit faster.
> But someone would have to implement your idea in order to
> do a cost/benefit analysis.
>=20

I'm not sure direct access will be faster. Either way hypervisor is
involved to update guest's page table.

Anyway, my point is, switching to grant table is not as hard as you
think - pass along grant refs instead of guest pseudo address in the
ring and use grant table API instead of foreign mapping API in the
backend.

Wei.

> > > Host could access memory of guest in KVM much easier than Xen,
> > > but I hadn't heard someone said KVM is un-secret.
> > >=20
> > > Regards
> > > Qin chuanyu
> > >=20
> > >=20
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
