From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] net: sctp: Don't use 64 kilobyte lookup table for four
 elements
Date: Mon, 28 Sep 2015 09:30:31 -0300
Message-ID: <20150928123031.GA24740@localhost.localdomain>
References: <1443293594-4908-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33188 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757269AbbI1Mag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 08:30:36 -0400
Content-Disposition: inline
In-Reply-To: <1443293594-4908-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 26, 2015 at 08:53:14PM +0200, Denys Vlasenko wrote:
> Seemingly innocuous sctp_trans_state_to_prio_map[] array
> is way bigger than it looks, since
> "[SCTP_UNKNOWN] = 2" expands into "[0xffff] = 2" !
> 
> This patch replaces it with switch() statement.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: linux-sctp@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> ---
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
> +		return 3; /* best case */
> +	case SCTP_UNKNOWN:
> +		return 2;
> +	case SCTP_PF:
> +		return 1;
> +	default: /* case SCTP_INACTIVE */
> +		return 0;	/* worst case */
> +	}
>  }

Nice finding, but please make above comments aligned to the column.
Then it looks good to me.

When posting v2, also post to netdev@vger.kernel.org, it's where Dave
collects sctp (amongst others) patches. Kernel patches are not collected
on linux-sctp@, though they are posted there too but for reviewing only.

Thanks,
Marcelo
