From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/8] tipc: compensate for double accounting
 in socket rcv buffer
Date: Wed, 14 May 2014 04:47:01 -0700
Message-ID: <1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
	 <1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51378 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbaENLrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 07:47:03 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so1577906pab.6
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 04:47:02 -0700 (PDT)
In-Reply-To: <1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 05:39 -0400, Jon Maloy wrote:
> The function net/core/sock.c::__release_sock() runs a tight loop
> to move buffers from the socket backlog queue to the receive queue.
> 
> As a security measure, sk_backlog.len of the receiving socket
> is not set to zero until after the loop is finished, i.e., until
> the whole backlog queue has been transferred to the receive queue.
> During this transfer, the data that has already been moved is counted
> both in the backlog queue and the receive queue, hence giving an
> incorrect picture of the available queue space for new arriving buffers.
> 
> This leads to unnecessary rejection of buffers by sk_add_backlog(),
> which in TIPC leads to unnecessarily broken connections.
> 
> In this commit, we compensate for this double accounting by adding
> a counter that keeps track of it. The function socket.c::backlog_rcv()
> receives buffers one by one from __release_sock(), and adds them to the
> socket receive queue. If the transfer is successful, it increases a new
> atomic counter 'tipc_sock::dupl_rcvcnt' with 'truesize' of the
> transferred buffer. If a new buffer arrives during this transfer and
> finds the socket busy (owned), we attempt to add it to the backlog.
> However, when sk_add_backlog() is called, we adjust the 'limit'
> parameter with the value of the new counter, so that the risk of
> inadvertent rejection is eliminated.
> 
> It should be noted that this change does not invalidate the original
> purpose of zeroing 'sk_backlog.len' after the full transfer. We set an
> upper limit for dupl_rcvcnt, so that if a 'wild' sender (i.e., one that
> doesn't respect the send window) keeps pumping in buffers to
> sk_add_backlog(), he will eventually reach an upper limit,
> (2 x TIPC_CONN_OVERLOAD_LIMIT). After that, no messages can be added
> to the backlog, and the connection will be broken. Ordinary, well-
> behaved senders will never reach this buffer limit at all.

This looks very complicated and hides some underlying problem.

Why TCP has no problem, but TIPC has it ?

It seems you have too low sk_rcvbuf, or you advertise too big windows to
senders.

If backlog content is so big it eventually makes TIPC drops incoming
packets, then you have a scheduling issue, or unexpected bufferbloat.

Maybe TIPC holds socket lock too long in some place ?
