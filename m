From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] [bonding]: clear header_ops when last slave detached
Date: Mon, 17 Nov 2014 18:58:27 -0800
Message-ID: <1780.1416279507@famine>
References: <1415845156-15461-1-git-send-email-wen.gang.wang@oracle.com> <54694D09.4080304@oracle.com> <866.1416274729@famine> <546AA746.8090008@oracle.com> <1416277163.18588.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wengang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41308 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbaKRC6d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 21:58:33 -0500
In-reply-to: <1416277163.18588.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>On Tue, 2014-11-18 at 09:56 +0800, Wengang wrote:
>> Hi Jay,
>>=20
>> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8818=E6=97=A5 09:38, Jay Vosburgh =E5=
=86=99=E9=81=93:
>> > Wengang <wen.gang.wang@oracle.com> wrote:
>> >
>> >> Hi,
>> >>
>> >> Could anybody please review this patch?
>> > 	I don't see that the original of this ever came through netdev.
>>=20
>> Oh, that' bad. I sent this to netdev@vger.kernel.org. The mail addre=
ss=20
>> is wrong?
>>=20
>> >> thanks,
>> >> wengang
>> >>
>> >> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8813=E6=97=A5 10:19, Wengang Wang=
 =E5=86=99=E9=81=93:
>> >>> When last slave of a bonding master is removed, the bonding then=
 does not work.
>> >>> When packet_snd is called against with a master net_device, it a=
ccesses
>> >>> header_ops. In case the header_ops is not valid any longer(say m=
odule unloaded)
>> >>> it will then access an invalid memory address.
>> >>> This patch try to fix this issue by clearing header_ops when las=
t slave
>> >>> detached.
>> > 	Am I correct in presuming that this behavior is limited to ipoib
>> > slaves only?  I don't see that this could occur with ethernet slav=
es, as
>> > eth_header_ops isn't part of a module.  This needs to be mentioned=
 in
>> > the commit log.
>> Yes, the problem is found with ipoib slaves.
>> >>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> >>> ---
>> >>>    drivers/net/bonding/bond_main.c | 2 ++
>> >>>    1 file changed, 2 insertions(+)
>> >>>
>> >>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bondi=
ng/bond_main.c
>> >>> index c9ac06c..84a34fc 100644
>> >>> --- a/drivers/net/bonding/bond_main.c
>> >>> +++ b/drivers/net/bonding/bond_main.c
>> >>> @@ -1728,6 +1728,8 @@ static int __bond_release_one(struct net_d=
evice *bond_dev,
>> >>>    	unblock_netpoll_tx();
>> >>>    	synchronize_rcu();
>> >>>    	bond->slave_cnt--;
>> >>> +	if (!bond->slave_cnt)
>> >>> +		bond->dev->header_ops =3D NULL;
>> >>>      	if (!bond_has_slaves(bond)) {
>> >>>    		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>> > 	I believe your addition could be moved into the block for the
>> > next if, as "!bond->slave_cnt" is essentially "!bond_has_slaves()"=
=2E
>>=20
>> Yes, Agree.
>> I will send the second prompt soon with commit message mentioning ip=
oib.
>
>I really don't like this patch. Its quite racy.
>
>bond_setup_by_slave() kind of assume slave_dev->header_ops is always
>present.=20

	Isn't the ipoib header_ops implicitly gated by the presence or
absence of the module itself?  An ipoib device can't be enslaved unless
ipoib is loaded, and if ipoib is loaded, the ops are present.  And ipoi=
b
can't be removed while there are interfaces enslaved to bonding.

	I'm not saying it's not ugly, but I'm not seeing why it won't
work or what the race would be.

>No rcu protection, no module refcount protection for struct header_ops
>
>Considering ipoib_hard_header() is quite small, you might instead move
>ipoib_hard_header() and ipoib_header_ops in static vmlinux, like we do
>for eth_header_ops.

	Won't this require including all of the functions referenced by
the ops?  The problem here is that packet_snd will call dev_hard_header=
,
which wants to call header_ops->create.

	Ok, now that I check, there's only one op in ipoib_header_ops,
->create, and it's fairly simple.

	There was a similar chicken and egg problem with bonding and
ipoib a while back related to the master device having a dangling
pointer into ipoib somewhere; that might have been the header_ops as
well, so there may be a hack or two that could be removed if the ops
cannot disappear.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
