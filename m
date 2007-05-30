From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH-2.4] Fix divide by 0 in vegas_cong_avoid()
Date: Wed, 30 May 2007 21:56:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705302100500.26408@kivilampi-30.cs.helsinki.fi>
References: <a5bf86a80705290218t5e8605d3m9750d9dae6d96112@mail.gmail.com>
 <20070529080534.5692bad8@freepuppy> <a5bf86a80705291123r7aa753besbcb1de3f13dc1b3c@mail.gmail.com>
 <20070529150216.712e422b@freepuppy> <Pine.LNX.4.64.0705301010300.25173@kivilampi-30.cs.helsinki.fi>
 <20070530093447.35300699@freepuppy>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1320221522-1180551047=:26408"
Cc: Lior Dotan <liodot@gmail.com>, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54754 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbXE3S4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 14:56:04 -0400
In-Reply-To: <20070530093447.35300699@freepuppy>
Content-ID: <Pine.LNX.4.64.0705302151070.26408@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1320221522-1180551047=:26408
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0705302151071.26408@kivilampi-30.cs.helsinki.fi>

On Wed, 30 May 2007, Stephen Hemminger wrote:

> On Wed, 30 May 2007 10:49:54 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > I think the code did a right thing before your api merge, since it called 
> > rtt callback only if FLAG_RETRANS_DATA_ACKED was not set (and pkts_acked 
> > always), i.e., when TCP cannot know if it was the rexmission that 
> > triggered the cumulative ACK or any original transmission, no new RTT 
> > measurement should be made. Consider also the fact that, there might be a 
> > non rexmitted skb after rexmitted one, which Lior's patch doesn't do 
> > right way at all since the FLAG_DATA_ACKED would again get set (no 
> > div-by-zero would have occured then but an unreliable timestamp would
> > have been givento vegas in 2.4).
> > 
> > The number of packets that got cumulatively acked is never a right metric 
> > to measure whether the cumulative ACK originated from rexmitted skbs or 
> > not. ...Perhaps the FLAG_RETRANS_DATA_ACKED flag needs to be passed 
> > somehow to cc modules?
> 
> What about the mixed case where some retransmitted data and new
> data was covered by one ack. 

Without timestamps TCP cannot do anything better than consider a
cumulative ACK that includes any ever retransmitted segment as
inaccurate timestamp. Like in tcp_ack_no_tstamp:

        if (flag & FLAG_RETRANS_DATA_ACKED)
                return;

...I think this same applies to cc modules as well. With timestamps 
things are another beast.

> I would rather keep the merge, but think about the cases more
> carefully.

IMHO there's no problem with keeping the merge, you just need to add 
another parameter to pkts_acked (or by some other means indicate it) to 
distinguish RTT measurement with accurate timestamp from inaccurate ones. 
Maybe the first step (to 2.6.22 to avoid new bugs etc.) should be just to 
give the flag (for some funny reason, it's called "acked" in 
tcp_clean_rtx_queue) or use a single arg with 0/1 value fo depending on 
FLAG_RETRANS_DATA_ACKED and check that in the merged pkts_acked in the 
cases that were using the old rtt callback. It would allow retaining the 
previous (correct) functionality as it was before the API merge. That 
would prevent potential regressions in cc modules due to this merge. 

...Then perhaps come up with a solution that takes advantage of timestamps 
more aggressively to 2.6.23 like the core rtt estimator already does. 


-- 
 i.
---696243703-1320221522-1180551047=:26408--
