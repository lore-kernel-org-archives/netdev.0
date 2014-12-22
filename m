From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] bonding: avoid re-entry of bond_release
Date: Mon, 22 Dec 2014 10:45:24 -0500
Message-ID: <20141222154524.GA36069@gospo.home.greyhouse.net>
References: <1418979417-28867-1-git-send-email-wen.gang.wang@oracle.com>
 <20141219151157.GD22253@gospo>
 <54962A00.6080005@huawei.com>
 <54976F52.30403@oracle.com>
 <54977C52.3060309@huawei.com>
 <5497D6B0.2040402@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>, netdev@vger.kernel.org
To: Wengang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:42954 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbaLVPpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 10:45:32 -0500
Received: by mail-qg0-f67.google.com with SMTP id z107so612530qgd.6
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 07:45:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5497D6B0.2040402@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 04:30:40PM +0800, Wengang wrote:
> OK. Will change as suggested and re-post.

Sounds great.  Thanks for your work on this.

>=20
> thanks,
> wengang
>=20
> =E4=BA=8E 2014=E5=B9=B412=E6=9C=8822=E6=97=A5 10:05, Ding Tianhong =E5=
=86=99=E9=81=93:
> >On 2014/12/22 9:09, Wengang wrote:
> >>Hi Andy and Ding,
> >>
> >>Thanks for your reviews!
> >>In the ioctl path, removing a interface that is not currently actua=
lly a slave
> >>can happen from user space(by mistake), we should avoid the noisy m=
essage.
> >>
> >>While, __bond_release_one() has another call path which is from bon=
d_uninit().
> >>In the later case, it should be treated as an error if the interfac=
e is not with
> >>IFF_SLAVE flag. To notice that error occurred, the message is print=
ed. I think
> >>the message is needed for this path.
> >>
> >>How do you think?
> >>
> >Just like the bond_enslave(), it is only a warning.
> >
> >Ding
> >
> >>thanks,
> >>wengang
> >>
> >>=E4=BA=8E 2014=E5=B9=B412=E6=9C=8821=E6=97=A5 10:01, Ding Tianhong =
=E5=86=99=E9=81=93:
> >>>On 2014/12/19 23:11, Andy Gospodarek wrote:
> >>>>On Fri, Dec 19, 2014 at 04:56:57PM +0800, Wengang Wang wrote:
> >>>>>If bond_release is run against an interface which is already det=
ached from
> >>>>>it's master, then there is an error message shown like
> >>>>>     "<master name> cannot release <slave name>".
> >>>>>
> >>>>>The call path is:
> >>>>>     bond_do_ioctl()
> >>>>>         bond_release()
> >>>>>             __bond_release_one()
> >>>>>
> >>>>>Though it does not really harm, the message the message is misle=
ading.
> >>>>>This patch tries to avoid the message.
> >>>>>
> >>>>>Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> >>>>>---
> >>>>>   drivers/net/bonding/bond_main.c | 5 ++++-
> >>>>>   1 file changed, 4 insertions(+), 1 deletion(-)
> >>>>>
> >>>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bondi=
ng/bond_main.c
> >>>>>index 184c434..4a71bbd 100644
> >>>>>--- a/drivers/net/bonding/bond_main.c
> >>>>>+++ b/drivers/net/bonding/bond_main.c
> >>>>>@@ -3256,7 +3256,10 @@ static int bond_do_ioctl(struct net_devic=
e *bond_dev, struct ifreq *ifr, int cmd
> >>>>>           break;
> >>>>>       case BOND_RELEASE_OLD:
> >>>>>       case SIOCBONDRELEASE:
> >>>>>-        res =3D bond_release(bond_dev, slave_dev);
> >>>>>+        if (slave_dev->flags & IFF_SLAVE)
> >>>>>+            res =3D bond_release(bond_dev, slave_dev);
> >>>>>+        else
> >>>>>+            res =3D 0;
> >>>>Functionally this patch is fine, but I would prefer that you simp=
ly
> >>>>change the check in __bond_release_one to not be so noisy.  There=
 is a
> >>>>check[1] in bond_enslave to see if a slave is already in a bond a=
nd that
> >>>>just prints a message of netdev_dbg (rather than netdev_err) and =
it
> >>>>seems that would be appropriate for this type of message.
> >>>>
> >>>>[1] from bond_enslave():
> >>>>
> >>>>          /* already enslaved */
> >>>>          if (slave_dev->flags & IFF_SLAVE) {
> >>>>                  netdev_dbg(bond_dev, "Error: Device was already=
 enslaved\n");
> >>>>                  return -EBUSY;
> >>>>          }
> >>>>
> >>>>
> >>>>>           break;
> >>>>>       case BOND_SETHWADDR_OLD:
> >>>>>       case SIOCBONDSETHWADDR:
> >>>>>--=20
> >>>agree ,use netdev_dbg looks more better and enough.
> >>>
> >>>Ding
> >>>
> >>>
> >>
>=20
