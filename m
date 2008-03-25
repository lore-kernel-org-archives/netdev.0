From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: Fix Protocol violation when receiving a error length
 INIT ACK
Date: Tue, 25 Mar 2008 12:46:49 +0800
Message-ID: <47E883B9.5040907@cn.fujitsu.com>
References: <47E73E83.9000301@cn.fujitsu.com> <47E74B17.40907@cn.fujitsu.com> <47E87290.2080205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vladislav <vladislav.yasevich@hp.com>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60093 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbYCYEpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 00:45:47 -0400
In-Reply-To: <47E87290.2080205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gui:

I looked the source code and found that only in the state *COOKIE_WAIT* 
received INIT-ACK need to do this, not all of the states. The other 
states we should have known the init-tag of peer.

Gui Jianfeng wrote:
> Wei Yongjun wrote:
>   
>> NACK.
>>
>> If the INIT-ACK chunk is too short to contain the init-tag, get the
>> init-tag of peer may get a unexpected value.
>> Such as this:
>>  CHUNK_INIT_ACK
>>   Type                             = 2
>>   Flags                            = 0
>>   Length                           = 4
>>
>> So I think the better way is to set T bit of ABORT chunk and used the
>> own's Tag.
>>     
>
>   Seems reasonable. Please ignore the previous one, here is a new patch.
>
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> ---
>  net/sctp/outqueue.c     |    3 +++
>  net/sctp/sm_statefuns.c |    5 +++++
>  2 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 1bb3c5c..c071446 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -793,6 +793,9 @@ int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  			break;
>  
>  		case SCTP_CID_ABORT:
> +			if (sctp_test_T_bit(chunk)) {
> +				packet->vtag = asoc->c.my_vtag;
> +			}
>  		case SCTP_CID_SACK:
>  		case SCTP_CID_HEARTBEAT:
>  		case SCTP_CID_HEARTBEAT_ACK:
>   

> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index f2ed647..85e1d63 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -4144,6 +4144,11 @@ static sctp_disposition_t sctp_sf_abort_violation(
>  		goto nomem;
>  
>  	if (asoc) {
> +		/* Treat INIT-ACK as a special case. */
> +		if (chunk->chunk_hdr->type == SCTP_CID_INIT_ACK) {
> +			abort->chunk_hdr->flags |= SCTP_CHUNK_FLAG_T;
> +		}
> +
>  		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
>  		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
>  
>   
Those code should be move to sctp_make_abort 
<../cgi-bin/global.cgi?pattern=sctp_make_abort&type=reference>() for 
common using. And may be need check whether we need the T flags.

