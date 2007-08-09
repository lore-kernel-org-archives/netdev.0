From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: net-2.6.24 GIT state
Date: Thu, 9 Aug 2007 12:50:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708091233050.24369@kivilampi-30.cs.helsinki.fi>
References: <20070809.022823.31781972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39936 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763083AbXHIJuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 05:50:54 -0400
In-Reply-To: <20070809.022823.31781972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Aug 2007, David Miller wrote:

> Ok, as is clear for some the net-2.6.24 tree has been cut
> and is at:
> 
> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.24.git
> 
> I'll be going over the TCP bits Ilpo and I have been discussing

...In case I didn't make it clear previously, you'll notice that there are 
some non-submitted changes rebased as well on the top of it.

> then expect me to disappear back to driver hacking :-)  As is,
> there should be enough in there for people to play with,
> regression test, and improve.

At least these are trivial to take (after rebase, some come nicely even 
from the before tree):

40564051bdb237231e625ba674fdedf6e8373027 [TCP]: Remove num_acked>0 checks from cong.ctrl mods pkts_acked
4c035cd78a6b60710b0dda4f62339df070f761c8 [TCP]: Add tcp_dec_pcount_approx int variant
ed2753b0b463df41c10121ce494d51428047fcbc [TCP]: Move code from tcp_ecn.h to tcp*.c and tcp.h & remove it
c215314c6ea0261865d3df09f375016f3dcadeba [TCP]: Access to highest_sack obsoletes forward_cnt_hint
9e5f432fb247af2f0062c3c57d7f45d511692f26 [TCP] FRTO: remove unnecessary fackets/sacked_out recounting
96001b306c60cb969d456ac70e376220db97e54a [TCP]: Move Reno SACKed_out counter functions earlier
318cf753170367504cfac07ac89e97befb1ca501 [TCP]: Extract DSACK detection code from tcp_sacktag_write_queue().
a2539974b098065ebe02ad11a6411df4f56ba0ed [TCP]: Rexmit hint must be cleared instead of setting it
  - Could be combined with the extrator as it's really a bug fix, once 
    rxmit cnt hint gets dropped, we can add this back as optimization :-).
2fea67411f0c89642fa4abc0490b65c7852a1202 [TCP]: Extracted rexmit hint clearing from the LOST marking code
1fba6548b2ecc2d513981898247472d1183329c5 [TCP]: Add highest_sack seqno, points to globally highest SACK

...I was claiming incorrectly last time that highest_sack stuff needs 
SACK-block validation, it does not as it takes seq from skb->seq, not from 
the receiver like I thought :-). ...Redoing the validator (the improved 
version) on top of net-2.6.24 is on my "high priority list" though, so 
maybe I'll have it already on today.

Left_out removal should be safe too: after my analysis, it seems safe as 
most of the functions are if-modified-then-sync type, some sync always. 
Clean_rtx_queue leaves left_out to old state which is the hardest thing to 
track. However, TCP should always execute fastretrans_alert (that syncs 
near entry) if sacked_out+lost_out is (or was) non-zero, so it shouldn't 
leak stale state anywhere. Not going to fastretrans_alert would be IMHO a 
bug that should be fixed. I found one such case which is fixed in [TCP]: 
Keep state in Disorder also if only lost_out > 0). Also FRTO that is 
called before fastretrans_alert sync at entry, so it shouldn't be a 
problem to it either. 

...Taking IsReno/IsFack removal is probably going to be hardest one, as it 
will conflict a lot. ...Maybe some sed work in patches would reduce # of 
conflicts instead of trying cherry-pick+rebase.

-- 
 i.
