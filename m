From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc6-git2: warn_on_slowpath for tcp_simple_retransmit
Date: Thu, 3 Apr 2008 15:52:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804031541160.21524@wrl-59.cs.helsinki.fi>
References: <5a4c581d0804011528g786550c5sfd6bf90c0c37706@mail.gmail.com>
 <Pine.LNX.4.64.0804021110190.10371@wrl-59.cs.helsinki.fi>
 <5a4c581d0804021309y6b0f3af1tab24090a17104bf4@mail.gmail.com>
 <Pine.LNX.4.64.0804022333230.10610@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1168032753-1207168751=:10610"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>,
	David Miller <davem@davemloft.net>,
	Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58435 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbYDCMwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 08:52:42 -0400
In-Reply-To: <Pine.LNX.4.64.0804022333230.10610@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0804031541560.21524@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1168032753-1207168751=:10610
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0804031541162.21524@wrl-59.cs.helsinki.fi>

On Wed, 2 Apr 2008, Ilpo Järvinen wrote:

> On Wed, 2 Apr 2008, Alessandro Suardi wrote:
> 
> > On Wed, Apr 2, 2008 at 10:10 AM, Ilpo Järvinen
> > <ilpo.jarvinen@helsinki.fi> wrote:
> > > On Wed, 2 Apr 2008, Alessandro Suardi wrote:
> > >
> > >  > Found this in my FC6-based bittorrent box (K7-800 running
> > >  >  a 2.6.25-rc6-git2 kernel) this evening.
> > >  >
> > >  > The kernel was upgraded two weeks ago to fix the bug
> > >  >  in which an USB VIA driver hammered the PCI bus
> > >  >  causing ATA disk performance to drop, and has been
> > >  >  running since then (it still is).
> > >  >
> > >  > So it's actually 2.6.25-rc6-git2 plus patch as in here
> > >  > http://www.gossamer-threads.com/lists/linux/kernel/895506#895506
> > >  >
> > >  > If there's anything useful I can do, just ask. Thanks !
> > >
> > >  Can you reproduce?
> > 
> > Nope. That only happened once in this uptime:
> > 
> > [root@donkey ~]# uptime
> >  21:57:21 up 14 days, 22:04,  5 users,  load average: 0.64, 0.47, 0.44
> > 

[...snip...]

> > If there's anything else - reproducing seems really really
> >  unlikely - 1 packet in 66 million...
> 
> Yeah, it seems some hard to hit corner case and so far nobody has
> a reproducable scenario (or at least I'm not aware of any). I tried
> to reproduce it last weekend and failed, even with some netem stimuli 
> added while torrenting.

No wonder you won't hit it too often if it's this one. This wasn't 
reported be kernel before 2.6.24-gsomething but I think pre-2.6.24s are 
broken too, they my return negative packets_in_flight because of this for 
a while (which can lead to packet bursts).

This shouldn't cause fackets_out inconsistencies, so there's liekly more
to find. I already checked rest of the lost_out players and found no other 
similar bugs in them. Maybe I should try to play with mtu probing at home 
if it's able to catch more fishes. 

The patch is just compile tested.

-- 
 i.


[PATCH] [TCP]: tcp_simple_retransmit can cause S+L

tcp_simple_retransmit does L increment without any checking
whatsoever for overflowing S+L when NewReno is in use.

The simplest scenario I can currently think of is rather
complex in practice (there might be some more straightforward
cases though). Ie., if mss is reduced during mtu probing, it
endd up marking everything lost and if some duplicate ACKs
arrived prior to that sacked_out will be non-zero as well,
leading to S+L > packets_out, tcp_clean_rtx_queue on the next
cumulative ACK or tcp_fastretrans_alert on the next duplicate
ACK will fix the S counter.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    2 ++
 net/ipv4/tcp_input.c  |   22 ++++++++++++++++------
 net/ipv4/tcp_output.c |    3 +++
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 723b368..8f5fc52 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -760,6 +760,8 @@ static inline unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
 	return tp->packets_out - tcp_left_out(tp) + tp->retrans_out;
 }
 
+extern int tcp_limit_reno_sacked(struct tcp_sock *tp);
+
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6e46b4c..94f3015 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1625,13 +1625,11 @@ out:
 	return flag;
 }
 
-/* If we receive more dupacks than we expected counting segments
- * in assumption of absent reordering, interpret this as reordering.
- * The only another reason could be bug in receiver TCP.
+/* Limits sacked_out so that sum with lost_out isn't ever larger than
+ * packets_out. Returns zero if sacked_out adjustement wasn't necessary.
  */
-static void tcp_check_reno_reordering(struct sock *sk, const int addend)
+int tcp_limit_reno_sacked(struct tcp_sock *tp)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	u32 holes;
 
 	holes = max(tp->lost_out, 1U);
@@ -1639,8 +1637,20 @@ static void tcp_check_reno_reordering(struct sock *sk, const int addend)
 
 	if ((tp->sacked_out + holes) > tp->packets_out) {
 		tp->sacked_out = tp->packets_out - holes;
-		tcp_update_reordering(sk, tp->packets_out + addend, 0);
+		return 1;
 	}
+	return 0;
+}
+
+/* If we receive more dupacks than we expected counting segments
+ * in assumption of absent reordering, interpret this as reordering.
+ * The only another reason could be bug in receiver TCP.
+ */
+static void tcp_check_reno_reordering(struct sock *sk, const int addend)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	if (tcp_limit_reno_sacked(tp))
+		tcp_update_reordering(sk, tp->packets_out + addend, 0);
 }
 
 /* Emulate SACKs for SACKless connection: account for a new dupack. */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6e25540..441fdd3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1808,6 +1808,9 @@ void tcp_simple_retransmit(struct sock *sk)
 	if (!lost)
 		return;
 
+	if (tcp_is_reno(tp))
+		tcp_limit_reno_sacked(tp);
+
 	tcp_verify_left_out(tp);
 
 	/* Don't muck with the congestion window here.
-- 
1.5.2.2
---696208474-1168032753-1207168751=:10610--
