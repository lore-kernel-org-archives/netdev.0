From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH, net-next] qede: hide 32-bit compile warning
Date: Fri, 26 Aug 2016 09:51:09 -0700
Message-ID: <1472230269.4914.41.camel@perches.com>
References: <20160826153808.838861-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
        Manish Chopra <manish.chopra@qlogic.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826153808.838861-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-08-26 at 17:37 +0200, Arnd Bergmann wrote:
> The addition of the per-queue statistics introduced a harmless warning
> on all 32-bit architectures:
> 
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c: In function 'qede_get_ethtool_stats':
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:244:31: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>       buf[cnt++] = QEDE_TQSTATS_DATA(edev,
>                                ^
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:244:22: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
>       buf[cnt++] = QEDE_TQSTATS_DATA(edev,
>                       ^
> This changes the cast to 'void *' to shut up the warning, which
> avoids the assumptions on the size of the pointer type.
[]
> diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
[]
> @@ -60,7 +60,7 @@ static const struct {
>  };
>  
>  #define QEDE_TQSTATS_DATA(dev, sindex, tssid, tcid) \
> -	(*((u64 *)(((u64)(&dev->fp_array[tssid].txqs[tcid])) +\
> +	(*((u64 *)(((void *)(&dev->fp_array[tssid].txqs[tcid])) +\
>  		   qede_tqstats_arr[(sindex)].offset)))

That thing is perhaps overly complicated.
Maybe a static inline like below would be easier to read:

static inline u64
QEDE_TQSTATS_DATA(const struct qede_dev *edev,
		  int sindex, int tssid, int tcid)
{
	struct qede_tx_queue *txq = &edev->fp_array[tssid].txqs[tcid];
	size_t offset = qede_tqstats_arr[sindex].offset;

	return *(u64 *)((unsigned long)txq + offset);
}
