From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: linux-next-20170320 breaks stmmac on meson (Amlogic S905GXBB)
Date: Tue, 21 Mar 2017 15:07:31 +0100
Message-ID: <20170321140731.GB4589@Red>
References: <690d5153-7725-83e6-208a-6cb4cac3cd93@gmail.com>
 <88d2fa04-a9db-dbab-2c4f-03310ef7d540@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Heiner Kallweit <hkallweit1@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36440 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932430AbdCUOQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 10:16:55 -0400
Received: by mail-wm0-f54.google.com with SMTP id n11so13199660wma.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 07:16:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <88d2fa04-a9db-dbab-2c4f-03310ef7d540@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 10:13:08AM +0000, Joao Pinto wrote:
> 
> Hi Heiner and Corentin,
> 
> Às 9:58 PM de 3/20/2017, Heiner Kallweit escreveu:
> > As reported by Corentin Labbe before:
> > stmmac in the latest next kernel is broken also on meson8b.
> > 
> > The following commit seems to create the trouble:
> > 6deee2221e11 "net: stmmac: prepare dma op mode config for multiple queues"
> > 
> > I also get queue timeout errors.
> 
> From what you are describing it seems that the tx op mode is not being
> configured by some reason and so it is not enabled.
> 
> Please check if this path is being executed:
> 
> stmmac_mtl_configuration >> stmmac_dma_operation_mode >> priv->hw->dma->dma_tx_mode
> 
> It must iterate by all the available channels / queues, that should be =1 since
> I assume you have a single queue:
> 
> 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
> 		for (chan = 0; chan < rx_channels_count; chan++)
> 			priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode, chan,
> 						   rxfifosz);
> 
> 		for (chan = 0; chan < tx_channels_count; chan++)
> 			priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode, chan);
> 
> Could you please check if RX and TX op mode are being programmed?
> 
> The rx and tx queue counters are initialized in stmmac_mtl_setup() function
> (stmmac_platform.c). If they are not declared in DT they assume the default
> value of 1.
> 

Since stmmac_mtl_configuration is only called with priv->synopsys_id >= DWMAC_CORE_4_00, all older platform never call stmmac_dma_operation_mode.

Re-adding stmmac_dma_operation_mode at its place before 6deee2221e110f6574988120dba6cab7e7313f44 "net: stmmac: prepare dma op mode config for multiple queues" fix my issue.
