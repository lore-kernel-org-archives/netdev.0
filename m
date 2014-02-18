From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH RFC] sctp: Update HEARTBEAT timer immediately after user
 changed HB.interval
Date: Tue, 18 Feb 2014 09:50:04 -0500
Message-ID: <5303731C.8020308@gmail.com>
References: <1392703010-6128-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>, nhorman@tuxdriver.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392703010-6128-1-git-send-email-xufeng.zhang@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2014 12:56 AM, Xufeng Zhang wrote:
> For an established association, if user has updated the HB.interval
> parameter by setsockopt(), this new heartbeat interval will not
> take effect until:
>   - the expiry of the heartbeat timer and new hearbeat is sent.
>   - DATA chunk has been sent and the transport resets the timer.
> This could not meet the requirement of the user who need to
> get HEARTBEAT sent at the specified time.
> 
> Thus, we need to update the heartbeat timer immediately after
> user has changed HB.interval.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
>  net/sctp/socket.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9e91d6e..699ae1e 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2344,6 +2344,11 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
>  			if (trans) {
>  				trans->hbinterval =
>  				    msecs_to_jiffies(params->spp_hbinterval);
> +
> +				/* Update the heartbeat timer immediately. */
> +				if (!mod_timer(&trans->hb_timer,
> +					    sctp_transport_timeout(trans)))
> +					sctp_transport_hold(trans);

This is causes a rather inconsistent behavior in that it doesn't
account of the amount of time left on the hb timer.  Thus it doesn't
always do what commit log implies.  If the remaining time is shorter
then the new timeout value, it will take longer till the next HB
the application expects.

If the application has very strict timing requirement on the HBs, it
should trigger the HB manually.

We could rework the code to allow the combination of
SPP_HB_DEMAND | SPP_HB_ENABLE to work as follows:
  1) update the timer to the new value
  2) Send an immediate HB
     a) Update the hb timeout.

2a should probably be done regardless since it can cause 2 HB to be
outstanding at the same time.

-vlad


>  			} else if (asoc) {
>  				asoc->hbinterval =
>  				    msecs_to_jiffies(params->spp_hbinterval);
> 
