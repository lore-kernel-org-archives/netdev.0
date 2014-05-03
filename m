From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 0/7] net: ethernet: marvell: Assorted fixes
Date: Sat,  3 May 2014 15:26:55 -0300
Message-ID: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60604 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752218AbaECS2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:28:02 -0400
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

Ezequiel Garcia (7):
  net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
  net: mvneta: Clean-up mvneta_tx_frag_process()
  net: mvneta: Check tx queue setup error in mvneta_change_mtu()
  net: mvneta: Clean-up mvneta_init()
  net: mvneta: Use prepare/commit API to simplify MAC address setting
  net: mvneta: Change the number of default rx queues to one
  net: mvmdio: Use devm_* API to simplify the code

 drivers/net/ethernet/marvell/mv643xx_eth.c | 15 ++----
 drivers/net/ethernet/marvell/mvmdio.c      | 18 +++----
 drivers/net/ethernet/marvell/mvneta.c      | 86 +++++++++++++-----------------
 3 files changed, 47 insertions(+), 72 deletions(-)

-- 
1.9.1
