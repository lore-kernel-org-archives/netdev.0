From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: Fix error handling for switch statement case in
 the function sctp_cmd_interprete
Date: Tue, 5 Apr 2016 19:12:21 -0300
Message-ID: <20160405221220.GA15005@localhost.localdomain>
References: <1459892201-21397-1-git-send-email-bastienphilbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bastien Philbert <bastienphilbert@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459892201-21397-1-git-send-email-bastienphilbert@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2016 at 05:36:41PM -0400, Bastien Philbert wrote:
> This fixes error handling for the switch statement case
> SCTP_CMD_SEND_PKT by making the error value of the call
> to sctp_packet_transmit equal the variable error due to
> this function being able to fail with a error code. In
> addition allow the call to sctp_ootb_pkt_free afterwards
> to free up the no longer in use sctp packet even if the
> call to the function sctp_packet_transmit fails in order
> to avoid a memory leak here for not freeing the sctp

This leak shouldn't exist as sctp_packet_transmit() will free the packet
if it returns ENOMEM, through the nomem: handling.

But about making it visible to the user, that looks interesting to me
although I cannot foresee yet its effects, like the comment at the end
of sctp_packet_transmit() on not returning EHOSTUNREACH. Did you check
it?

> 
> Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
> ---
>  net/sctp/sm_sideeffect.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 7fe56d0..f3a8b58 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1434,7 +1434,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  		case SCTP_CMD_SEND_PKT:
>  			/* Send a full packet to our peer.  */
>  			packet = cmd->obj.packet;
> -			sctp_packet_transmit(packet, gfp);
> +			error = sctp_packet_transmit(packet, gfp);
>  			sctp_ootb_pkt_free(packet);
>  			break;
>  
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
