From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 13:01:29 -0500
Message-ID: <fc3c25e72104.4804a729@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov> <fb8e9e4f102e.47f8ebfd@fnal.gov>
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
 <000301c89e81$80124570$6b5ee183@D2GT6T71>
 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
 <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: John Heffner <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:40415 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791AbYDOSDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 14:03:22 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZD00FYUOKB5B@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Tue, 15 Apr 2008 13:01:30 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041513013008471 for
 <netdev@vger.kernel.org>; Tue, 15 Apr 2008 13:01:30 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZD00J01OLUV5@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 15 Apr 2008 13:01:30 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> No, this is not right. The old_ack happens only if left edge 
> backtracks, in which case we obviously should discard as it's stale 
> information (except SACK may reveal something not yet known which is
> why sacktag is called there). This same applies regardless of SACK (no 
> 
> tagging of course).

Yes, I mis-present myself in the last email. What I meant is the left edge backtrack case as you have pointed out.
 
> 
> I think you might have found a bug though it won't affect you but 
> makes 
> that check easier to pass actually:
> 
> Questionable thing is that || in tcp_may_raise_cwnd (might not be 
> intentional)...
> 
> But in your case, during initial slow-start that condition in 
> tcp_may_raise_cwnd will always be true (if you've metrics are cleared 
> as 
> they should). Because: (...not important || 1) && 1 because cwnd < 
> ssthresh. After that, when you don't have ECE nor are in recovery, 
> tcp_may_raise_cwnd results in this: (1 || ...not calculated) && 1, so 
> it 
> should always allow increment in your case except when in recovery 
> which 
> hardly makes up for the difference you're seeing...

You are right, I just printed out the return value of tcp_may_raise_cwnd(). It is all one!


> This would only make difference if any of those SACK blocks were new. 
> If 
> they're not, DATA_SACKED_ACKED won't be set in flag.
> 
> > >  Not quite sure, just a guess.
> 
> You seem to be missing the third case, which I tried to point out
> earlier. The case where left edge remains the same. I think it makes a 
> 
> huge difference here (I'll analyse non-recovery case here):
> 
> NewReno goes always to fastretrans_alert, to default branch, and 
> because 
> it's is_dupack, it increments sacked_out through tcp_add_reno_sack. 
> Effectively packets_in_flight is reduced by one and TCP is able to 
> send 
> a new segment out.
> 
> Now with SACK there are two cases:
> 
> SACK and newly discovere SACK info (for simplicity, lets assume just 
> one 
> newly discovered sacked segment). Sacktag marks that segment and 
> increment 
> sacked_out, effectively making packets_in_flight equal to the case 
> with 
> NewReno. It goes to fastretrans_alert and makes all similar maneuvers 
> as 
> NewReno (except if enough SACK blocks have arrived to trigger recovery 
> 
> while NewReno would not have enough dupACKs collected, I doubt that 
> this 
> makes the difference though, I'll need no-metricsed logs to verify the 
> 
> number of recoveries to confirm that they're quite few).
> 
> SACK and no new SACK info. Sacktag won't find anything to mark, thus 
> sacked_out remains the same. It goes to fastretrans_alert because 
> ca_state 
> is CA_Disorder. But, now we did lose one segment compared with NewReno 
> 
> because we didn't increment sacked_out making packets_in_flight to 
> stay in 
> the amount it was before. Thus we cannot send new data segment out and 
> 
> fall behind the NewReno.

Agree with you. Thanks. You did give me a good class on Linux ACK/SACK implementation. Thank you.

> > I had considered this, but it would seem that tcp_may_raise_cwnd() in
> > this case *should* return true, right?
> 
> Yes, it seems. Though I think that it's unintentional. I'd say that 
> that 
> || should be && but I might be wrong.

Yes, It is all ture!

wenji
