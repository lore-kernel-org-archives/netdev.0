From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [bonding]: clear header_ops when last slave detached
Date: Mon, 17 Nov 2014 18:19:23 -0800
Message-ID: <1416277163.18588.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415845156-15461-1-git-send-email-wen.gang.wang@oracle.com>
	 <54694D09.4080304@oracle.com> <866.1416274729@famine>
	 <546AA746.8090008@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>, netdev@vger.kernel.org
To: Wengang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:47392 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaKRCT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 21:19:26 -0500
Received: by mail-pd0-f175.google.com with SMTP id y10so3625231pdj.34
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 18:19:26 -0800 (PST)
In-Reply-To: <546AA746.8090008@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-18 at 09:56 +0800, Wengang wrote:
> Hi Jay,
>=20
> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8818=E6=97=A5 09:38, Jay Vosburgh =E5=
=86=99=E9=81=93:
> > Wengang <wen.gang.wang@oracle.com> wrote:
> >
> >> Hi,
> >>
> >> Could anybody please review this patch?
> > 	I don't see that the original of this ever came through netdev.
>=20
> Oh, that' bad. I sent this to netdev@vger.kernel.org. The mail addres=
s=20
> is wrong?
>=20
> >> thanks,
> >> wengang
> >>
> >> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8813=E6=97=A5 10:19, Wengang Wang =
=E5=86=99=E9=81=93:
> >>> When last slave of a bonding master is removed, the bonding then =
does not work.
> >>> When packet_snd is called against with a master net_device, it ac=
cesses
> >>> header_ops. In case the header_ops is not valid any longer(say mo=
dule unloaded)
> >>> it will then access an invalid memory address.
> >>> This patch try to fix this issue by clearing header_ops when last=
 slave
> >>> detached.
> > 	Am I correct in presuming that this behavior is limited to ipoib
> > slaves only?  I don't see that this could occur with ethernet slave=
s, as
> > eth_header_ops isn't part of a module.  This needs to be mentioned =
in
> > the commit log.
> Yes, the problem is found with ipoib slaves.
> >>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> >>> ---
> >>>    drivers/net/bonding/bond_main.c | 2 ++
> >>>    1 file changed, 2 insertions(+)
> >>>
> >>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bondin=
g/bond_main.c
> >>> index c9ac06c..84a34fc 100644
> >>> --- a/drivers/net/bonding/bond_main.c
> >>> +++ b/drivers/net/bonding/bond_main.c
> >>> @@ -1728,6 +1728,8 @@ static int __bond_release_one(struct net_de=
vice *bond_dev,
> >>>    	unblock_netpoll_tx();
> >>>    	synchronize_rcu();
> >>>    	bond->slave_cnt--;
> >>> +	if (!bond->slave_cnt)
> >>> +		bond->dev->header_ops =3D NULL;
> >>>      	if (!bond_has_slaves(bond)) {
> >>>    		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
> > 	I believe your addition could be moved into the block for the
> > next if, as "!bond->slave_cnt" is essentially "!bond_has_slaves()".
>=20
> Yes, Agree.
> I will send the second prompt soon with commit message mentioning ipo=
ib.

I really don't like this patch. Its quite racy.

bond_setup_by_slave() kind of assume slave_dev->header_ops is always
present.=20

No rcu protection, no module refcount protection for struct header_ops

Considering ipoib_hard_header() is quite small, you might instead move
ipoib_hard_header() and ipoib_header_ops in static vmlinux, like we do
for eth_header_ops.
