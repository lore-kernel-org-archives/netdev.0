From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: send abort chunk when max_retrans exceeded
Date: Tue, 20 Nov 2012 15:07:15 -0500
Message-ID: <20121120200714.GA20444@hmsreliant.think-freely.org>
References: <1353434344-17864-1-git-send-email-nhorman@tuxdriver.com>
 <50ABCF87.2090901@gmail.com>
 <20121120191514.GA10287@shamino.rdu.redhat.com>
 <50ABD9CA.7080907@gmail.com>
 <50ABDF66.2040603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55219 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab2KTUHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:07:25 -0500
Content-Disposition: inline
In-Reply-To: <50ABDF66.2040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 20, 2012 at 02:52:06PM -0500, Vlad Yasevich wrote:
> On 11/20/2012 02:28 PM, Vlad Yasevich wrote:
> >On 11/20/2012 02:15 PM, Neil Horman wrote:
> >>On Tue, Nov 20, 2012 at 01:44:23PM -0500, Vlad Yasevich wrote:
> >>>On 11/20/2012 12:59 PM, Neil Horman wrote:
> >>>>In the event that an association exceeds its max_retrans attempts,
> >>>>we should
> >>>>send an ABORT chunk indicating that we are closing the assocation as
> >>>>a result.
> >>>>Because of the nature of the error, its unlikely to be received, but
> >>>>its a nice
> >>>>clean way to close the association if it does make it through, and
> >>>>it will give
> >>>>anyone watching via tcpdump a clue as to what happened.
> >>>>
> >>>>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >>>>CC: Vlad Yasevich <vyasevich@gmail.com>
> >>>>CC: "David S. Miller" <davem@davemloft.net>
> >>>>CC: linux-sctp@vger.kernel.org
> >>>>---
> >>>>  include/net/sctp/sm.h    |  2 ++
> >>>>  net/sctp/sm_make_chunk.c | 26 +++++++++++++++++++++-----
> >>>>  net/sctp/sm_sideeffect.c |  9 ++++++++-
> >>>>  3 files changed, 31 insertions(+), 6 deletions(-)
> >>>>
> >>>>diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
> >>>>index b5887e1..2a82d13 100644
> >>>>--- a/include/net/sctp/sm.h
> >>>>+++ b/include/net/sctp/sm.h
> >>>>@@ -234,6 +234,8 @@ struct sctp_chunk
> >>>>*sctp_make_abort_violation(const struct sctp_association *,
> >>>>  struct sctp_chunk *sctp_make_violation_paramlen(const struct
> >>>>sctp_association *,
> >>>>                     const struct sctp_chunk *,
> >>>>                     struct sctp_paramhdr *);
> >>>>+struct sctp_chunk *sctp_make_violation_max_retrans(const struct
> >>>>sctp_association *,
> >>>>+                           const struct sctp_chunk *);
> >>>>  struct sctp_chunk *sctp_make_heartbeat(const struct
> >>>>sctp_association *,
> >>>>                    const struct sctp_transport *);
> >>>>  struct sctp_chunk *sctp_make_heartbeat_ack(const struct
> >>>>sctp_association *,
> >>>>diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> >>>>index fbe1636..d6a8c80 100644
> >>>>--- a/net/sctp/sm_make_chunk.c
> >>>>+++ b/net/sctp/sm_make_chunk.c
> >>>>@@ -1074,17 +1074,33 @@ struct sctp_chunk
> >>>>*sctp_make_violation_paramlen(
> >>>>  {
> >>>>      struct sctp_chunk *retval;
> >>>>      static const char error[] = "The following parameter had
> >>>>invalid length:";
> >>>>-    size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t) +
> >>>>-                sizeof(sctp_paramhdr_t);
> >>>>+    size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t);
> >>>>
> >>>>      retval = sctp_make_abort(asoc, chunk, payload_len);
> >>>>      if (!retval)
> >>>>          goto nodata;
> >>>>
> >>>>-    sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION,
> >>>>-            sizeof(error) + sizeof(sctp_paramhdr_t));
> >>>>+    sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION,
> >>>>sizeof(error));
> >>>>+    sctp_addto_chunk(retval, sizeof(error), error);
> >>>>+
> >>>>+nodata:
> >>>>+    return retval;
> >>>>+}
> >>>
> >>>Neil
> >>>
> >>>You ended dropping the parameter information of the parameter that
> >>>caused the violation.  Was that intentional?
> >>>
> >>Yes, it was, because theres not really IMO a specific parameter that
> >>causes this
> >>abort condition.
> >
> >Sure there is.  You changed sctp_make_violation_paramlen() which is
> >called when we receive a protocol parameter which has an invalid length.
> >This triggers a violation and the parameter is report back.  This has
> >nothing to do with max_rtx overflow.
> 
> It looks like you tried to re-use sctp_make_violation_paramlen(),
> abandoned that approach, but forgot to fully restore the old
> function...
> 
> -vlad
> 
Oh hell, you're right, my apologies, thats exactly what happened, and I
misunderstood what you were saying.  I thought you were asking why I wasn't
including a parameter segment in the max_retrans abort (because there isn't
any).  I completly missed the fact that I inadvertently mangled the
sctp_violation_paramlen function. 

I'll fix that up and repost.

Thanks
Neil
