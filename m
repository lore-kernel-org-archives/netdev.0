From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows
 SACK when bundling
Date: Mon, 23 Jul 2012 08:14:11 -0400
Message-ID: <20120723121411.GC16518@hmsreliant.think-freely.org>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
 <20120723004932.GB8040@neilslaptop.think-freely.org>
 <500CB74A.4040300@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xufengzhang.main@gmail.com, vyasevich@gmail.com, sri@us.ibm.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xufeng zhang <xufeng.zhang@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47835 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab2GWMOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 08:14:32 -0400
Content-Disposition: inline
In-Reply-To: <500CB74A.4040300@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 23, 2012 at 10:30:34AM +0800, xufeng zhang wrote:
> On 07/23/2012 08:49 AM, Neil Horman wrote:
> >
> >Not sure I understand how you came into this error.  If we get an invalid
> >stream, we issue an SCTP_REPORT_TSN side effect, followed by an SCTP_CMD_REPLY
> >which sends the error chunk.  The reply goes through
> >sctp_outq_tail->sctp_outq_chunk->sctp_outq_transmit_chunk->sctp_outq_append_chunk.
> >That last function checks to see if a sack is already part of the packet, and if
> >there isn't one, appends one, using the updated tsn map.
> Yes, you are right, but consider the invalid stream identifier's
> DATA chunk is the first
> DATA chunk in the association which will need SACK immediately.
> Here is what I thought of the scenario:
>     sctp_sf_eat_data_6_2()
>         -->sctp_eat_data()
>             -->sctp_make_op_error()
>             -->sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(err))
>             -->sctp_outq_tail()          /* First enqueue ERROR chunk */
>         -->sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, SCTP_FORCE())
>             -->sctp_gen_sack()
>                 -->sctp_make_sack()
>                 -->sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
> SCTP_CHUNK(sack))
>                 -->sctp_outq_tail()          /* Then enqueue SACK chunk */
> 
> So SACK chunk is enqueued after ERROR chunk.
Ah, I see.  Since the ERROR and SACK chunks are both control chunks, and since
we explicitly add the SACK to the control queue instead of going through the
bundle path in sctp_packet_append_chunk the ordering gets wrong.

Ok, so the problem makes sense.  I think the soultion could be alot easier
though.  IIRC SACK chunks always live at the head of a packet, so why not just
special case it in sctp_outq_tail?  I.e. instead of doing a list_add_tail, in
the else clause of sctp_outq_tail check the chunk_hdr->type to see if its
SCTP_CID_SACK.  If it is, use list_add_head rather than list_add_tail.  I think
that will fix up both the COOKIE_ECHO and ESTABLISHED cases, won't it?  And then
you won't have keep track of extra state in the packet configuration.

Regards
Neil
