From: Fabio Estevam <festevam@gmail.com>
Subject: Re: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Wed, 12 Apr 2017 13:26:39 -0300
Message-ID: <CAOMZO5DnKfNF__HThRBMix-yr6X9-x0VOVm57oeCQ2iwyL8gzg@mail.gmail.com>
References: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
 <20170407160915.GF23415@lunn.ch> <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        Fugang Duan <fugang.duan@nxp.com>,
        Koen Vandeputte <koen.vandeputte@ncentric.com>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34928 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755011AbdDLQ0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:26:45 -0400
Received: by mail-oi0-f45.google.com with SMTP id f22so37992199oib.2
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 09:26:44 -0700 (PDT)
In-Reply-To: <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tim,

On Wed, Apr 12, 2017 at 1:15 PM, Tim Harvey <tharvey@gateworks.com> wrote:
>
> Andrew,
>
> Thanks for the reply. Your talking about suspend/resume power
> management right? The users reporting this were not using
> suspend/resume.
>
> With regards to clock are you talking about the IPG clock? Is there
> any other way that would get turned off other than fec suspend/resume?

Yes, through pm_runtime.

Can you check if this quick debug change help?

--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3606,8 +3606,6 @@ static int __maybe_unused
fec_runtime_suspend(struct device *dev)
        struct net_device *ndev = dev_get_drvdata(dev);
        struct fec_enet_private *fep = netdev_priv(ndev);

-       clk_disable_unprepare(fep->clk_ipg);
-
        return 0;
 }


If you don't see the problem with it, then it means we need to fix the
pm runtime support in this driver.

Most likely pm runtime is turning off the clocks when it should not.
