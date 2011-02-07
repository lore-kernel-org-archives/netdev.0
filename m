From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Tue, 8 Feb 2011 01:36:28 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1102080112450.29228@melkinpaasi.cs.helsinki.fi>
References: <1297119424-19956-1-git-send-email-ycheng@google.com> <20110207.150522.28821840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49613 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210Ab1BGXga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 18:36:30 -0500
In-Reply-To: <20110207.150522.28821840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Feb 2011, David Miller wrote:

> From: Yuchung Cheng <ycheng@google.com>
> Date: Mon,  7 Feb 2011 14:57:04 -0800
> 
> > Fix a bug that undo_retrans is incorrectly decremented when undo_marker is
> > not set or undo_retrans is already 0. This happens when sender receives
> > more DSACK ACKs than packets retransmitted during the current
> > undo phase. This may also happen when sender receives DSACK after
> > the undo operation is completed or cancelled.
> > 
> > Fix another bug that undo_retrans is incorrectly incremented when
> > sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). This case
> > is rare but not impossible.
> > 
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Looks good, Ilpo could you please review this real quick?

I already too a quick look so you're real lucky, only delay of writing is 
needed... :-)

Neither is harmful to "fix" but I think they're partially also checking 
for things which shouldn't cause problems... E.g., undo_retrans is only 
used after checking undo_marker's validity first so I don't think 
undo_marker check is exactly necessary there (but on the other hand it 
does no harm)... 

The tcp_retransmit_skb problem I don't understand at all as we should be 
fragmenting or resetting pcount to 1 (the latter is true only if all 
bugfixes were included to the kernel where >1 pcount for a rexmitted skb 
was seen). If pcount is indeed >1 we might have other issues too somewhere 
but I fail to remember immediately what they would be. That change is not 
bad though since using +/-1 is something we should be getting rid of 
anyway and on long term it would be nice to make tcp_retransmit_skb to be 
able to take advantage of TSO anyway whenever possible.

I also noticed that the undo_retrans code in sacktag side is still doing 
undo_retrans-- ops which could certainly cause real miscounts, though 
it is extremely unlikely due to the fact that DSACK should be sent 
immediately for a single segment at a time (so the sender would need to 
split+recollapse in between).

-- 
 i.
