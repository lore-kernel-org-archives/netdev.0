From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 8 Apr 2008 16:45:12 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71> <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov> <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57496 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbYDHNpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 09:45:18 -0400
In-Reply-To: <fbbce0572843.47fb038c@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Apr 2008, Wenji Wu wrote:

> > NewReno never retransmitted anything in them (except at the very end 
> > of 
> > the transfer). Probably something related to how tp->reordering behaves
> > I suppose...
> 
> Yes, the adaptive tp->reordering will play a role here. 

...What is not clear to me why NewReno does not go to recovery at least 
once near the beginning, or at least it won't result in a retransmission.

In which kernel version this dump comes from? 2.6.24 newreno is crippled 
with TSO as was recently discovered, ie., it won't mark lost super skbs 
at head and thus won't retransmit them. Also 2.6.25-rcs are still broken 
(though they'll transmit too much, I'll not go detail in here), DaveM now 
has the fix for 2.6.25-rcs in net-2.6.

> > This is probably far fetched but could you tell us how you make sure 
> > that 
> > earlier connection's metrics are not affecting the latter connection? 
> > 
> > Ie., the discovered reordering is not transferred across the flows (in 
> > CBI 
> > like manner) and thus newreno has unfair advantage?
> 
> You can reverse the order of the tests, with SACK option on/off. The 
> results are still the same.

Ok. I just wanted to make sure so that we don't end up trace some test 
setup issue :-).

> Also, according to the source code, tp->reordering will be initialized 
> to "/proc/sys/net/ipv4/tcp_reordering" (default 3), when the new 
> connection is established.

In addition, in tcp_init_metrics():

	if (dst_metric(dst, RTAX_REORDERING) &&
            tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
                tcp_disable_fack(tp);
                tp->reordering = dst_metric(dst, RTAX_REORDERING);
        }

> After that, tp->reordering is controlled by  the the adaptive algorithm

Yes, however, the algorithm will be vastly different in those two cases.
NewReno stuff is in tcp_check_reno_reordering() and other place in 
tcp_try_undo_partial() but the latter is only happening in recovery I 
think. SACK on the other has number of callsites to tcp_update_reordering, 
check for yourself.

This might be due to my change which made tcp_check_reno_reordering to be 
called earlier than it used to be (to remove a transition state during 
which sacked_out contained stale info including some already cumulative 
ACKed segments). I was quite unsure if I can safely do that. It's not 
clear to me how your test could cause sacked_out > packets_out-1 to occur 
though, which is necessary for tcp_update_reordering to get called with 
newreno. The ACK reordering should just make the number of duplicate acks 
smaller because part of them get discarded as old ones as a newer 
cumulative ACK often arrives a bit "ahead" of it's time making rest 
smaller sequenced ACKs very close to no-op. ...Though I didn't yet do a 
awk magic to prove that it won't happen in the non-sack dump.

-- 
 i.
