From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 11:10:00 -0200
Message-ID: <20170120131000.GR3781@localhost.localdomain>
References: <20170120130157.20034-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, lucien.xin@gmail.com
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170120130157.20034-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 01:01:57PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The comparison on the timeout can lead to an array overrun
> read on sctp_timer_tbl because of an off-by-one error. Fix
> this by using < instead of <= and also compare to the array
> size rather than SCTP_EVENT_TIMEOUT_MAX.
> 
> Fixes CoverityScan CID#1397639 ("Out-of-bounds read")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sctp/debug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/debug.c b/net/sctp/debug.c
> index 95d7b15..e371a0d 100644
> --- a/net/sctp/debug.c
> +++ b/net/sctp/debug.c
> @@ -166,7 +166,7 @@ static const char *const sctp_timer_tbl[] = {
>  /* Lookup timer debug name. */
>  const char *sctp_tname(const sctp_subtype_t id)
>  {
> -	if (id.timeout <= SCTP_EVENT_TIMEOUT_MAX)
> +	if (id.timeout < ARRAY_SIZE(sctp_timer_tbl))
>  		return sctp_timer_tbl[id.timeout];

The issue exists but this is not the right fix.
Issue was introduced by 7b9438de0cd4 ("sctp: add stream reconf timer")
as it introduced a new timer but didn't add the timer name here, so the
fix should (also) include:

diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 95d7b15dad21..c5f4ed5242ac 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -159,6 +159,7 @@ static const char *const sctp_timer_tbl[] = {
 	"TIMEOUT_T4_RTO",
 	"TIMEOUT_T5_SHUTDOWN_GUARD",
 	"TIMEOUT_HEARTBEAT",
+	"TIMEOUT_RECONF",
 	"TIMEOUT_SACK",
 	"TIMEOUT_AUTOCLOSE",
 };

Thanks,
Marcelo

>  	return "unknown_timer";
>  }
> -- 
> 2.10.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
