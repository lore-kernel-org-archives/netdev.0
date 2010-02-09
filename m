From: John Williams <john.williams@petalogix.com>
Subject: Re: [PATCH] [V3] net: emaclite: adding MDIO and phy lib support
Date: Wed, 10 Feb 2010 08:30:24 +1000
Message-ID: <1d3f23371002091430hb550153u602c8e7c010381b9@mail.gmail.com>
References: <2ea396ca-3014-40f4-86ac-0e9f1aa82b5b@SG2EHSMHS005.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f202.google.com ([209.85.216.202]:36189 "EHLO
	mail-px0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754540Ab0BIWaY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 17:30:24 -0500
Received: by pxi40 with SMTP id 40so44094pxi.21
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 14:30:24 -0800 (PST)
In-Reply-To: <2ea396ca-3014-40f4-86ac-0e9f1aa82b5b@SG2EHSMHS005.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

Sorry If I'm painting bike-sheds here, just one tiny tweak might be in
order to standardise your mutex_unlock exit path:

> +static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int =
reg)
> +{
> + =A0 =A0 =A0 struct net_local *lp =3D bus->priv;
> + =A0 =A0 =A0 u32 ctrl_reg;
> + =A0 =A0 =A0 u32 rc;
> +
> + =A0 =A0 =A0 mutex_lock(&lp->mdio_mutex);
> +
> + =A0 =A0 =A0 if (xemaclite_mdio_wait(lp)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&lp->mdio_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> + =A0 =A0 =A0 }

[snip]


> + =A0 =A0 =A0 if (xemaclite_mdio_wait(lp)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&lp->mdio_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> + =A0 =A0 =A0 }

[snip]


> + =A0 =A0 =A0 dev_dbg(&lp->ndev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "xemaclite_mdio_read(phy_id=3D%i, reg=3D=
%x) =3D=3D %x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id, reg, rc);
> +
> + =A0 =A0 =A0 return rc;

Can this be better expressed like this:

my_func() {
  mutex_lock()
=2E.

  if(some error) {
    rc=3D-ETIMEDOUT;
    goto out_unlock;
  }
  ...

  /* success path */
  rc=3D0;
=2E.
out_unlock:
  mutex_unlock()
  return rc;
}


Is this style still favoured in driver exit paths?

Thanks,

John
--=20
John Williams, PhD, B.Eng, B.IT
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com  p: +61-7-30090663  f: +61-7-30090663
