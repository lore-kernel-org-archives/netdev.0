From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Wed, 5 Dec 2007 14:17:40 +0300
Message-ID: <20071205111740.GA4024@ms2.inr.ac.ru>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi> <47559FA1.2090104@psc.edu> <Pine.LNX.4.64.0712042252450.12072@kivilampi-30.cs.helsinki.fi> <4755C3E9.4090609@psc.edu> <Pine.LNX.4.64.0712042319160.12072@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Matt Mathis <mathis@psc.edu>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:49773 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750993AbXLELSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 06:18:10 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712042319160.12072@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> My theory is that it could relate to tcp_cwnd_restart and 
> tcp_cwnd_application_limited using it and the others are just then 
> accidently changed as well. Perhaps I'll have to dig once again to 
> changelog history to see if there's some clue (unless Alexey shed 
> some light to this)...

Yes, it is RFC2861. There is some rationale in preamble to section 3.
But even for this case it can be set to full cwnd instead.

Also, I used it to calculate prior_ssthresh to restore ssthresh
in the case when we detect false retransmission. It is not an accident.
I really mean that tcp_current_sshresh() is correct estimate
for "current ssthresh" and this should be the same as in restart
situation. Of course, rationale of RFC2861 does not apply
to this case _directly_. But it was at the end of chain of syllogisms.

Look:

If we have not infinite ssthresh and cwnd > ssthresh, we are already
in congestion avoidance mode and we can set prior_ssthresh to any value
in the range ssthresh...cwnd without significant changes in behaviour
wrt congestion avoidance.

ssthresh would be an obvious underestimate.

cwnd can be an overestimate, because the path is surely congested
(cwnd > ssthresh) and cwnd is not a measure of current capacity.

Behavioral changes happen, when final cwnd is too low, because pipe
was drained during recovery. We allow to slow start to sshresh,
but value of ssthresh should be the same as we use for restart case.

Alexey
