From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next 11/13] kcm: Add memory limit for receive
 message construction
Date: Mon, 7 Mar 2016 20:28:01 -0500
Message-ID: <20160308012726.GA10335@oracle.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
 <1457388672-2600559-12-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49756 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbcCHB2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 20:28:15 -0500
Content-Disposition: inline
In-Reply-To: <1457388672-2600559-12-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/07/16 14:11), Tom Herbert wrote:
> 
> Message assembly is performed on the TCP socket. This is logically
> equivalent of an application that performs a peek on the socket to find
> out how much memory is needed for a receive buffer. The receive socket
> buffer also provides the maximum message size which is checked.
> 
> The receive algorithm is something like:
> 
>    1) Receive the first skbuf for a message (or skbufs if multiple are
>       needed to determine message length).
>    2) Check the message length against the number of bytes in the TCP
>       receive queue (tcp_inq()).
> 	- If all the bytes of the message are in the queue (incluing the
> 	  skbuf received), then proceed with message assembly (it should
> 	  complete with the tcp_read_sock)
>         - Else, mark the psock with the number of bytes needed to
> 	  complete the message.
>    3) In TCP data ready function, if the psock indicates that we are
>       waiting for the rest of the bytes of a messages, check the number
>       of queued bytes against that.
>         - If there are still not enough bytes for the message, just
> 	  return
>         - Else, clear the waiting bytes and proceed to receive the
> 	  skbufs.  The message should now be received in one
> 	  tcp_read_sock

AIUI, the above logic will make sure that ->sk_data_ready reads the entire
message in one shot.  For "very large" messages, TCP's windowing logic
will eventually kick in, and the sender (all threads in the sender
that share the single tcp socket)  will be throttled, correct?  

I suppose that (all sender threads being blocked behind one "too large"
message) may not an unreasonable constraint, but is it possible to end up
with a deadlocked TCP (recv) socket- one for which the receiver 
closed the window (so sender TCP cannot send the remaining
bytes of the kcm message), but cannot be drained because of #3 above?

BTW there are a couple of typos above;
s/skbuf/skbuff
s/incluing/including

--Sowmini
