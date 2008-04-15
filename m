From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 11:25:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov> <fb8e9e4f102e.47f8ebfd@fnal.gov>
  <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>  <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
  <fbbce0572843.47fb038c@fnal.gov>  <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
  <fba201de4228.47fb3b26@fnal.gov>  <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
  <000301c89e81$80124570$6b5ee183@D2GT6T71> <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>, wenji@fnal.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47363 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281AbYDOIZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 04:25:50 -0400
In-Reply-To: <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2008, John Heffner wrote:

> On Mon, Apr 14, 2008 at 3:47 PM, Wenji Wu <wenji@fnal.gov> wrote:
> >
> >  Could the throughput difference with SACK ON/OFF be due to the following
> >  code in tcp_ack()?
> >
> >  3120        if (tcp_ack_is_dubious(sk, flag)) {
> >  3121                /* Advance CWND, if state allows this. */
> >  3122                if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
> >  3123                    tcp_may_raise_cwnd(sk, flag))
> >  3124                        tcp_cong_avoid(sk, ack, prior_in_flight, 0);
> >  3125                tcp_fastretrans_alert(sk, prior_packets -
> >  tp->packets_out, flag);
> >  3126        } else {
> >  3127                if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
> >  3128                        tcp_cong_avoid(sk, ack, prior_in_flight, 1);
> >  3129        }
> >
> >  In my tests, there are actually no packet drops, just severe packet
> >  reordering in both forward and reverse paths. With good tcp_reordering
> >  auto-tuning, there are few retransmissions.
> >
> >
> >  (1) With SACK option off, the reorder ACKs will not cause much harm to the
> >  throughput. As you have pointed out in the email that "The ACK reordering
> >
> >  should just make the number of duplicate acks smaller because part of them
> >  get discarded as old ones as a newer cumulative ACK often arrives a bit
> >  "ahead" of its time making rest smaller sequenced ACKs very close to on-op."

...Please note that these are considered as old ACKs, so that we do goto 
old_ack, which is equal for both SACK and NewReno. ...So it won't make any 
difference between them.

> >  If there are any ACK advancement, tcp_cong_avoid() will be called.

NewReno case analysis is not exactly what you assume, if there was at 
least on duplicate ACK already, the ca_state will be CA_Disorder for 
NewReno which makes ack_is_dubious true. You probably assumed it goes
to the other branch directly?

> >  (2) With the sack option is on. If the ACKs do not advance the left edge of
> >  the window, those ACKs will go to "old_ack" of "tcp_ack()", no much
> >  processing except sack-tagging the corresponding packets in the
> >  retransmission queue. tcp_cong_avoid() will not be called.

No, this is not right. The old_ack happens only if left edge 
backtracks, in which case we obviously should discard as it's stale 
information (except SACK may reveal something not yet known which is
why sacktag is called there). This same applies regardless of SACK (no 
tagging of course).

...Hmm, there's one questionable part in here in the code (I doubt it 
makes any difference here though). If new sack info is discovered, we 
don't retransmit but send new data (if window allows) even when in 
recovery where TCP should retransmit first.

> >  However, if the ACKs advance the left edge of the window and these ACKs
> >  include SACK options, tcp_ack_is_dubious(sk, flag)) would be true. Then the
> >  calling of tcp_cong_avoid() needs to satisfy the if-condition at line 3122,
> >  which is stricter than the if-condition at line 3127.
> >
> >  So, the congestion window with SACK on would be smaller than with SACK off.

I think you might have found a bug though it won't affect you but makes 
that check easier to pass actually:

Questionable thing is that || in tcp_may_raise_cwnd (might not be 
intentional)...

But in your case, during initial slow-start that condition in 
tcp_may_raise_cwnd will always be true (if you've metrics are cleared as 
they should). Because: (...not important || 1) && 1 because cwnd < 
ssthresh. After that, when you don't have ECE nor are in recovery, 
tcp_may_raise_cwnd results in this: (1 || ...not calculated) && 1, so it 
should always allow increment in your case except when in recovery which 
hardly makes up for the difference you're seeing...

> >  If you run tcptrace and xplot on the files I posted, you would see 
> >  lots ACKs will advance the left edge of the window, and include SACK 
> >  blocks.

This would only make difference if any of those SACK blocks were new. If 
they're not, DATA_SACKED_ACKED won't be set in flag.

> >  Not quite sure, just a guess.

You seem to be missing the third case, which I tried to point out
earlier. The case where left edge remains the same. I think it makes a 
huge difference here (I'll analyse non-recovery case here):

NewReno goes always to fastretrans_alert, to default branch, and because 
it's is_dupack, it increments sacked_out through tcp_add_reno_sack. 
Effectively packets_in_flight is reduced by one and TCP is able to send 
a new segment out.

Now with SACK there are two cases:

SACK and newly discovere SACK info (for simplicity, lets assume just one 
newly discovered sacked segment). Sacktag marks that segment and increment 
sacked_out, effectively making packets_in_flight equal to the case with 
NewReno. It goes to fastretrans_alert and makes all similar maneuvers as 
NewReno (except if enough SACK blocks have arrived to trigger recovery 
while NewReno would not have enough dupACKs collected, I doubt that this 
makes the difference though, I'll need no-metricsed logs to verify the 
number of recoveries to confirm that they're quite few).

SACK and no new SACK info. Sacktag won't find anything to mark, thus 
sacked_out remains the same. It goes to fastretrans_alert because ca_state 
is CA_Disorder. But, now we did lose one segment compared with NewReno 
because we didn't increment sacked_out making packets_in_flight to stay in 
the amount it was before. Thus we cannot send new data segment out and 
fall behind the NewReno.

> I had considered this, but it would seem that tcp_may_raise_cwnd() in
> this case *should* return true, right?

Yes, it seems. Though I think that it's unintentional. I'd say that that 
|| should be && but I might be wrong.

> Sill the mystery remains as to why *both* are going so slowly.  You
> mentioned you're using a web100 kernel.  What are the final values of
> all the variables for the connections (grab with readall)?

...I think that due to reordering, one will lose part of the cwnd 
increments because of old ACKs as they won't allow you to add more 
segments to the network, at some point of time the lossage will be large 
enough to stall the growth of the cwnd (if in congestion avoidance with 
the small increment). With slow start it seems not that self-evident that 
such level exists though it might.

-- 
 i.
