From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] GENETLINK: Global lock refined to family granularity
Date: Mon, 31 Mar 2008 14:26:48 +0200
Message-ID: <20080331122648.GA20815@postel.suug.ch>
References: <47EB8D8D.8020506@st.com> <20080331103350.GZ20815@postel.suug.ch> <47F0C942.9070603@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52433 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670AbYCaM02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 08:26:28 -0400
Content-Disposition: inline
In-Reply-To: <47F0C942.9070603@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Richard MUSIL <richard.musil@st.com> 2008-03-31 13:21
> It takes two locks, instead of one. I do not see, how it could be less
> (in terms of synchronization primitives - but not necessarily mutexes)
> if I want that level of granularity. Might be more efficient with RCU
> lists (but I do not know), but complexity remains the same.

The synchronization mutex in genl_recv() remains and you add an
additional global mutex genl_fam_lock and a per family lock. That's
2 vs 6 lock operations. It is possible to use RCU to manage the
family, ops and groups list and make the processing path lockless.
All you have to do is synchronize the family unregister function to
message processing as dumping can't disable preempt. Given this, your
patch would be a lot more acceptable to me as the biggest cost would
be reduced and the cost vs gain ratio would be a lot better.

> In that case, nothing can be done. Of course, trying to unregister
> family form its own handler could lead to either crash or deadlock. The
> point was, it would not deadlock when manipulating other family - which
> happens with current implementation.
> Also, it would allow processing of different messages in parallel as
> long as they are belonging to different families. Right now, the
> processing is blocked as long as any single message is processed.

The old behaviour is well defined and obvious. If you allow manipulation
during message processing then allow it for all objects not just some.

I'm all for parallel processing. It has been requested for some time now
by various people but so far nobody got around implementing it. It would
be a very legitimate reason to complicate locking and would even be
worth some additional locking costs. I'm all for this.

> I am not convinced about that. Does it mean you suggest that any
> genetlink message handler should by default offload processing to
> workqueue, so it won't block any other message processing from any other
> family?

I meant deferring the registration of operations to after message
processing using workqueues. Much like it is done for many other things
which can't be done in current locking context.

> You right it does not. Should I look into it, or was your answer
> definitive no?

I'm not against the idea, I just feel that the gains in your patch in
its current form do not justify the additional locking and complextity
costs. Combined with parallel processing and RCU lists it would be a
no brainer and probably merged instantly.
