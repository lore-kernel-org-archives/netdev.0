From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 19:49:34 +0400
Message-ID: <20060719154934.GA29877@ms2.inr.ac.ru>
References: <44BD38B1.1080807@kom.aau.dk> <20060719132719.GA22143@ms2.inr.ac.ru> <44BE498F.9070001@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:12475 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030192AbWGSPt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 11:49:59 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
Content-Disposition: inline
In-Reply-To: <44BE498F.9070001@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HellO!

> IsLost (SeqNum):
>      This routine returns whether the given sequence number is
>      considered to be lost.  The routine returns true when either
>      DupThresh discontiguous SACKed sequences have arrived above
>      'SeqNum' or (DupThresh * SMSS) bytes with sequence numbers greater
>      than 'SeqNum' have been SACKed.  Otherwise, the routine returns
>      false.

It is not used. The metric is just distance between snd.una and
the most forward sack.

It can be changed, but, to be honest, counting "discontiguous SACked sequences"
looks really weird and totally unjustified.

You can look for function tcp_time_to_recover() and replace
tcp_fackets_out(tp) > tp->reordering with something like
tp->sacked_out+1 > tp->reordering. It is not so weird as rfc
recommends, but it should make some difference.


> so you are saying, it doesnt matter whether I disable FACK or not, it is 
> basically set by default?

Condition triggering start of fast retransmit is the same.
The behaviour while retransmit is different. FACKless code
behaves more like NewReno.


> and it is disabled only when reordering is detected (and this is done 
> either through timestamps or DSACK, right?)...
> so if neither DSACK and timestamps are enabled we are unable to detect 
> disorder, so basically there should be no difference between SACK and 
> FACK, cause it is always FACK used... and that seems to make sense  from 
> the results I have 

Yes. But FACKless tcp still retransmits less aggressively.


> the # of retransmissions increases as shown in the second figure? isnt 
> that odd? shouldnt it be the other way around?

The most odd is that I see no correlation between #of retransmits
and download time in you graphs. Actually, the correlation is negative. :-)


> Also why does the # retransmissions in the timestamp case increases when 
> we use SACK/FACK as compared with no SACK case?

Excessive retransmissions still happen. Undoing just restores cwnd
and tries to increase reordering metric to avoid false retransmits.


> This one , I dont think I understood you. Could you please make it a bit 
> more clearer?

1. Suppose, some segments, but not all, were delayed.
2. Senders sees dupack with a SACK. It is the first, SACK allows to open
   window for one segment, you send one segment with snd.nxt.
3. Receivers receives it before delayed segments arrived.
4. When senders sees this SACK, it assumes that all the delayed
   segments are lost.


> OK ...but if timestamps are enabled, then I just couldnt figure out the 
> use of  DSACK, can it tell us something more than we can find using 
> timestamps??

It depends. Normally, no. If the network is fast, timestamps are just
too coarse to detect redundant retransmissions.

Plus, the heuristcs based on timestamps essentially relies on a bug
in our timestamps processing code. Another side could have it fixed. :-)

Alexey
