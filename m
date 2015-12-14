From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: [PATCH] chelsio: add support for other 10G boards
Date: Mon, 14 Dec 2015 22:58:42 +0300
Message-ID: <20151214195842.GA20848@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49009 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbbLNT65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:58:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen Hemminger,

The patch f1d3d38af757: "[PATCH] chelsio: add support for other 10G
boards" from Dec 1, 2006, leads to the following static checker
warning:

	drivers/net/ethernet/chelsio/cxgb/subr.c:630 t1_link_start()
	warn: was shift intended here '(mac->adapter->params.nports < 2)'

drivers/net/ethernet/chelsio/cxgb/subr.c
   623  int t1_link_start(struct cphy *phy, struct cmac *mac, struct link_config *lc)
   624  {
   625          unsigned int fc = lc->requested_fc & (PAUSE_RX | PAUSE_TX);
   626  
   627          if (lc->supported & SUPPORTED_Autoneg) {
   628                  lc->advertising &= ~(ADVERTISED_ASYM_PAUSE | ADVERTISED_PAUSE);
   629                  if (fc) {
   630                          if (fc == ((PAUSE_RX | PAUSE_TX) &
   631                                     (mac->adapter->params.nports < 2)))

This condition is never weird.  PAUSE_RX is 1.  PAUSE_TX is 2.
The nports < 2 condition is either 0 or 1.  We know fc is in 1-3 range.

We could re-write it as:

	if (fc == 1 && mac->adapter->params.nports < 2)

The static checker is suggesting that we could do nports << 2 but then
the condition would never be true so that can't be right.

   632                                  lc->advertising |= ADVERTISED_PAUSE;
   633                          else {
   634                                  lc->advertising |= ADVERTISED_ASYM_PAUSE;
   635                                  if (fc == PAUSE_RX)
   636                                          lc->advertising |= ADVERTISED_PAUSE;
   637                          }
   638                  }
   639                  phy->ops->advertise(phy, lc->advertising);

regards,
dan carpenter
