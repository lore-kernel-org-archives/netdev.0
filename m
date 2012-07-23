From: xufeng zhang <xufeng.zhang@windriver.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows
 SACK when bundling
Date: Mon, 23 Jul 2012 10:30:34 +0800
Message-ID: <500CB74A.4040300@windriver.com>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com> <20120723004932.GB8040@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xufengzhang.main@gmail.com>, <vyasevich@gmail.com>,
	<sri@us.ibm.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120723004932.GB8040@neilslaptop.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/23/2012 08:49 AM, Neil Horman wrote:
>
> Not sure I understand how you came into this error.  If we get an invalid
> stream, we issue an SCTP_REPORT_TSN side effect, followed by an SCTP_CMD_REPLY
> which sends the error chunk.  The reply goes through
> sctp_outq_tail->sctp_outq_chunk->sctp_outq_transmit_chunk->sctp_outq_append_chunk.
> That last function checks to see if a sack is already part of the packet, and if
> there isn't one, appends one, using the updated tsn map.
Yes, you are right, but consider the invalid stream identifier's DATA 
chunk is the first
DATA chunk in the association which will need SACK immediately.
Here is what I thought of the scenario:
     sctp_sf_eat_data_6_2()
         -->sctp_eat_data()
             -->sctp_make_op_error()
             -->sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(err))
             -->sctp_outq_tail()          /* First enqueue ERROR chunk */
         -->sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, SCTP_FORCE())
             -->sctp_gen_sack()
                 -->sctp_make_sack()
                 -->sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, 
SCTP_CHUNK(sack))
                 -->sctp_outq_tail()          /* Then enqueue SACK chunk */

So SACK chunk is enqueued after ERROR chunk.
> So Can you explain in
> some more detail how you're getting into this situation?
>    
Actually it's triggered by a customer's test case, but we can also 
reproduce this problem
easily by explicitly contaminating the sctp stack:
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -701,7 +701,7 @@ struct sctp_chunk *sctp_make_datafrag_empty(struct 
sctp_association *asoc,
          * creating the chunk.
          */
         dp.tsn = 0;
-       dp.stream = htons(sinfo->sinfo_stream);
+       dp.stream = htons(sinfo->sinfo_stream) + 10;
         dp.ppid   = sinfo->sinfo_ppid;

         /* Set the flags for an unordered send.  */


Then run sctp_darn application and capture the sctp packet at the same time.



Thanks,
Xufeng Zhang
> Thanks!
> Neil
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>    
