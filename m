From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 17:02:39 +0200
Message-ID: <44BE498F.9070001@kom.aau.dk>
References: <44BD38B1.1080807@kom.aau.dk> <20060719132719.GA22143@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:10979 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S964860AbWGSPDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 11:03:08 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060719132719.GA22143@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi ,

Alexey Kuznetsov wrote:

>Hello!
>
>  
>
>>DSACK)  is used, the retransmissions seem to happen earlier .
>>    
>>
>
>Yes. With SACK/FACK retransmissions can be triggered earlier,
>if an ACK SACKs a segment which is far enough from current snd.una.
>That's what happens f.e. in T_SACK_dump5.dat
>
>01:28:15.681050 < 192.38.55.34.51137 > 192.168.110.111.42238: P 18825:20273[31857](1448) ack 1/5841 win 5840/0 <nop,nop,timestamp 418948058 469778216> [|] (DF)(ttl 64, id 19165)
>01:28:15.800946 < 192.168.110.111.42238 > 192.38.55.34.51137: . 1:1[5841](0) ack 8689/31857 win 23168/0 <nop,nop,timestamp 469778229 418948031,nop,nop, sack 1 {10137:11585} > (DF) [tos 0x8]  (ttl 62, id 45508)
>01:28:15.860773 < 192.168.110.111.42238 > 192.38.55.34.51137: . 1:1[5841](0) ack 8689/31857 win 23168/0 <nop,nop,timestamp 469778235 418948031,nop,nop, sack 2 {13033:14481}{10137:11585} > (DF) [tos 0x8]  (ttl 62, id 45509)
>01:28:15.860781 < 192.38.55.34.51137 > 192.168.110.111.42238: . 8689:10137[31857](1448) ack 1/5841 win 5840/0 <nop,nop,timestamp 418948076 469778235> [|] (DF) (ttl 64, id 19166)
>
>The second sack confirms that 13033..14481 already arrived.
>
>And this is even not a mistake, the third dupack arrived immediately:
>01:28:15.901382 < 192.168.110.111.42238 > 192.38.55.34.51137: . 1:1[5841](0) ack 8689/31857 win 23168/0 <nop,nop,timestamp 469778238 418948031,nop,nop, sack 2 {13033:15929}{10137:11585} > (DF) [tos 0x8]  (ttl 62, id 45510)
>  
>
Thanks a lot Alexey for pointing that out.!!!..That was more or less 
what I was asumming....  but is this feature of linux TCP documented 
somewhere? as far as I can see I couldnt find it in Pasi's paper.... in 
the conservative sack based recovery RFC (* RFC 3517), it is clearly 
*stated that the

   Upon the receipt of the first (DupThresh - 1) duplicate ACKs, the
   scoreboard is to be updated as normal.  Note: The first and second
   duplicate ACKs can also be used to trigger the transmission of
   previously unsent segments using the Limited Transmit algorithm
   [RFC3042].

   When a TCP sender receives the duplicate ACK corresponding to
   DupThresh ACKs, the scoreboard MUST be updated with the new SACK
   information (via Update ()).  If no previous loss event has occurred
   on the connection or the cumulative acknowledgment point is beyond
   the last value of RecoveryPoint, a loss recovery phase SHOULD be
   initiated, per the fast retransmit algorithm outlined in [RFC2581].

ofcourse,  once we are in the fast recovery phase we are able to mark a packet lost based on the criteria (also from the same RFC)

IsLost (SeqNum):
      This routine returns whether the given sequence number is
      considered to be lost.  The routine returns true when either
      DupThresh discontiguous SACKed sequences have arrived above
      'SeqNum' or (DupThresh * SMSS) bytes with sequence numbers greater
      than 'SeqNum' have been SACKed.  Otherwise, the routine returns
      false.

But from the trace portion you cut outside  it seems the sack 
implementation in linux simply checked the sn of the newly sacked one, 
and finding out that there are two blocks in between, considered it as 
if it is a dupthresh duplicate ack and retransmitted it... So if we were 
not using sack the retransmission would have occured after 
01:28:15.90... so the TCP SACK retransmitted in this case around 50ms 
earlier...but  it might be larger in some cases, (I will try to look 
into the traces to find larger time differences but you can see there is 
a clear difference by looking at the plots of the cdf of the time of 
occurance of the first retransmissions for the different cases at  
http://kom.aau.dk/~oumer/first_transmission_times.pdf .... so I am on 
the verge of concluding TCP SACK is worse than non SACK TCP incase of 
persistent reordering....if only I could find a reference about the 
linux TCP SACK behaviour we discussed above :-)...

>Actually, it is the reason why the FACK heuristics is not disabled
>even when FACK disabled. Experiments showed that relaxing it severely
>damages recovery in presense of real multiple losses.
>And when it happens to be reordering, undoing works really well.
>  
>
so you are saying, it doesnt matter whether I disable FACK or not, it is 
basically set by default?
and it is disabled only when reordering is detected (and this is done 
either through timestamps or DSACK, right?)...
so if neither DSACK and timestamps are enabled we are unable to detect 
disorder, so basically there should be no difference between SACK and 
FACK, cause it is always FACK used... and that seems to make sense  from 
the results I have  (i.e. referrring to ....
http://kom.aau.dk/~oumer/384_100Kbyte_Timestamps_SACK_FACK_DSACK_10FER_DT.pdf
http://kom.aau.dk/~oumer/384_100Kbyte_Timestamps_SACK_FACK_DSACK_10FER_ret.pdf
)...

now let's introduce DSACK and no timestamps... that means we are able to 
detect some reordering and download time should decrease, and it does so 
as shown in the first of the figures I just give the link to...however, 
the # of retransmissions increases as shown in the second figure? isnt 
that odd? shouldnt it be the other way around?

Also why does the # retransmissions in the timestamp case increases when 
we use SACK/FACK as compared with no SACK case?...and as you mentioned 
earlier reordering undoing works very well, by comparing the curves with 
and without timestamps, but some of this seems to be undo when we use it 
along with SACK, FACK and DSACK, eventhough the differences are not that 
much...

>There is one more thing, which probably happens in your experiments,
>though I did not find it in dumps. If reordering exceeds RTT, i.e.
>we receive SACK for a segment, which was sent as part of forward
>retransmission after a hole was detected, fast retransmit entered immediately.
>Two dupacks is enough for this: first triggers forward transmission,
>if the second SACKs the segmetn which has just been sent, we are there.
>  
>
This one , I dont think I understood you. Could you please make it a bit 
more clearer?

>>One more thing, say I have FRTO, DSACK and timestamps enabled, which 
>>algorithm takes precedence ?
>>    
>>
>
>They live together, essnetially, not dependant. 
>  
>
OK ...but if timestamps are enabled, then I just couldnt figure out the 
use of  DSACK, can it tell us something more than we can find using 
timestamps??

>Alexey
>  
>
Regards,
Oumer

