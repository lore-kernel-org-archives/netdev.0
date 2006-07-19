From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 17:27:19 +0400
Message-ID: <20060719132719.GA22143@ms2.inr.ac.ru>
References: <44BD38B1.1080807@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:53158 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964804AbWGSN2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 09:28:38 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
Content-Disposition: inline
In-Reply-To: <44BD38B1.1080807@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> DSACK)  is used, the retransmissions seem to happen earlier .

Yes. With SACK/FACK retransmissions can be triggered earlier,
if an ACK SACKs a segment which is far enough from current snd.una.
That's what happens f.e. in T_SACK_dump5.dat

01:28:15.681050 < 192.38.55.34.51137 > 192.168.110.111.42238: P 18825:20273[31857](1448) ack 1/5841 win 5840/0 <nop,nop,timestamp 418948058 469778216> [|] (DF)(ttl 64, id 19165)
01:28:15.800946 < 192.168.110.111.42238 > 192.38.55.34.51137: . 1:1[5841](0) ack 8689/31857 win 23168/0 <nop,nop,timestamp 469778229 418948031,nop,nop, sack 1 {10137:11585} > (DF) [tos 0x8]  (ttl 62, id 45508)
01:28:15.860773 < 192.168.110.111.42238 > 192.38.55.34.51137: . 1:1[5841](0) ack 8689/31857 win 23168/0 <nop,nop,timestamp 469778235 418948031,nop,nop, sack 2 {13033:14481}{10137:11585} > (DF) [tos 0x8]  (ttl 62, id 45509)
01:28:15.860781 < 192.38.55.34.51137 > 192.168.110.111.42238: . 8689:10137[31857](1448) ack 1/5841 win 5840/0 <nop,nop,timestamp 418948076 469778235> [|] (DF) (ttl 64, id 19166)

The second sack confirms that 13033..14481 already arrived.

And this is even not a mistake, the third dupack arrived immediately:
01:28:15.901382 < 192.168.110.111.42238 > 192.38.55.34.51137: . 1:1[5841](0) ack 8689/31857 win 23168/0 <nop,nop,timestamp 469778238 418948031,nop,nop, sack 2 {13033:15929}{10137:11585} > (DF) [tos 0x8]  (ttl 62, id 45510)

Actually, it is the reason why the FACK heuristics is not disabled
even when FACK disabled. Experiments showed that relaxing it severely
damages recovery in presense of real multiple losses.
And when it happens to be reordering, undoing works really well.


There is one more thing, which probably happens in your experiments,
though I did not find it in dumps. If reordering exceeds RTT, i.e.
we receive SACK for a segment, which was sent as part of forward
retransmission after a hole was detected, fast retransmit entered immediately.
Two dupacks is enough for this: first triggers forward transmission,
if the second SACKs the segmetn which has just been sent, we are there.

> One more thing, say I have FRTO, DSACK and timestamps enabled, which 
> algorithm takes precedence ?

They live together, essnetially, not dependant. 

Alexey
