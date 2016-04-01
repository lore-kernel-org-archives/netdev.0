From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: avoid refreshing heartbeat timer too often
Date: Thu, 31 Mar 2016 21:24:27 -0300
Message-ID: <20160401002427.GK3387@mrl.redhat.com>
References: <1459258897-21607-1-git-send-email-marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D54DBFFCD@AcuExch.aculab.com>
 <56FBC2DE.3000207@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D54DC1DB0@AcuExch.aculab.com>
 <20160331212512.GJ3387@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424AbcDAAYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 20:24:31 -0400
Content-Disposition: inline
In-Reply-To: <20160331212512.GJ3387@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 06:25:12PM -0300, 'Marcelo Ricardo Leitner' wrote:
> On Thu, Mar 31, 2016 at 11:16:52AM +0000, David Laight wrote:
> > From: Marcelo Ricardo Leitner
> > > Sent: 30 March 2016 13:13
> > > Em 30-03-2016 06:37, David Laight escreveu:
> > > > From: Marcelo Ricardo Leitner
> > > >> Sent: 29 March 2016 14:42
> > > >>
> > > >> Currently on high rate SCTP streams the heartbeat timer refresh can
> > > >> consume quite a lot of resources as timer updates are costly and it
> > > >> contains a random factor, which a) is also costly and b) invalidates
> > > >> mod_timer() optimization for not editing a timer to the same value.
> > > >> It may even cause the timer to be slightly advanced, for no good reason.
> > > >
> > > > Interesting thoughts:
> > > > 1) Is it necessary to use a different 'random factor' until the timer actually
> > > >     expires?
> > > 
> > > I don't understand you fully here, but we have to have a random factor
> > > on timer expire. As noted by Daniel Borkmann on his commit 8f61059a96c2
> > > ("net: sctp: improve timer slack calculation for transport HBs"):
> > 
> > When a HEARTBEAT chunk is sent determine the new interval, use that
> > interval until the timer actually expires when a new interval is
> > calculated. So the random number is only generated once per heartbeat.
> > 
> > >      RFC4960, section 8.3 says:
> > > 
> > >        On an idle destination address that is allowed to heartbeat,
> > >        it is recommended that a HEARTBEAT chunk is sent once per RTO
> > >        of that destination address plus the protocol parameter
> > >        'HB.interval', with jittering of +/- 50% of the RTO value,
> > >        and exponential backoff of the RTO if the previous HEARTBEAT
> > >        is unanswered.
> > > 
> > > Previous to his commit, it was using a random factor based on jiffies.
> > > 
> > > This patch then assumes that random_A+2 is just as random as random_B as
> > > long as it is within the allowed range, avoiding the unnecessary updates.
> > > 
> > > > 2) It might be better to allow the heartbeat timer to expire, on expiry work
> > > >     out the new interval based on when the last 'refresh' was done.
> > > 
> > > Cool, I thought about this too. It would introduce some extra complexity
> > > that is not really worth I think, specially because now we may be doing
> > > more timer updates even with this patch but it's not triggering any wake
> > > ups and we would need at least 2 wake ups then: one for the first
> > > timeout event, and then re-schedule the timer for the next updated one,
> > > and maybe again, and again.. less timer updates but more wake ups, one
> > > at every heartbeat interval even on a busy transport. Seems it's cheaper
> > > to just update the timer then.
> > 
> > One wakeup per heartbeat interval on a busy connection is probably noise.
> > Probably much less than the 1000s of timer updates that would otherwise happen.
> 
> I was thinking more on near-idle systems, as the overhead for this
> refresh looked rather small now even for busy transports if compared to
> other points, a worth trade-off for reducing wake ups, imho.
> 
> But then I checked tcp, and it does what you're suggesting.
> I'll rework the patch. Thanks

This is what I'm getting with the new approach. I splitted
sctp_transport_reset_timers into sctp_transport_reset_t3_rtx and
sctp_transport_reset_hb_timer, thus why sctp_transport_reset_t3_rtx in there
and it never updates the timer, only start if it's not running already
(as before). Ran netperf for 60 seconds now, to be sure that the timer
would expire twice (1st for initial path validation and 2nd for pure hb).

Samples: 230K of event 'cpu-clock', Event count (approx.): 57707250000
  Overhead  Command  Shared Object      Symbol
+    5,65%  netperf  [kernel.vmlinux]   [k] memcpy_erms
+    5,59%  netperf  [kernel.vmlinux]   [k] copy_user_enhanced_fast_string
-    5,05%  netperf  [kernel.vmlinux]   [k] _raw_spin_unlock_irqrestore
   - _raw_spin_unlock_irqrestore
      + 49,89% __wake_up_sync_key
      + 45,68% sctp_ulpq_tail_event
      - 2,85% mod_timer
         + 76,51% sctp_transport_reset_t3_rtx
         + 23,49% sctp_do_sm
      + 1,55% del_timer
+    2,50%  netperf  [sctp]             [k] sctp_datamsg_from_user
+    2,26%  netperf  [sctp]             [k] sctp_sendmsg

Doesn't seem much different from v1, but ok.

Also I could do some more cleanups on heartbeat/timer code.

  Marcelo
