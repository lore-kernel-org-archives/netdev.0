From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: bad commit touching stmmac_ptp.c
Date: Wed, 19 Oct 2016 00:16:09 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610182339340.25105@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Alexandre TORGUE <alexandre.torgue@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36748 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbcJSEQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 00:16:12 -0400
Received: by mail-qk0-f174.google.com with SMTP id o68so17597124qkf.3
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 21:16:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I noticed a recently added commit 7086605a6a ("stmmac: fix error check 
when init ptp") to the mainline linux tree from you. This commit is 
wrong.  The affected code now reads as:

int stmmac_ptp_register(struct stmmac_priv *priv)
{
        spin_lock_init(&priv->ptp_lock);
        priv->ptp_clock_ops = stmmac_ptp_clock_ops;

        priv->ptp_clock = ptp_clock_register(&priv->ptp_clock_ops,
                                             priv->device);
        if (IS_ERR(priv->ptp_clock)) {
                priv->ptp_clock = NULL;
                return PTR_ERR(priv->ptp_clock);
        }

        spin_lock_init(&priv->ptp_lock);

        netdev_dbg(priv->dev, "Added PTP HW clock successfully\n");

        return 0;
}

Firstly, you basically reverted the change I did with commit 
efee95f42b ("ptp_clock: future-proofing drivers against PTP subsystem 
becoming optional").  Please have a look at that commit and ponder its 
implications.

Secondly, the error you're actually returning to the caller with your 
patch is actually PTR_ERR(NULL) which is basically a more convoluted way 
to return the same value as what was returned before your patch, which 
is probably not what you intended.

And finally you added a needless initialization of priv->ptp_lock given 
that this was already done a few lines before that addition.

Was this patch actually reviewed?


Nicolas
