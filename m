From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 1/1] net: ethernet: davinci_cpdma: Add boundary for rx and
 tx descriptors
Date: Mon, 10 Dec 2012 09:24:50 +0100
Message-ID: <CABkLObqOEMKMD3df5pEDJWsGPA=oAj34Yz867D7p2hGdTr0WCA@mail.gmail.com>
References: <1355125052-28448-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	s.hauer@pengutronix.de
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1355125052-28448-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again,

On Mon, Dec 10, 2012 at 8:37 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> When there is heavy transmission traffic in the CPDMA, then Rx descriptors
> memory is also utilized as tx desc memory this leads to reduced rx desc memory
> which leads to poor performance.
>

"poor performance" is an understatement, see Sascha's description of
his patch. At initialization of the driver, half of the descriptors in
the pool are allocated for rx. When a packet arrives, one of the rx
descriptors is released and a new one is allocated. If tx allocates
this descriptor in the meantime, it is lost for rx forever! If tx
consumes all rx descriptors this way, the rx channel is dead!

Regards, Christian

> This patch adds boundary for tx and rx descriptors in bd ram dividing the
> descriptor memory to ensure that during heavy transmission tx doesn't use
> rx descriptors.
>
> This patch is already applied to davinci_emac driver, since CPSW and
> davici_dmac uses the same CPDMA, moving the boundry seperation from
> Davinci EMAC driver to CPDMA driver which was done in the following
> commit
>
> commit 86d8c07ff2448eb4e860e50f34ef6ee78e45c40c
> Author: Sascha Hauer <s.hauer@pengutronix.de>
> Date:   Tue Jan 3 05:27:47 2012 +0000
>
>     net/davinci: do not use all descriptors for tx packets
>
>     The driver uses a shared pool for both rx and tx descriptors.
>     During open it queues fixed number of 128 descriptors for receive
>     packets. For each received packet it tries to queue another
>     descriptor. If this fails the descriptor is lost for rx.
>     The driver has no limitation on tx descriptors to use, so it
>     can happen during a nmap / ping -f attack that the driver
>     allocates all descriptors for tx and looses all rx descriptors.
>     The driver stops working then.
>     To fix this limit the number of tx descriptors used to half of
>     the descriptors available, the rx path uses the other half.
>
>     Tested on a custom board using nmap / ping -f to the board from
>     two different hosts.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
