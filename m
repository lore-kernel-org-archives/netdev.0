From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 8/9] [TCP]: Reduce sacked_out with reno when purging
 write_queue
Date: Tue, 3 Jul 2007 14:08:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707031353480.14307@kivilampi-30.cs.helsinki.fi>
References: <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1180168562524-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070702.220009.128111387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-685715096-1183460898=:14307"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35599 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770AbXGCLIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 07:08:19 -0400
In-Reply-To: <20070702.220009.128111387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-685715096-1183460898=:14307
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 2 Jul 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 26 May 2007 11:36:01 +0300
> 
> > Previously TCP had a transitional state during which reno
> > counted segments that are already below the current window into
> > sacked_out, which is now prevented. Re-try now unconditional
> > S+L catching (I wonder if we could get that BUG_ON place
> > pinpointed more exactly in oops because now inlining makes it
> > lose its original context as they always seem to be in
> > tcp_ack, #define helps?).
> > 
> > Beware, this change is not a trivial one and might have some
> > unexpected side-effects under obscure conditions since state
> > tracking is to happen much later on and the reno sack counting
> > was highly depending on the current state.
> > 
> > This approach conservatively calls just remove_sack and leaves
> > reset_sack() calls alone. The best solution to the whole problem
> > would be to first calculate the new sacked_out fully (this patch
> > does not move reno_sack_reset calls from original sites and thus
> > does not implement this). However, that would require very
> > invasive change to fastretrans_alert (perhaps even slicing it to
> > two halves). Alternatively, all callers of tcp_packets_in_flight
> > (i.e., users that depend on sacked_out) should be postponed
> > until the new sacked_out has been calculated but it isn't any
> > simpler alternative.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> So basically the idea behind this patch is to do the update of
> the fake RENO sakcs in clean_rtx_queue instead of fixing it up
> at the very last moment right before we invoke tcp_try_to_undo_partial().

Yeap, it would change sacked_out that things are seeing before 
undo_partial point (if there would be some) but it would qualify IMHO 
as fix for those case too rather than bug. I checked that F-RTO (with 
reno) cannot ever access stale sacked_out because of other constraints 
based on ACK's snd_una, and that's pretty much what's being done between 
there.

TCP might still do another update later on by using tcp_reset_reno_sack, 
but that's always going to more aggressive update (or at least an equal 
one).

> I like this patch and I can't find any holes in the idea.
> 
> But some things have changed in the meantime and this patch
> (and probably 9/9 too) don't apply cleanly.  Could you respin
> these against current tcp-2.6 so I can apply them?

I knew that :-), it was postponed due to other, more important issues and 
because the trees then got some depencies at that point I decided it's 
better to wait for a while until tcp-2.6 gets all stuff that's to be in 
net-2.6... But now that things seem to have settled, I'll provide the 
updated one later on. The 9/9 should be dropped, I've noticed a cpu 
processing vulnerability in it which I previously didn't see there (I 
describe it in my other post).


-- 
 i.
---696243703-685715096-1183460898=:14307--
