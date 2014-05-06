From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2 0/9] net: ethernet: marvell: Assorted fixes
Date: Tue,  6 May 2014 14:20:49 -0300
Message-ID: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53512 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752052AbaEFRVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:21:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series consists of cleanups and minor improvements on mvneta, mv643xx_eth
and mvmdio drivers. None of the patches imply any functionality change, except
for the patch six "Change the number of default rx queues to one".

This patch reduces the driver's allocated resources and makes the multiqueue
path in the poll function not get taken. In other words, in the poll():

static int mvneta_poll(struct napi_struct *napi, int budget)
{
	/* .. */
        if (rxq_number > 1) {
		/* .. */
        } else {
                rx_done = mvneta_rx(pp, budget, &pp->rxqs[rxq_def]);
                budget -= rx_done;
        }
}

the first block of the 'if' won't be taken. This should be completely harmless,
as the driver only supports the first queue, by requiring 'rxq_def' to be '0'.
This is explained by a comment in the code:

        /* Our multiqueue support is not complete, so for now, only
         * allow the usage of the first RX queue
         */
        if (rxq_def != 0) {
                dev_err(&pdev->dev, "Invalid rxq_def argument: %d\n", rxq_def);
                return -EINVAL;
        }

Willy, Thomas: given you've done some work on these drivers, could you review
the series and comment?

Changes from v1:

  * Added two more clean-up patches to the series.

  * Added Sebastian's Acked-by's.

  * Fixed extra empty line in "net: mv643xx_eth: Simplify
    mv643xx_eth_adjust_link()" as pointed out by David Miller.

Ezequiel Garcia (9):
  net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
  net: mvneta: Clean-up mvneta_tx_frag_process()
  net: mvneta: Check tx queue setup error in mvneta_change_mtu()
  net: mvneta: Clean-up mvneta_init()
  net: mvneta: Use prepare/commit API to simplify MAC address setting
  net: mvneta: Change the number of default rx queues to one
  net: mvmdio: Use devm_* API to simplify the code
  net: mvneta: Factorize feature setting
  net: mvneta: Remove unneeded 'weigth' field

 drivers/net/ethernet/marvell/mv643xx_eth.c | 14 ++---
 drivers/net/ethernet/marvell/mvmdio.c      | 18 ++----
 drivers/net/ethernet/marvell/mvneta.c      | 97 ++++++++++++------------------
 3 files changed, 49 insertions(+), 80 deletions(-)

-- 
1.9.1
