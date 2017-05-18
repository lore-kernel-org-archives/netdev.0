From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 5/5] qede: Split PF/VF ndos.
Date: Thu, 18 May 2017 04:58:25 +0000
Message-ID: <BLUPR0701MB20042DD110A79E49C2BC0DD78DE40@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
        <1494331671-16273-6-git-send-email-Yuval.Mintz@cavium.com>
        <CY1PR0701MB20094B9857D89E463608F3B98DE70@CY1PR0701MB2009.namprd07.prod.outlook.com>
 <20170517.111007.1089356716021925537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0072.outbound.protection.outlook.com ([104.47.33.72]:14976
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752529AbdERE62 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 00:58:28 -0400
In-Reply-To: <20170517.111007.1089356716021925537.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Looking at my alternatives for solving this, I can't see any 'good'
> > options - it seems mightily unorthodox to modify net_device_ops, I.e.,
> > add/remove an NDO function-pointer based on some device property, and
> > having multiple ops declared for the sake of a single feature seems
> > unscalable.
>=20
> Multiple ops is the only thing that works right now.

What about something like -=20

diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/e=
thernet/qlogic/qede/qede_filter.c
index 333876c..7450c8b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -1028,6 +1028,13 @@ int qede_xdp(struct net_device *dev, struct netdev_x=
dp *xdp)
 {
        struct qede_dev *edev =3D netdev_priv(dev);

+       /* Not all VFs can support XDP; But we can't fail the query */
+       if ((<Actual condition to determine XDP support>) {
+               if (xdp->command =3D=3D XDP_QUERY_PROG)
+                       return 0;
+               return -EOPNOTSUPP;
+       }
+
        switch (xdp->command) {
        case XDP_SETUP_PROG:
                return qede_xdp_set(edev, xdp->prog);
