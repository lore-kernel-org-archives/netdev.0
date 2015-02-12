From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net] tg3: Hold tp->lock before calling tg3_halt() from
 tg3_init_one()
Date: Wed, 11 Feb 2015 17:40:03 -0800
Message-ID: <1423705203.4744.1.camel@prashant>
References: <54DC0140.6000406@ce.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "mchan@broadcom.com" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Junichi Nomura <j-nomura@ce.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:1593 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbBLB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 20:59:49 -0500
In-Reply-To: <54DC0140.6000406@ce.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-12 at 01:26 +0000, Junichi Nomura wrote:
> tg3_init_one() calls tg3_halt() without tp->lock despite its assumption
> and causes deadlock.
> If lockdep is enabled, a warning like this shows up before the stall:
> 
>   [ BUG: bad unlock balance detected! ]
>   3.19.0test #3 Tainted: G            E
>   -------------------------------------
>   insmod/369 is trying to release lock (&(&tp->lock)->rlock) at:
>   [<ffffffffa02d5a1d>] tg3_chip_reset+0x14d/0x780 [tg3]
>   but there are no more locks to release!
> 
> tg3_init_one() doesn't call tg3_halt() under normal situation but
> during kexec kdump I hit this problem.
> 
> Fixes: 932f19de ("tg3: Release tp->lock before invoking synchronize_irq()")
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 615a6db..23a019c 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -17855,8 +17855,10 @@ static int tg3_init_one(struct pci_dev *pdev,
>  	 */
>  	if ((tr32(HOSTCC_MODE) & HOSTCC_MODE_ENABLE) ||
>  	    (tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
> +		tg3_full_lock(tp, 0);
>  		tw32(MEMARB_MODE, MEMARB_MODE_ENABLE);
>  		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
> +		tg3_full_unlock(tp);
>  	}
>  
>  	err = tg3_test_dma(tp);
> -- 
> 1.9.3

Acked-by: Prashant Sreedharan <prashant@broadcom.com>
