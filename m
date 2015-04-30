From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net/rds: fix unaligned memory access
Date: Thu, 30 Apr 2015 15:23:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB289BF@AcuExch.aculab.com>
References: <1430404073-16879-1-git-send-email-david.ahern@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: shamir rabinovitch <shamir.rabinovitch@oracle.com>
To: 'David Ahern' <david.ahern@oracle.com>,
	"rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.190]:62235 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbbD3PZd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 11:25:33 -0400
In-Reply-To: <1430404073-16879-1-git-send-email-david.ahern@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern
> Sent: 30 April 2015 15:28
> rdma_conn_param private data is copied using memcpy after headers such
> as cma_hdr (see cma_resolve_ib_udp as example). so the start of the
> private data is aligned to the end of the structure that come before. if
> this structure end with u32 the meaning is that the start of the private
> data will be 4 bytes aligned. structures that use u8/u16/u32/u64 are
> naturally aligned but in case the structure start is not 8 bytes aligned,
> all u64 members of this structure will not be aligned. to solve this issue
> we must use special macros that allow unaligned access to those
> unaligned members.
> 
> Addresses the following kernel log seen when attempting to use RDMA:
> 
> Kernel unaligned access at TPC[10507a88] rds_ib_cm_connect_complete+0x1bc/0x1e0 [rds_rdma]
...
> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index 31b74f5..e0bbbac 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -183,8 +183,17 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
> 
>  	/* If the peer gave us the last packet it saw, process this as if
>  	 * we had received a regular ACK. */
> -	if (dp && dp->dp_ack_seq)
> -		rds_send_drop_acked(conn, be64_to_cpu(dp->dp_ack_seq), NULL);

Or just mark 'dp_ack_seq' with __attribute((aligned(4))).
Then the compiler will generate two 32bit loads.
(provided be64_to_cpu() doesn't do anything stupid.)

	David
