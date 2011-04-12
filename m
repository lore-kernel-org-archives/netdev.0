From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4] net: bnx2x: convert to hw_features
Date: Tue, 12 Apr 2011 16:49:40 +0200
Message-ID: <20110412144940.GA26043@rere.qmqm.pl>
References: <20110411202630.C079D13909@rere.qmqm.pl> <1302610228.32697.298.camel@lb-tlvb-vladz> <20110412140708.GA21835@rere.qmqm.pl> <1302619012.6750.8.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33682 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932270Ab1DLOtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 10:49:41 -0400
Content-Disposition: inline
In-Reply-To: <1302619012.6750.8.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 12, 2011 at 05:36:52PM +0300, Vladislav Zolotarov wrote:
> On Tue, 2011-04-12 at 07:07 -0700, Micha=B3 Miros=B3aw wrote:
> > On Tue, Apr 12, 2011 at 03:10:28PM +0300, Vladislav Zolotarov wrote=
:
> > > On Mon, 2011-04-11 at 13:26 -0700, Micha=B3 Miros=B3aw wrote:
> > > > Since ndo_fix_features callback is postponing features change w=
hen
> > > > bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_feat=
ures()
> > > > has to be called again when this condition changes. Previously,
> > > > ethtool_ops->set_flags callback returned -EBUSY in that case
> > > > (it's not possible in the new model).
> > > ACK (with reservations). ;)
> > > Could u, pls., just add this comment I've asked for in the previo=
us
> > > e-mail?=20
> > The one about vlan_features?=20
> Yeah, this one.
> > I'll just fix the comment in netdevice.h
> > instead, since it might be not clear enough.
> Could u still add this comment to bnx2x in your patch as well. It'll
> just make these code section more clear regardless the netdevice.h
> contents... ;)

This would be duplicating information easily found elsewhere.
I don't like it. :)

> > > The things I first thought to comment on are:
> > > 	- Removing TPA_ENABLED_FLAG the similar way u've removed the
> > > bp->rx_csum.
> > > 	- Merging the code handling 'features' in bnx2x_init_bp() with t=
he
> > > similar code in bnx2x_init_dev().
> > >=20
> > > However I think it would be right if we clear our mess by ourselv=
es and
> > > that u have already done much enough... ;)=20
> > >=20
> > > I've run our standard test suite (which in particular heavily tes=
ts the
> > > RX_CSUM and LRO flags toggling) on this patch and it passed it.
> > It might be possible to get rid of ndo_set_features, since it looks=
 like
> > the reset/recovery handler is doing unload/load itself. This needs =
more
> > digging into the driver than this simple conversion.
> Hmm... I don't get u here. Although the recovery handler does
> unload/load itself if there has been an attempt to change features
> during the recovery it won't be able to get applied until the whole
> recovery process ends. So, this patch added the extra call for
> netdev_update_features() right after we know that the recovery proces=
s
> has successfully ended. So, could u, pls., explain exactly what do u
> mean here by saying "It might be possible to get rid of
> ndo_set_features"?

Hmm. I thought one, and wrote another.

Since bnx2x_parity_recover() runs with rtnl_lock(), as should
netdev_update_features(), then in case the recovery is in progress
it should be enough to not call bnx2x_reload_if_running() then
and just change the flags --- changes will be picked up on bnx2x_nic_lo=
ad()
after recovery is complete. This removes the need for netdev_update_fea=
tures()
calls.

Best Regards,
Micha=B3 Miros=B3aw
