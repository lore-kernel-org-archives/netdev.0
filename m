From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: sctp: set chunk->tsn_gap_acked at the end of cycle
Date: Fri, 22 Nov 2013 09:27:03 -0500
Message-ID: <528F69B7.7020902@gmail.com>
References: <1385106589-402-1-git-send-email-changxiangzhong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chang Xiangzhong <changxiangzhong@gmail.com>,
	nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385106589-402-1-git-send-email-changxiangzhong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/22/2013 02:49 AM, Chang Xiangzhong wrote:
> tsn_gap_acked is an important state flag in chunk, which indicates if the
> chunk has been acked in gap reports before.

Actually, this bit indicates simply that the chunk has been acked.  It
doesn't state whether it's been acked in a gap report or via cumulative tsn.

> SFR-CACC algorithm depends on this
> variable. So set this at the end of each iteration, otherwise the SFR-CACC
> algorithm would never be toggled.
> 
> Signed-off-by: Chang Xiangzhong <changxiangzhong@gmail.com>
> ---
>  net/sctp/outqueue.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1b494fa..bff828c 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1396,7 +1396,6 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  			 * while DATA was outstanding).
>  			 */
>  			if (!tchunk->tsn_gap_acked) {
> -				tchunk->tsn_gap_acked = 1;
>  				if (TSN_lt(*highest_new_tsn_in_sack, tsn))
>  					*highest_new_tsn_in_sack = tsn;
>  				bytes_acked += sctp_data_size(tchunk);
> @@ -1460,6 +1459,8 @@ static void sctp_check_transmitted(struct sctp_outq *q,
>  				 */
>  				list_add_tail(lchunk, &tlist);
>  			}
> +
> +			tchunk->tsn_gap_acked = 1;

The current code will set the state if it hasn't been set yet.  Why is
this needed?

Now there is an issue with tracking highest_new_tsn_in_sack.  The spec
is a little vague on this, but the highest_new_tsn_in_sack only supposed
to track tsns that have not been resent.  If a tsn has been reneged, and
then sent again, it is not considered 'new' thus should not count
toward highest_new_tsn_in_sack.  We currently do not track this right.

-vlad

-vlad

>  		} else {
>  			if (tchunk->tsn_gap_acked) {
>  				pr_debug("%s: receiver reneged on data TSN:0x%x\n",
> 
