From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Date: Mon, 3 Dec 2007 15:44:05 +0000
Message-ID: <20071203154405.GA2914@gerrit.erg.abdn.ac.uk>
References: <1196631416-17778-1-git-send-email-acme@redhat.com> <20071203083512.GA5484@gerrit.erg.abdn.ac.uk> <20071203124412.GC15034@ghostprotocols.net> <20071203134947.GD18547@gerrit.erg.abdn.ac.uk> <20071203145443.GE15034@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	dccp@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41689 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750776AbXLCPpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 10:45:17 -0500
Content-Disposition: inline
In-Reply-To: <20071203145443.GE15034@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > | > 	static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
| > | > 	{
| > | > 		if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
| > | > 			hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
| > | > 	}
| > | 
| > | 	And we also just do test for len > 0 in update_s, that looks like
| > | also excessive, no?
| > Hm, I think we need to make it robust against API bugs and/or zero-sized
| > data packets. The check `len > 0' may seem redundant but it catches such
| > a condition. For a moving average an accidental zero value will have
| > quite an impact on the overall value. In CCID3 it is
| > 
| >   	x_new = 0.9 * x_old + 0.1 * len
| > 
| > So if len is accidentally 0 where it should not be, then each time the
| > moving average is reduced to 90%.
| 
| So we must make it a BUG_ON, not something that is to be always present.
|  
I think it should be a warning condition since it can be triggered when
the remote party sends zero-sized packets. It may be good to log this
into the syslog to warn about possibly misbehaving apps/peers/remote
stacks.


| > As a comparison - the entire patch set took about a full month to do.
| > But that meant I am reasonably sure the algorithm is sound and can cope
| > with problematic conditions.
| 
| And from what I saw so far that is my impression too, if you look at
| what I'm doing it is:
| 
| 1. go thru the whole patch trying to understand hunk by hunk
You are doing a great job - in particular as it really is a lot of material.

| 2. do consistency changes (add namespace prefixes)
| 3. reorganize the code to look more like what is already there, we
|    both have different backgrounds and tastes about how code should
|    be written, so its only normal that if we want to keep the code
|    consistent, and I want that, I jump into things I think should be
|    "reworded", while trying to keep the algorithm expressed by you.
|
Agree, that is not always easy to get right. I try to stick as close as
possible to existing conventions but of course that is my
interpretation, so I am already anticipating such changes/comments here.

| think about further automatization on regression testing.
| 
If it is of any use, some scripts and setups are at the bottom of the page at
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/
