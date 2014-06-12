From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT wakes up without data
Date: Thu, 12 Jun 2014 09:00:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1406120641490.1769@ja.home.ssi.bg>
References: <538FB666.9050303@yahoo-inc.com> <alpine.LFD.2.11.1406071441260.2287@ja.home.ssi.bg> <5397A98F.2030206@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Wayne Badger <badger@yahoo-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33179 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751134AbaFLGAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 02:00:24 -0400
In-Reply-To: <5397A98F.2030206@yahoo-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 10 Jun 2014, Wayne Badger wrote:

> On 6/7/14, 10:41 AM, Julian Anastasov wrote:
> >
> >     This discussion (http://marc.info/?t=125541062900001&r=1&w=2)
> > has some hints about using TCP_SYNCNT.
> 
> Thanks for the pointer.  I have read through this discussion, but I
> can't see how it helps with the current implementation.  TCP_SYNCNT
> (or sysctl.tcp_synack_retries if TCP_SYNCNT is unused) allows you to
> set the number of retries, but inet_csk_reqsk_queue_prune essentially
> ignores the TCP_SYNCNT value if TCP_DEFER_ACCEPT is in use.
> 
>         if (queue->rskq_defer_accept)
>             max_retries = queue->rskq_defer_accept;

	You are right, I missed that. So, we send just
one SYN+ACK when period is about to expire.

> I have so far been unable to obtain the behavior documented for
> TCP_DEFER_ACCEPT, even with various settings of TCP_SYNCNT.  No setting
> of TCP_SYNCNT can make it be used in the calculations in favor of the
> TCP_DEFER_ACCEPT value.  No matter which value I choose for TCP_SYNCNT,
> the connection is always promoted to a full socket and moved to the
> accept queue.
> 
> Would you verify whether a server ever accepts the socket if data is
> not sent?  I've been using v3.14.0 with default sysctl settings and a
> TCP_DEFER_ACCEPT value of 30 and don't see that behavior.

	syn_ack_recalc() schedules SYN+ACK, so under
normal conditions, it triggers ACK from client and
child is created, even without DATA. Request will
expire only when last SYN+ACK or the following ACK
is lost (or not sent).

> The behavior that we want is for the receipt of the duplicate bare
> ACK to not result in waking up user space.  The socket still hasn't
> received any data, so there's no point in the process accepting the
> socket since there's nothing the process can do.

	One problem with this behavior is that after first ACK
more ACKs are not expected. Your RST logic still relies on the
last SYN+ACK we sent to trigger additional ACK. I guess,
we can live with this because for firewalls it is not worse
than current behavior. We replace accept() with RST.

> I would prefer that we send a RST upon receipt of a bare ACK for a
> socket that has completed the 3way handshake, waited the
> TCP_DEFER_ACCEPT timeout and has never received any
> data.  If it has timed out, then the server should be done with the
> connection request.

	I'm ok with this idea.

> >     The best place would be to send this reset in
> > inet_csk_reqsk_queue_prune() after the /* Drop this request */
> > comment if inet_rsk(req)->acked is set because we are not
> > sure if our SYN+ACKs after the period will lead to new packets
> > from client. But we have no skb to reply, not sure if
> > the open request contains data to build a reset.
> 
> We could drop the connection in inet_csk_reqsk_queue_prune, but we have
> to ensure that the receipt of the bare ACK response from the duplicate
> SYN-ACK doesn't promote the socket as it is doing now.  We'll also have

	Agreed. I'm just not sure for the implementation
needed for inet_csk_reqsk_queue_prune. TCP experts
can help here.

> to do something for syncookies because a valid bare ACK received for
> a socket that doesn't even have a minisock should behave similarly.
> The code to handle this can't go in inet_csk_reqsk_queue_prune because
> there is no socket of any type to prune so we'll at least need to have the
> code in two places but we could easily commonize it in a function.

	I don't know the syn-cookie code. Even now
inet_csk_reqsk_queue_prune() expires acked requests,
isn't inet_csk_reqsk_queue_drop sufficient?

> Was it the intent with commit d1b99ba41d to change the semantics
> of TCP_DEFER_ACCEPT such that sockets were always promoted to full
> sockets and moved to the accept queue?  I want to make sure that we
> are all on the same page with what the semantics mean because if we
> have a disagreement there, then nothing else matters.  I'm just trying
> to get a socket to stay in the kernel and not wake up the listener before
> there is any data.

	IIRC, the main idea is to remove connection from
firewalls, the idea with triggered ACK was the easiest
solution.

Regards

--
Julian Anastasov <ja@ssi.bg>
