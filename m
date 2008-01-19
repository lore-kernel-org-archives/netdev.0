From: David Miller <davem@davemloft.net>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Fri, 18 Jan 2008 20:37:23 -0800 (PST)
Message-ID: <20080118.203723.184002414.davem@davemloft.net>
References: <4790CDC8.6060000@hp.com>
	<20080118.153715.167557482.davem@davemloft.net>
	<47915DD4.7090109@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761167AbYASEhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 23:37:21 -0500
In-Reply-To: <47915DD4.7090109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 18 Jan 2008 21:17:56 -0500

> Hmm... in the code I am looking at, it's set in both zero and
> non-zero cases so it does solve the issue.
> 
> So does initializing it to NO_ERROR like you did.

Here is the code block in question in net-2.6.25:

	/* Verify the INIT chunk before processing it. */
	err_chunk = NULL;
	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
			      &err_chunk)) {
 ...
		if (err_chunk) {
 ...
			if (packet) {
				sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT,
						SCTP_PACKET(packet));
				SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
				error = SCTP_ERROR_INV_PARAM;
			} else {
				error = SCTP_ERROR_NO_RESOURCE;
			}
		}
 ...
		return sctp_stop_t1_and_abort(commands, error, ECONNREFUSED,
						asoc, chunk->transport);

If err_chunk == NULL at the "if (err_chunk)" test, error
will be left uninitialized, even after being moved as you
have suggested (right after the sctp_verify_init() call).

Thanks.
