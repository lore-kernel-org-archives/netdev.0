From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH v2 03/46] net drivers: remove unnecessary
 dma_sync_to_device(DMA_FROM_DEVICE)
Date: Mon, 11 Jul 2011 11:30:39 +0300
Message-ID: <201107111130.39629.vladz@broadcom.com>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
	<6f2d2a58a4932cd93a0291fac9636d3681d69031.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Matthew Carlson <mcarlson@broadcom.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ron Mercer <ron.mercer@qlogic.com>, Michael Chan <mchan@broadcom.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Divy Le Ray <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Hartley Sweeten <hsweeten@visionengravers.com>,
	John Ronciak <john.ronciak@intel.com>, Jon Mas
To: =?utf-8?q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <6f2d2a58a4932cd93a0291fac9636d3681d69031.1310339688.git.mirq-linux@rere.qmqm.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>         prod_rx_buf->skb = skb;
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
> index c016e20..c9e49a0 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.h
> +++ b/drivers/net/bnx2x/bnx2x_cmn.h
> @@ -923,16 +923,11 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x
> *bp, static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
>                                       u16 cons, u16 prod)
>  {
> -       struct bnx2x *bp = fp->bp;
>         struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
>         struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
>         struct eth_rx_bd *cons_bd = &fp->rx_desc_ring[cons];
>         struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
> 
> -       dma_sync_single_for_device(&bp->pdev->dev,
> -                                  dma_unmap_addr(cons_rx_buf, mapping),
> -                                  RX_COPY_THRESH, DMA_FROM_DEVICE);
> -
>         dma_unmap_addr_set(prod_rx_buf, mapping,
>                            dma_unmap_addr(cons_rx_buf, mapping));
>         prod_rx_buf->skb = cons_rx_buf->skb;

Michal, pls., note that this function is only called for buffers which were 
previously dma_synced towards CPU (your "[PATCH v2 05/46] net: bnx2x: fix DMA 
sync direction" properly fixes the direction of the first call which was 
incorrect). Then, according to the 3d edition of the "Linux device drivers" 
book, chapter 15, "Setting up streaming DMA mappings" article, end of the page 
449, when we call for dma_syc_single_for_cpu() the buffer ownership gets to 
the CPU and CPU may safely access the buffer (in particular, we read it). Then 
the author says: "Before the device accesses the buffer, however, ownership 
should be transfered back to it with: dma_sync_single_for_device().

The DMA-API.txt document u've referenced doesn't refer the above function, so, 
it's unclear how your fix may be based on it. On the other hand it clearly 
contradicts the "Linux device driver" book.

Pls., comment.

thanks,
vlad


------------------------------------------------------------------------------
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security 
threats, fraudulent activity, and more. Splunk takes this data and makes 
sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
