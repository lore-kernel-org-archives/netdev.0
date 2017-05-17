From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 5/5] qede: Split PF/VF ndos.
Date: Wed, 17 May 2017 06:16:46 +0000
Message-ID: <CY1PR0701MB20094B9857D89E463608F3B98DE70@CY1PR0701MB2009.namprd07.prod.outlook.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
 <1494331671-16273-6-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0082.outbound.protection.outlook.com ([104.47.33.82]:59802
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750784AbdEQGQs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 02:16:48 -0400
In-Reply-To: <1494331671-16273-6-git-send-email-Yuval.Mintz@cavium.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> PFs and VFs share the same structure of NDOs today, and the VFs explicitl=
y
> fails the ndo_xdp() callback stating it doesn't support XDP.
>=20
> This results in lots of:
>=20
>   [qede_xdp:1032(enp131s2)]VFs don't support XDP
>   ------------[ cut here ]------------
>   WARNING: CPU: 4 PID: 1426 at net/core/rtnetlink.c:1637
> rtnl_dump_ifinfo+0x354/0x3c0
>   ...
>   Call Trace:
>     ? __alloc_skb+0x9b/0x1d0
>     netlink_dump+0x122/0x290
>     netlink_recvmsg+0x27d/0x430
>     sock_recvmsg+0x3d/0x50
>   ...
>=20
> As every dump request for the VF interface info would fail due to
> rtnl_xdp_fill() returning an error code.
>=20
> To resolve this, introduce a subset of the NDOs meant for the VF in a
> seperate structure and register that one instead for VFs, and omit the
> ndo_xdp initialization.
>=20
> Fixes: 40b8c45492ef ("qede: Prevent VFs from using XDP")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

I'm currently working on adding XDP support for qede VFs.
Problem is there's quite a bit of IOV infrastructure involved in this,
and legacy [well, current] PFs would prevent their VFs from utilizing it.

Once I have it ready, if I'd add back the ndo_xdp unconditionally for VFs,
then when working over legacy PFs above issue would resurface.

Looking at my alternatives for solving this, I can't see any 'good' options=
 -
it seems mightily unorthodox to modify net_device_ops, I.e., add/remove
an NDO function-pointer based on some device property, and having
multiple ops declared for the sake of a single feature seems unscalable.

Any better solutions?
