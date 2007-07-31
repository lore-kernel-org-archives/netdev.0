From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 1/2] [TCP]: Fix ratehalving with bidirectional
 flows
Date: Tue, 31 Jul 2007 18:59:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707311817370.15687@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0707310751260.15079@kivilampi-30.cs.helsinki.fi>
 <20070730.222112.41634340.davem@davemloft.net> <20070731105113.4730d9bb@oldman.hamilton.local>
 <20070731.025827.07638506.davem@davemloft.net> <20070731143726.3fecfe86@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48191 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762368AbXGaP7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 11:59:08 -0400
In-Reply-To: <20070731143726.3fecfe86@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jul 2007, Stephen Hemminger wrote:

> I noticed no difference in the two flow tests.  That is not a bad thing, just
> that this test doesn't hit that code.

...I'm not too sure about your test setup but the bugs I fixed only cover 
cases that occur if flow is bidirectional (and obviously active in both 
directions at the same time), they won't occur in a case of unidirectional 
transfer or in request-reply style connections (well, in the latter 
case if there's some overlap, it can have effect but that's usually 
not significant)...

In case of bidirectional transfers, you *should* see some difference as 
previously the fast recovery was _very_ broken. Of course there could be 
other issue with large cwnd TCP that hides it by going to RTO still, but 
at least over 384k/200ms link (DBP sized buffers, IIRC), these change
behavior very dramatically, mainly in the initial slow-start overshoot 
recovery because in there losses per RTT is so high number compared to 
what is experienced later on. One or a few losses are usually recovered 
without RTO when congestion happens later on.

> The anomaly is that first flow does slow start then gets loss and ends up
> reducing it's window size all the way to the bottom, finally it recovers.
> This happens with Cubic, H-TCP and others as well; if the queue in the
> network is large enough, they don't handle the initial loss well.

...TCP related stuff that changed in /proc/net/netstat might shed 
some light to this if none of the given explinations please you... :-)

> See the graph.

What exactly do you mean by "RENO" in the title, I mean what's tcp_sack 
set to? There is occassionally a bit confusion in that respect in the 
terminology @ netdev, I've used to reno refering to non-SACK stuff 
elsewhere but in here that's not always the case... Usually it's possible 
to derive the correct interpretation from the context, but in this case 
I'm not too sure... :-)

What I often have often seen with non-SACK TCP is that initial slow-start 
exhausts even very large advertised window on high DBP link and then due 
to draining of ACK feedback, gets RTOed... That usually shows up as long 
lasting recovery where one segment per RTT is recovered and new data is 
being sent as duplicate ACKs arrive with nearly constant rate until the 
window limit is hit (but I cannot see such periond in the graph you 
posted, so I guess it's not the explanation in this case). And if your 
"RENO" refers to something with SACK, that's not going to explain it 
anyway.

...Another nasty one I know is RED+ECN, though I'd say it's a bit far 
fetched one, as ECN cannot be used nicely in retransmission, 
a retransmission gets dropped instead of marking if RED wanted to mark.
I guess that doesn't occur in your test case either?


-- 
 i.
