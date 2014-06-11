From: Wayne Badger <badger@yahoo-inc.com>
Subject: Re: TCP_DEFER_ACCEPT wakes up without data
Date: Tue, 10 Jun 2014 19:57:51 -0500
Message-ID: <5397A98F.2030206@yahoo-inc.com>
References: <538FB666.9050303@yahoo-inc.com> <alpine.LFD.2.11.1406071441260.2287@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mrout2.yahoo.com ([216.145.54.172]:31990 "EHLO mrout2.yahoo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbaFKBJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 21:09:26 -0400
In-Reply-To: <alpine.LFD.2.11.1406071441260.2287@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/7/14, 10:41 AM, Julian Anastasov wrote:
>     Hello,
>
> On Wed, 4 Jun 2014, Wayne Badger wrote:
>
>> I would like to revisit the current state of TCP_DEFER_ACCEPT.  I know
>> that it has been discussed in the past and the discussion about 4.5
>> years ago led to commit d1b99ba41d6c5aa1ed2fc634323449dd656899e9 (tcp:
>> accept socket after TCP_DEFER_ACCEPT period) being introduced which
>> changed the semantics of TCP_DEFER_ACCEPT.
>
>     This discussion (http://marc.info/?t=125541062900001&r=1&w=2)
> has some hints about using TCP_SYNCNT.

Thanks for the pointer.  I have read through this discussion, but I
can't see how it helps with the current implementation.  TCP_SYNCNT
(or sysctl.tcp_synack_retries if TCP_SYNCNT is unused) allows you to
set the number of retries, but inet_csk_reqsk_queue_prune essentially
ignores the TCP_SYNCNT value if TCP_DEFER_ACCEPT is in use.

        if (queue->rskq_defer_accept)
            max_retries = queue->rskq_defer_accept;

>> A few questions.
>>
>> If the new behavior was desired at the time of the commit, why was the
>> existing TCP_DEFER_ACCEPT behavior changed instead of just adding a new
>> sockopt that implements the new behavior?  Why was the tcp(7) man page
>
>     May be because with help from TCP_SYNCNT we
> have more control.

I have so far been unable to obtain the behavior documented for
TCP_DEFER_ACCEPT, even with various settings of TCP_SYNCNT.  No setting
of TCP_SYNCNT can make it be used in the calculations in favor of the
TCP_DEFER_ACCEPT value.  No matter which value I choose for TCP_SYNCNT,
the connection is always promoted to a full socket and moved to the
accept queue.

Would you verify whether a server ever accepts the socket if data is
not sent?  I've been using v3.14.0 with default sysctl settings and a
TCP_DEFER_ACCEPT value of 30 and don't see that behavior.

>> not modified to describe the new behavior?
>
>> I propose the following patch to regain the tcp(7) semantics.  The patch
>> resolves dataless connections in one of two ways.  After the initial
>> timeout, a SYN-ACK is retransmitted and if a bare ACK is received, then
>> a RST is sent to the client and the connection is immediately dropped.
>> If nothing is received from the client, then the connection is silently
>> dropped after another rexmit timeout (the next one in the geometric
>> sequence).
>
>     After receiving the first bare ACK we do not
> retransmit SYN+ACKs, we send them after the period to
> trigger a new ACK[+DATA] that will lead to wakeup. You
> prefer if the next packet from client comes without DATA
> to send RST instead of more SYN+ACKs?

The SYN-ACK is sent after the timeout period and I do see the
kernel waiting for the appropriate timeout period based on the
TCP_DEFER_ACCEPT value.  This action, by itself, does not promote the
minisock to a full socket and wake up user space.  The subsequent
receipt of the duplicate bare ACK is what causes the kernel to promote
the minisock to a full socket, insert the full socket on the accept
queue and wake up user space.

The behavior that we want is for the receipt of the duplicate bare
ACK to not result in waking up user space.  The socket still hasn't
received any data, so there's no point in the process accepting the
socket since there's nothing the process can do.

As I mentioned above, I can't get the kernel to send more SYN-ACKs
because the minisock is promoted and the user process wakes up to
handle the accept.

Eventually, these connections will need to be removed.  Since we have
a connection that is in an ESTABLISHED connection (we got a SYN,
responded with SYN-ACK, and received a valid ACK), we shouldn't just
discard the minisock.  We can send a RST from just a minisock (note
that tcp_check_req already sends RSTs) and we choose to do that so at
least let the client knows that we're done.  Promoting the minisock to a
full socket just to send a FIN is just extra work.

I would prefer that we send a RST upon receipt of a bare ACK for a
socket that has completed the 3way handshake, waited the
TCP_DEFER_ACCEPT timeout and has never received any
data.  If it has timed out, then the server should be done with the
connection request.

>     The best place would be to send this reset in
> inet_csk_reqsk_queue_prune() after the /* Drop this request */
> comment if inet_rsk(req)->acked is set because we are not
> sure if our SYN+ACKs after the period will lead to new packets
> from client. But we have no skb to reply, not sure if
> the open request contains data to build a reset.

We could drop the connection in inet_csk_reqsk_queue_prune, but we have
to ensure that the receipt of the bare ACK response from the duplicate
SYN-ACK doesn't promote the socket as it is doing now.  We'll also have
to do something for syncookies because a valid bare ACK received for
a socket that doesn't even have a minisock should behave similarly.
The code to handle this can't go in inet_csk_reqsk_queue_prune because
there is no socket of any type to prune so we'll at least need to have the
code in two places but we could easily commonize it in a function.

Was it the intent with commit d1b99ba41d to change the semantics
of TCP_DEFER_ACCEPT such that sockets were always promoted to full
sockets and moved to the accept queue?  I want to make sure that we
are all on the same page with what the semantics mean because if we
have a disagreement there, then nothing else matters.  I'm just trying
to get a socket to stay in the kernel and not wake up the listener before
there is any data.

> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

Thanks,
Wayne
