From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Remove lost_retrans zero special cases
Date: Thu, 18 Oct 2007 13:17:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710181314130.3767@kivilampi-30.cs.helsinki.fi>
References: <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1192102867248-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071011.173622.09942622.davem@davemloft.net> <20071018.125045.90803775.takano@axe-inc.co.jp>
 <Pine.LNX.4.64.0710181214140.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1703770056-1192702644=:3767"
Cc: y-kodama@aist.go.jp, Netdev <netdev@vger.kernel.org>
To: TAKANO Ryousei <takano@axe-inc.co.jp>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40569 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbXJRKRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:17:25 -0400
In-Reply-To: <Pine.LNX.4.64.0710181214140.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1703770056-1192702644=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 18 Oct 2007, Ilpo Järvinen wrote:

> On Thu, 18 Oct 2007, TAKANO Ryousei wrote:
> 
> > From: David Miller <davem@davemloft.net>
> > Subject: Re: [PATCH 7/7] [TCP]: Limit processing lost_retrans loop to work-to-do cases
> > Date: Thu, 11 Oct 2007 17:36:22 -0700 (PDT)
> > 
> > > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > > Date: Thu, 11 Oct 2007 14:41:07 +0300
> > > 
> > > > This addition of lost_retrans_low to tcp_sock might be
> > > > unnecessary, it's not clear how often lost_retrans worker is
> > > > executed when there wasn't work to do.
> > > > 
> > > > Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
> > > > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > > 
> > > Applied.
> > 
> > > +	    after(highest_sack_end_seq, tp->lost_retrans_low) &&
> >
> > This limit degrades the performance of my test case described before,
> 
> Thanks for testing.... Btw, just noticed that lost_retrans_low addition 
> patch incorrectly dropped check for highest_sack_end_seq (probably due to 
> incorrect resolution from my side at some point of development of those 
> two patches as I added that check later on when realized it's necessary), 
> patching that below... Since it causes zero received_upto in 
> tcp_mark_lost_retrans, some RETRANS bits got cleared unintentionally
> because of that.

...snip...

> --
> 
> [PATCH] [TCP]: Add highest_sack_end_seq check back to lost_retrans call

Try this patch instead not on the top of the one I sent earlier (IMHO 
this is better approach):

--
[PATCH] [TCP]: Remove lost_retrans zero seqno special cases

Both high-sack detection and new lowest seq variables have
unnecessary zero special case which are now removed by setting
safe initial seqnos.

This also fixes problem which caused zero received_upto being
passed to tcp_mark_lost_retrans which confused after relations
within the marker loop causing incorrect TCPCB_SACKED_RETRANS
clearing. The problem was noticed because of a performance
report from TAKANO Ryousei <takano@axe-inc.co.jp>.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0f00966..9288220 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1121,7 +1121,7 @@ static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
 	struct sk_buff *skb;
 	int flag = 0;
 	int cnt = 0;
-	u32 new_low_seq = 0;
+	u32 new_low_seq = tp->snd_nxt;
 
 	tcp_for_write_queue(skb, sk) {
 		u32 ack_seq = TCP_SKB_CB(skb)->ack_seq;
@@ -1153,7 +1153,7 @@ static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
 				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 			}
 		} else {
-			if (!new_low_seq || before(ack_seq, new_low_seq))
+			if (before(ack_seq, new_low_seq))
 				new_low_seq = ack_seq;
 			cnt += tcp_skb_pcount(skb);
 		}
@@ -1242,7 +1242,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord = tp->packets_out;
 	int prior_fackets;
-	u32 highest_sack_end_seq = 0;
+	u32 highest_sack_end_seq = tp->lost_retrans_low;
 	int flag = 0;
 	int found_dup_sack = 0;
 	int cached_fack_count;
-- 
1.5.0.6

---696243703-1703770056-1192702644=:3767--
