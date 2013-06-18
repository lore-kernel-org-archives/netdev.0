From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] bnx2x: add support for ndo_ll_poll
Date: Tue, 18 Jun 2013 01:10:58 -0700
Message-ID: <1371543058.3252.214.camel@edumazet-glaptop>
References: <1371541333-19225-1-git-send-email-dmitry@broadcom.com>
	 <1371541333-19225-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:46463 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab3FRILE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 04:11:04 -0400
Received: by mail-ea0-f175.google.com with SMTP id z7so2311366eaf.20
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 01:11:02 -0700 (PDT)
In-Reply-To: <1371541333-19225-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-18 at 10:42 +0300, Dmitry Kravkov wrote:
> Adds ndo_ll_poll method and locking for FPs between LL and the napi.
> 
> When receiving a packet we use skb_mark_ll to record the napi it came from.
> Add each napi to the napi_hash right after netif_napi_add().
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 125 +++++++++++++++++++++++
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  73 +++++++++++--
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |  23 ++++-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   4 +
>  4 files changed, 213 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index f76597e..a295a53 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -485,6 +485,21 @@ struct bnx2x_fastpath {
>  	struct bnx2x		*bp; /* parent */
>  
>  	struct napi_struct	napi;
> +
> +#ifdef CONFIG_NET_LL_RX_POLL
> +	unsigned int state;
> +#define BNX2X_FP_STATE_IDLE		      0
> +#define BNX2X_FP_STATE_NAPI		(1 << 0)    /* NAPI owns this FP */
> +#define BNX2X_FP_STATE_POLL		(1 << 1)    /* poll owns this FP */
> +#define BNX2X_FP_STATE_NAPI_YIELD	(1 << 2)    /* NAPI yielded this FP */
> +#define BNX2X_FP_STATE_POLL_YIELD	(1 << 3)    /* poll yielded this FP */
> +#define BNX2X_FP_YIELD	(BNX2X_FP_STATE_NAPI_YIELD | BNX2X_FP_STATE_POLL_YIELD)
> +#define BNX2X_FP_LOCKED	(BNX2X_FP_STATE_NAPI | BNX2X_FP_STATE_POLL)
> +#define BNX2X_FP_USER_PEND (BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_POLL_YIELD)
> +	/* protect state */
> +	spinlock_t lock;
> +#endif /* CONFIG_NET_LL_RX_POLL */
> +
>  	union host_hc_status_block	status_blk;
>  	/* chip independent shortcuts into sb structure */
>  	__le16			*sb_index_values;
> @@ -557,6 +572,116 @@ struct bnx2x_fastpath {
>  #define bnx2x_fp_stats(bp, fp)	(&((bp)->fp_stats[(fp)->index]))
>  #define bnx2x_fp_qstats(bp, fp)	(&((bp)->fp_stats[(fp)->index].eth_q_stats))
>  
> +#ifdef CONFIG_NET_LL_RX_POLL
> +static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
> +{
> +	spin_lock_init(&fp->lock);
> +	fp->state = BNX2X_FP_STATE_IDLE;
> +}
> +
> +/* called from the device poll routine to get ownership of a FP */
> +static inline int bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)

static inline bool ?

> +{
> +	int rc = true;
> +
> +	spin_lock(&fp->lock);
> +	if (fp->state & BNX2X_FP_LOCKED) {
> +		WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
> +		fp->state |= BNX2X_FP_STATE_NAPI_YIELD;
> +		rc = false;
> +	} else {
> +		/* we don't care if someone yielded */
> +		fp->state = BNX2X_FP_STATE_NAPI;
> +	}
> +	spin_unlock(&fp->lock);
> +	return rc;
> +}
> +
> +/* returns true is someone tried to get the FP while napi had it */
> +static inline int bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)

bool

> +{
> +	int rc = false;
> +
> +	spin_lock(&fp->lock);
> +	WARN_ON(fp->state &
> +		(BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_NAPI_YIELD));
> +
> +	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
> +		rc = true;
> +	fp->state = BNX2X_FP_STATE_IDLE;
> +	spin_unlock(&fp->lock);
> +	return rc;
> +}
> +
> +/* called from bnx2x_low_latency_poll() */
> +static inline int bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)

bool

> +{
> +	int rc = true;
> +
> +	spin_lock_bh(&fp->lock);
> +	if ((fp->state & BNX2X_FP_LOCKED)) {
> +		fp->state |= BNX2X_FP_STATE_POLL_YIELD;
> +		rc = false;
> +	} else {
> +		/* preserve yield marks */
> +		fp->state |= BNX2X_FP_STATE_POLL;
> +	}
> +	spin_unlock_bh(&fp->lock);
> +	return rc;
> +}
> +
> +/* returns true if someone tried to get the FP while it was locked */
> +static inline int bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
bool

> +{
> +	int rc = false;
> +
> +	spin_lock_bh(&fp->lock);
> +	WARN_ON(fp->state & BNX2X_FP_STATE_NAPI);
> +
> +	if (fp->state & BNX2X_FP_STATE_POLL_YIELD)
> +		rc = true;
> +	fp->state = BNX2X_FP_STATE_IDLE;
> +	spin_unlock_bh(&fp->lock);
> +	return rc;
> +}
> +
> +/* true if a socket is polling, even if it did not get the lock */
> +static inline int bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
bool

> +{
> +	WARN_ON(!(fp->state & BNX2X_FP_LOCKED));
> +	return fp->state & BNX2X_FP_USER_PEND;
> +}
> +#else
> +static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
> +{
> +}
> +
> +static inline bool bnx2x_fp_lock_napi(struct bnx2x_fastpath *fp)
> +{
> +	return true;
> +}
> +
> +static inline bool bnx2x_fp_unlock_napi(struct bnx2x_fastpath *fp)
> +{
> +	return false;
> +}
> +
> +static inline bool bnx2x_fp_lock_poll(struct bnx2x_fastpath *fp)
> +{
> +	return false;
> +}
> +
> +static inline bool bnx2x_fp_unlock_poll(struct bnx2x_fastpath *fp)
> +{
> +	return false;
> +}
> +
> +static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
> +{
> +	return false;
> +}
> +#endif /* CONFIG_NET_LL_RX_POLL */
> +
>  /* Use 2500 as a mini-jumbo MTU for FCoE */
>  #define BNX2X_FCOE_MINI_JUMBO_MTU	2500
>  
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 4e42bdd..d8d371b 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -24,6 +24,7 @@
>  #include <net/tcp.h>
>  #include <net/ipv6.h>
>  #include <net/ip6_checksum.h>
> +#include <net/ll_poll.h>
>  #include <linux/prefetch.h>
>  #include "bnx2x_cmn.h"
>  #include "bnx2x_init.h"
> @@ -669,7 +670,12 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  		}
>  	}
>  #endif
> -	napi_gro_receive(&fp->napi, skb);
> +	skb_mark_ll(skb, &fp->napi);
> +
> +	if (bnx2x_fp_ll_polling(fp))
> +		netif_receive_skb(skb);
> +	else
> +		napi_gro_receive(&fp->napi, skb);
>  }
>  

This is racy [1], so I would not care and always call napi_gro_receive()

[1] We would have to flush GRO state every time we call
bnx2x_fp_lock_poll()

Ideally, we could keep a counter of enabled LLS sockets, to
automatically switch off/on GRO, but in net/core, not in every driver.
