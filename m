From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: set association state to established in
 dupcook_a handler
Date: Thu, 24 Jan 2013 07:39:39 -0500
Message-ID: <20130124123939.GA20658@hmsreliant.think-freely.org>
References: <1358995474-28369-1-git-send-email-xufengzhang.main@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xufengzhang.main@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49896 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065Ab3AXMjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 07:39:55 -0500
Content-Disposition: inline
In-Reply-To: <1358995474-28369-1-git-send-email-xufengzhang.main@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 10:44:34AM +0800, xufengzhang.main@gmail.com wrote:
> From: Xufeng Zhang <xufeng.zhang@windriver.com>
> 
> While sctp handling a duplicate COOKIE-ECHO and the action is
> 'Association restart', sctp_sf_do_dupcook_a() will processing
> the unexpected COOKIE-ECHO for peer restart, but it does not set
> the association state to SCTP_STATE_ESTABLISHED, so the association
> could stuck in SCTP_STATE_SHUTDOWN_PENDING state forever.
> This violates the sctp specification:
>   RFC 4960 5.2.4. Handle a COOKIE ECHO when a TCB Exists
>   Action
>   A) In this case, the peer may have restarted. .....
>      After this, the endpoint shall enter the ESTABLISHED state.
> 
> To resolve this problem, adding a SCTP_CMD_NEW_STATE cmd to the
> command list before SCTP_CMD_REPLY cmd, this will set the restart
> association to SCTP_STATE_ESTABLISHED state properly and also avoid
> I-bit being set in the DATA chunk header when COOKIE_ACK is bundled
> with DATA chunks.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
> v2:
> - Put the SCTP_CMD_NEW_STATE command before SCTP_CMD_REPLY and after SCTP_CMD_EVENT_ULP
>   suggested by Vlad and Neil
> - Improve the last paragraph of the commit header
>  
>  net/sctp/sm_statefuns.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 618ec7e..5131fcf 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -1779,8 +1779,10 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
>  
>  	/* Update the content of current association. */
>  	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC, SCTP_ASOC(new_asoc));
> -	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
>  	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
> +	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
> +			SCTP_STATE(SCTP_STATE_ESTABLISHED));
> +	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
>  	return SCTP_DISPOSITION_CONSUME;
>  
>  nomem_ev:
> -- 
> 1.7.0.2
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
