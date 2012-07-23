From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows
 SACK when bundling
Date: Sun, 22 Jul 2012 20:49:32 -0400
Message-ID: <20120723004932.GB8040@neilslaptop.think-freely.org>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, sri@us.ibm.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xufengzhang.main@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2012 at 01:57:30PM +0800, xufengzhang.main@gmail.com wrote:
> When "Invalid Stream Identifier" ERROR happens after process the
> received DATA chunks, this ERROR chunk is enqueued into outqueue
> before SACK chunk, so when bundling ERROR chunk with SACK chunk,
> the ERROR chunk is always placed first in the packet because of
> the chunk's position in the outqueue.
> This violates sctp specification:
>     RFC 4960 6.5. Stream Identifier and Stream Sequence Number
>     ...The endpoint may bundle the ERROR chunk in the same
>     packet as the SACK as long as the ERROR follows the SACK.
> So we must place SACK first when bundling "Invalid Stream Identifier"
> ERROR and SACK in one packet.
> Although we can do that by enqueue SACK chunk into outqueue before
> ERROR chunk, it will violate the side-effect interpreter processing.
> It's easy to do this job when dequeue chunks from the outqueue,
> by this way, we introduce a flag 'has_isi_err' which indicate
> whether or not the "Invalid Stream Identifier" ERROR happens.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>

Not sure I understand how you came into this error.  If we get an invalid
stream, we issue an SCTP_REPORT_TSN side effect, followed by an SCTP_CMD_REPLY
which sends the error chunk.  The reply goes through
sctp_outq_tail->sctp_outq_chunk->sctp_outq_transmit_chunk->sctp_outq_append_chunk.
That last function checks to see if a sack is already part of the packet, and if
there isn't one, appends one, using the updated tsn map.  So Can you explain in
some more detail how you're getting into this situation?

Thanks!
Neil
