From: "Ramirez Luna, Omar" <omar.ramirez@ti.com>
Subject: RE: [PATCH 6/8] netdev: separate out davinci cpdma controller code
Date: Tue, 3 Aug 2010 18:30:02 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A53043F3C8C2B@dlee03.ent.ti.com>
References: <1280842313-3743-1-git-send-email-cyril@ti.com>
 <1280842313-3743-7-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Nori, Sekhar" <nsekhar@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: "Chemparathy, Cyril" <cyril@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.c
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:49983 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757715Ab0HCXaE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 19:30:04 -0400
In-Reply-To: <1280842313-3743-7-git-send-email-cyril@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>From: linux-omap-owner@vger.kernel.org [mailto:linux-omap-owner@vger.kernel.org] On Behalf Of
>Chemparathy, Cyril
>
>In addition to being embedded into the EMAC controller, the CPDMA hardware
>block is used in TI's CPSW switch controller.  Fortunately, the programming
>interface to this hardware block remains pretty nicely consistent across these
>devices.
>
>This patch adds a new CPDMA services layer, which can then be reused across
>EMAC and CPSW drivers.
>
>Signed-off-by: Cyril Chemparathy <cyril@ti.com>
>---
> drivers/net/Kconfig         |   10 +
> drivers/net/Makefile        |    1 +
> drivers/net/davinci_cpdma.c |  836 +++++++++++++++++++++++++++++++++++++++++++
> drivers/net/davinci_cpdma.h |  105 ++++++
> 4 files changed, 952 insertions(+), 0 deletions(-)
> create mode 100644 drivers/net/davinci_cpdma.c
> create mode 100644 drivers/net/davinci_cpdma.h
>
[...]
>diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
>new file mode 100644
>index 0000000..acce1c1
>--- /dev/null
>+++ b/drivers/net/davinci_cpdma.c
[...]
>+struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
>+				     cpdma_handler_fn handler)
>+{
>+	struct cpdma_chan *chan;
>+	int ret, offset = (chan_num % CPDMA_MAX_CHANNELS) * 4;
>+	unsigned long flags;
>+
>+	if (__chan_linear(chan_num) >= ctlr->num_chan)
>+		return NULL;
>+
>+	ret = -ENOMEM;
>+	chan = kzalloc(sizeof(*chan), GFP_KERNEL);
>+	if (!chan)
>+		goto err_chan_alloc;
>+
>+	spin_lock_irqsave(&ctlr->lock, flags);
>+	ret = -EBUSY;
>+	if (ctlr->channels[chan_num])
>+		goto err_chan_busy;

Mem leaking 'chan'

>+
>+	chan->ctlr	= ctlr;
>+	chan->state	= CPDMA_STATE_IDLE;
>+	chan->chan_num	= chan_num;
>+	chan->handler	= handler;
>+
>+	if (is_rx_chan(chan)) {
>+		chan->hdp	= ctlr->params.rxhdp + offset;
>+		chan->cp	= ctlr->params.rxcp + offset;
>+		chan->rxfree	= ctlr->params.rxfree + offset;
>+		chan->int_set	= CPDMA_RXINTMASKSET;
>+		chan->int_clear	= CPDMA_RXINTMASKCLEAR;
>+		chan->td	= CPDMA_RXTEARDOWN;
>+		chan->dir	= DMA_FROM_DEVICE;
>+	} else {
>+		chan->hdp	= ctlr->params.txhdp + offset;
>+		chan->cp	= ctlr->params.txcp + offset;
>+		chan->int_set	= CPDMA_TXINTMASKSET;
>+		chan->int_clear	= CPDMA_TXINTMASKCLEAR;
>+		chan->td	= CPDMA_TXTEARDOWN;
>+		chan->dir	= DMA_TO_DEVICE;
>+	}
>+	chan->mask = BIT(chan_linear(chan));
>+
>+	spin_lock_init(&chan->lock);
>+
>+	ctlr->channels[chan_num] = chan;
>+	spin_unlock_irqrestore(&ctlr->lock, flags);
>+	return chan;
>+
>+err_chan_busy:
>+	spin_unlock_irqrestore(&ctlr->lock, flags);
>+err_chan_alloc:
>+	return ERR_PTR(ret);
>+}
[...]

Regards,

omar
