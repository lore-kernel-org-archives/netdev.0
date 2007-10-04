From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24] [TCP]: Fix fastpath_cnt_hint when GSO skb is
 partially ACKed
Date: Thu, 4 Oct 2007 23:20:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710041911400.17326@kivilampi-30.cs.helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
 <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
 <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi>
 <4703A1BB.1040006@free.fr> <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi>
 <4703AE04.5090009@free.fr> <4703B16C.2000106@fr.ibm.com>
 <Pine.LNX.4.64.0710031817540.27745@kivilampi-30.cs.helsinki.fi>
 <4704FE75.2030104@fr.ibm.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1276696139-1191529234=:17406"
Cc: Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <clg@fr.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47139 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760552AbXJDUUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 16:20:38 -0400
In-Reply-To: <4704FE75.2030104@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1276696139-1191529234=:17406
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 4 Oct 2007, Cedric Le Goater wrote:

> so here are the results on a net-2.6.24 kernel. 
> 
> I've put the patchset here to make sure it's correct: 
> 
> 	http://legoater.free.fr/patches/2.6.23/net-2.6.24.git-tcp_fastretrans/
> 
> and plenty of logs :
> 
> 	http://legoater.free.fr/patches/2.6.23/net-2.6.24.git-tcp_fastretrans.messages

Thanks a lot, the bug itself seems to occur far more common than I 
thought... It just very rarely manifests in significant behavior (requires 
non-trivial ACK/SACK pattern to occur). This same bug is present in the 
soon to be released 2.6.23 and in stable too though it's nearly impossible 
to ever see that by human eye and there's a silent fackets_out "fix up" in 
place due to known (and intentional) fackets_out inaccuracy (and nobody is 
really looking that large number of TCP traces)...

The fix below, you can test it with the debug patch quite easily, all 
those messages should of course vanish :-). In case you want to 
test, please mix those three patches (fixes a real bug too), this one and 
the debug patch together...

Dave should apply both the three patch series fix and this one as well to 
net-2.6.24 (Dave, in case you want me to resubmit, just ask... :-)). I'll 
send one against .23-rc9 soon after this (sadly enough, it will cause a 
conflict...).

-- 
 i.


[PATCH net-2.6.24] [TCP]: Fix fastpath_cnt_hint when GSO skb is partially ACKed

I used to be under impression that all hints are cleared in
clean_rtx_queue whenever cumulative ACKs occur. Yet, when only
GSO skb was partially ACKed, no hints were reset, therefore
fastpath_cnt_hint must be tweaked too or else it can corrupt
fackets_out. In case there was also a skb that got fully ACKed,
the fastpath_skb_hint is set to NULL which causes a recount for 
fastpath_cnt_hint (the old value won't be accessed anymore),
thus it can safely be decremented without additional checking.

Reported by Cedric Le Goater <clg@fr.ibm.com>, two other bugs
have been already found and patched due to that report, and
third one (unrelated to this fix) is under evaluation
currently :-)...

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 87c9ef5..4268cd1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2674,6 +2674,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 		tcp_rearm_rto(sk);
 
 		tp->fackets_out -= min(pkts_acked, tp->fackets_out);
+		/* hint's skb might be NULL but we don't need to care */
+		tp->fastpath_cnt_hint -= min_t(u32, pkts_acked,
+					       tp->fastpath_cnt_hint);
 		if (tcp_is_reno(tp))
 			tcp_remove_reno_sacks(sk, pkts_acked);
 
-- 
1.5.0.6

---696243703-1276696139-1191529234=:17406--
