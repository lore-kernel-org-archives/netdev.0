From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: about Linux adaptivly adjusting dupthresh
Date: Thu, 28 Aug 2008 21:53:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808282135350.7618@wrl-59.cs.helsinki.fi>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net> <000001c90852$a1c19a50$a05ee183@D2GT6T71>
 <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
 <fb62ce3717a7.48b5b0a8@fnal.gov> <Pine.LNX.4.64.0808280928450.5170@wrl-59.cs.helsinki.fi>
 <001101c90919$313d67b0$a05ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'David Miller' <davem@davemloft.net>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52208 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785AbYH1SxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 14:53:12 -0400
In-Reply-To: <001101c90919$313d67b0$a05ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Aug 2008, Wenji Wu wrote:

> Sorry, I made a mistake in the last post, what I mean is "algorithms
> adaptively adjust TCP reordering threshold dupthresh". 

Ah, that makes much more sense. :-)

> I understand that "Eifel algorithm" or "DSACK TCP" will adaptively adjust
> dupthresh to deal with packet reordering. Are there any other
> reordering-tolerant algorithms implemented in Linux? 

First about adaptive dupthresh:

In addition to DSACK, we use never-retransmitted block's cumulative ACKs 
to increase the dupthresh (see tcp_clean_rtx_queue). Then there's some 
newreno thing when dupacks > packets_out but I've never really figured it 
fully out if that's doing the correct thing when doing + tp->packets_out 
besides the most simple case (see tcp_check_reno_reordering).

I don't think that eifel adjusts dupthresh though it can remove ambiguity 
problem and thus we can use the never-retransmitted block acked detection 
more often.

Also, there's some added logic for small-windowed case to reduce dupthresh 
temporarily (at the smallest to 3 or whatever the default is) if window is 
not large enough to generate the incremented (see tcp_time_to_recover).


Again, I'm not too sure what you mean by "reordering tolerant", but here 
are some things that may be related:

FACK -> RFC3517 auto-fallback if reordering is detected (basically holes 
are only counted with FACK in the more-than-dupthresh check).

I guess Eifel like timestamp checking belongs to this category (in 
tcp_try_undo_partial).

If latency spike + reordering occurs, SACK FRTO might help but I think
it depends on scenario.

-- 
 i.
