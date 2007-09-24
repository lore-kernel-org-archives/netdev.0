From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6.24 0/5]: TCP sacktag cache usage recoded
Date: Mon, 24 Sep 2007 13:28:42 +0300
Message-ID: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	SANGTAE HA <sangtae.ha@gmail.com>,
	Tom Quetchenbach <virtualphtn@gmail.com>,
	Baruch Even <bar
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47089 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbXIXK2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 06:28:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After couple of wrong-wayed before/after()s and one infinite
loopy version, here's the current trial version of a sacktag  
cache usage recode....

Two first patches come from tcp-2.6 (rebased and rotated).
This series apply cleanly only on top of the other three patch
series I posted earlier today. The last debug patch provides
some statistics for those interested enough.

Dave, please DO NOT apply! ...Some thoughts could be nice
though :-).

It should improve processing of such likely events as cumulative
ACKs and new forward holed SACK considerably because full walk  
is not necessary anymore (old code could have been tweaked to   
cover them but it's better to drop each special case handling   
altogether and do a generic solution. Redundancy of fastpath    
hints and highest_sack stuff is also addressed, however, it     
might have slight effect as the hint could point to something   
less than highest_sack occassionally, whether that's significant
remains to see... In all cases except hint below highest_sack,  
the new solution should perform at least as well as the old code
(with a bit larger constant though, no additional cache misses  
though) because the SACK blocks old code choose not to process  
should all fall to LINUX_MIB_TCP_FULLSKIP category.

It's possible to improve it easily with RB-tree stuff though
this version is based on code using linked lists. I'm not yet
too sure that I got everything 100% correct as I "tweak"
start/end_seqs and exit skb loops a way that is prone to
off-by-one errors, could miss skb here and there. I'll probably
also recode dsack handling too to avoid recursion.

Stephen, Sangtae, others? experiencing those unexpected RTOs
during recovery of large windowed TCP, could you please give it
a try if it helps any...

--
 i.
   
ps. Our net-2.6.24 (and mainline?) DSACK processing code could
be broken btw. DSACK in the middle of other SACK block during
in-order walk seems to not be processed at all as the earlier
(sorted) block caused skb to advance past it already? (Just
occurred to me, I'll see what I can do to that if I've enough
time).


