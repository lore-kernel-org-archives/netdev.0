From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] net: sctp: Don't use 64 kilobyte lookup table for
 four elements
Date: Mon, 28 Sep 2015 09:51:27 -0400
Message-ID: <20150928135127.GB5248@hmsreliant.think-freely.org>
References: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 28, 2015 at 02:34:04PM +0200, Denys Vlasenko wrote:
> Seemingly innocuous sctp_trans_state_to_prio_map[] array
> is way bigger than it looks, since
> "[SCTP_UNKNOWN] = 2" expands into "[0xffff] = 2" !
> 
> This patch replaces it with switch() statement.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> CC: linux-sctp@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> ---
> 
> Changes since v1: tweaked comments
> 
>  net/sctp/associola.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 197c3f5..dae51ac 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1208,20 +1208,22 @@ void sctp_assoc_update(struct sctp_association *asoc,
>   *   within this document.
>   *
>   * Our basic strategy is to round-robin transports in priorities
> - * according to sctp_state_prio_map[] e.g., if no such
> + * according to sctp_trans_score() e.g., if no such
>   * transport with state SCTP_ACTIVE exists, round-robin through
>   * SCTP_UNKNOWN, etc. You get the picture.
>   */
> -static const u8 sctp_trans_state_to_prio_map[] = {
> -	[SCTP_ACTIVE]	= 3,	/* best case */
> -	[SCTP_UNKNOWN]	= 2,
> -	[SCTP_PF]	= 1,
> -	[SCTP_INACTIVE] = 0,	/* worst case */
> -};
> -
>  static u8 sctp_trans_score(const struct sctp_transport *trans)
>  {
> -	return sctp_trans_state_to_prio_map[trans->state];
> +	switch (trans->state) {
> +	case SCTP_ACTIVE:
> +		return 3;	/* best case */
> +	case SCTP_UNKNOWN:
> +		return 2;
> +	case SCTP_PF:
> +		return 1;
> +	default: /* case SCTP_INACTIVE */
> +		return 0;	/* worst case */
> +	}
>  }
>  
>  static struct sctp_transport *sctp_trans_elect_tie(struct sctp_transport *trans1,
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
