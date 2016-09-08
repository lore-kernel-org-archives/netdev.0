From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 1/6] sctp: remove the unnecessary state check in
 sctp_outq_tail
Date: Thu, 8 Sep 2016 15:23:19 -0400
Message-ID: <20160908192319.GD16608@hmsreliant.think-freely.org>
References: <cover.1473326067.git.lucien.xin@gmail.com>
 <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
 <20160908142701.GC16608@hmsreliant.think-freely.org>
 <CADvbK_dxTYrPPFJT5UPZErZLbW9y9oRm+VWbQXxhruwV6UgOZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57209 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938685AbcIHTXd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 15:23:33 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_dxTYrPPFJT5UPZErZLbW9y9oRm+VWbQXxhruwV6UgOZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 01:34:05AM +0800, Xin Long wrote:
> >> Data Chunks are only sent by sctp_primitive_SEND, in which sctp checks
> >> the asoc's state through statetable before calling sctp_outq_tail. So
> >> there's no need to do it again in sctp_outq_tail.
> >>
> >> This patch is to remove it from sctp_outq_tail.
> >>
> >> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > This doesn't seem safe to me.  The send operation is handled in side effect
> > processing off a queue that might have operations queued ahead of it, which
> > affect the associations state.  I think you need to keep this check in place
> >
> But not really for Data Chunk.
> 
> There are 3 places calling sctp_outq_tail.
> 1. in sctp_assoc_rwnd_increase():
>    it's for sending sack chunk, so this patch is safe for here
> 2. sctp_cmd_interpreter(), SCTP_CMD_REPLY:
>    still not Data Chunk, so safe.
> 3.SCTP_CMD_SEND_MSG: ->  sctp_cmd_send_msg()
>    it's for Data Chunk, but it's only called by sctp_sf_do_prm_send().
> 
Its not enough to just look at the paths where outq_tail is called, because
the outq_tail function is checking a state variable that can update
asynchronously in the side effect processing queue.  Look at any one of the
timer functions.  Those all fire asynchronous to the outq list, but they all
enqueue to the side effect list.  Its entirely possible that the state can be
ESTABLISHED in the primitive send path, but before you enqueue the SEND
sideffect, a timer will pop and enqueue a NEW_STATE side effect.  The end result
is you need to check the state again.

Neil

> #define TYPE_SCTP_PRIMITIVE_SEND  { \
> ...
> /* SCTP_STATE_COOKIE_WAIT */ \
> TYPE_SCTP_FUNC(sctp_sf_do_prm_send), \
> /* SCTP_STATE_COOKIE_ECHOED */ \
> TYPE_SCTP_FUNC(sctp_sf_do_prm_send), \
> /* SCTP_STATE_ESTABLISHED */ \
> TYPE_SCTP_FUNC(sctp_sf_do_prm_send), \
> /* SCTP_STATE_SHUTDOWN_PENDING */ \
> 
> 
> in sctp_sf_do_prm_send():
>    sctp_add_cmd_sf(commands, SCTP_CMD_SEND_MSG, SCTP_DATAMSG(msg));
>    return SCTP_DISPOSITION_CONSUME;
> 
> This function is called by PRIMITIVE_SEND, and every time after
> calling sctp_do_sm(), there must be no operations inside.
> so it's impossible that other operations queued ahead of it.
> 
> I'm not sure if I miss some special case, pls correct me if I'm wrong.
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
