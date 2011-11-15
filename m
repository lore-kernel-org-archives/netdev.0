From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Tue, 15 Nov 2011 22:04:31 +0100
Message-ID: <20111115210431.GA9768@darkmag.usersys.redhat.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
 <20111115170018.GB25132@gospo.rdu.redhat.com>
 <4EC2BC6D.9000304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298Ab1KOVEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 16:04:39 -0500
Content-Disposition: inline
In-Reply-To: <4EC2BC6D.9000304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2011 at 08:24:29PM +0100, Nicolas de Peslo=FCan wrote:
> Le 15/11/2011 18:00, Andy Gospodarek a =E9crit :
> >On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
> >>When changing mode via bonding's sysfs, the slaves are not initiali=
zed
> >>correctly. Forbid to change modes with slaves present to ensure tha=
t every
> >>slave is initialized correctly via bond_enslave().
> >>
> >>Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
> >
> >Looks good.  This behavior forces someone who wants to change to mod=
e to
> >go through steps that are almost as destructive as when module optio=
ns
> >are used to configure the mode.  I do not see a problem with this.
>=20
> Except the fact that is enforce one more constraint on the exact
> order one should write into sysfs to setup a bonding interface. We
> already have many such constraints and probably don't need more.
>=20
> Currently, it is possible to enslave slaves before selecting the
> mode. The ifenslave-2.6 package from Debian currently enslave slaves
> before setting the mode and would break with this change.

Yes, it's possible, however the enslaved interfaces are initialized wit=
h
the current mode parameters, and when the mode is changed - they aren't
reinitialized at all. There are a lot of mode-specific initialization s=
tuff
that's present only in bond_enslave(), and here are only some of the
(most obvious) snippets:

ALB/TLB balancing:
<snip>
        if (bond_is_lb(bond)) {
                /* bond_alb_init_slave() must be called before all othe=
r
 * stages since
                 * it might fail and we do not want to have to undo
                 * everything
                 */
                res =3D bond_alb_init_slave(bond, new_slave);
                if (res)
                        goto err_close;
        }   =20
</snip>

bond_alb_init_slave() is called only in this case. This means that the =
mac
address won't be changed at all, and some other stuff won't be properly
changed as well.

802.3ad:
<snip>
        if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
                /* add lacpdu mc addr to mc list */
                u8 lacpdu_multicast[ETH_ALEN] =3D MULTICAST_LACPDU_ADDR=
;

                dev_mc_add(slave_dev, lacpdu_multicast);
        }
</snip>

This means that the slave device will just drop all the LACPDUs.

So this means that at least two modes won't work if your first load the
bonding module with the default mode and then change it with slaves
attached. And I'm *really* sceptic on the other modes.

So even if the kernel doesn't show any error, it still doesn't work as
expected. To *really* fix this bug without adding any constraints would
require quite a few lines of code, and before it is fixed this patch is=
 the
best way to avoid it.
