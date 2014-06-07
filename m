From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT wakes up without data
Date: Sat, 7 Jun 2014 18:41:45 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1406071441260.2287@ja.home.ssi.bg>
References: <538FB666.9050303@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Wayne Badger <badger@yahoo-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35059 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752947AbaFGPl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2014 11:41:57 -0400
In-Reply-To: <538FB666.9050303@yahoo-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 4 Jun 2014, Wayne Badger wrote:

> I would like to revisit the current state of TCP_DEFER_ACCEPT.  I know
> that it has been discussed in the past and the discussion about 4.5
> years ago led to commit d1b99ba41d6c5aa1ed2fc634323449dd656899e9 (tcp:
> accept socket after TCP_DEFER_ACCEPT period) being introduced which
> changed the semantics of TCP_DEFER_ACCEPT.

	This discussion (http://marc.info/?t=125541062900001&r=1&w=2)
has some hints about using TCP_SYNCNT.

> A few questions.
> 
> If the new behavior was desired at the time of the commit, why was the
> existing TCP_DEFER_ACCEPT behavior changed instead of just adding a new
> sockopt that implements the new behavior?  Why was the tcp(7) man page

	May be because with help from TCP_SYNCNT we
have more control.

> not modified to describe the new behavior?

> I propose the following patch to regain the tcp(7) semantics.  The patch
> resolves dataless connections in one of two ways.  After the initial
> timeout, a SYN-ACK is retransmitted and if a bare ACK is received, then
> a RST is sent to the client and the connection is immediately dropped.
> If nothing is received from the client, then the connection is silently
> dropped after another rexmit timeout (the next one in the geometric
> sequence).

	After receiving the first bare ACK we do not
retransmit SYN+ACKs, we send them after the period to
trigger a new ACK[+DATA] that will lead to wakeup. You
prefer if the next packet from client comes without DATA
to send RST instead of more SYN+ACKs?

	The best place would be to send this reset in 
inet_csk_reqsk_queue_prune() after the /* Drop this request */
comment if inet_rsk(req)->acked is set because we are not
sure if our SYN+ACKs after the period will lead to new packets
from client. But we have no skb to reply, not sure if
the open request contains data to build a reset.

Regards

--
Julian Anastasov <ja@ssi.bg>
