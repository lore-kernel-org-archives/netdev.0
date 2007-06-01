From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Suspicious fackets_out handling
Date: Fri, 1 Jun 2007 15:17:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706011417430.28601@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704231218440.28337@kivilampi-30.cs.helsinki.fi>
 <20070531.125929.77054675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1304717728-1180696801=:28601"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39988 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbXFAMRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 08:17:04 -0400
In-Reply-To: <20070531.125929.77054675.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0706011424260.28601@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1304717728-1180696801=:28601
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0706011424261.28601@kivilampi-30.cs.helsinki.fi>

On Thu, 31 May 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 23 Apr 2007 14:28:21 +0300 (EEST)
> 
> > There are IMHO two problems in it. First of all, nothing ensures that the 
> > skb TCP is fragmenting is actually below the forwardmost sack block (and 
> > thus is included to the fackets_out)...

...this is so old thing already that I had to refresh my memory, 
haven't been expecting any answer for ages... :-)

> Good catch, I agree with your analysis completely.

...I later on understood (from a comment I found elsewhere) that 
fackets_out is occasionally estimated, rather than exact value (which 
could be completely fixed in tcp-2.6 due to presence of highest_sack but 
I'm also considering complete removal of it too, like you probably 
noticed).

> > What I'm not sure of though, is how to fix this in net-2.6(.22), it
> > is due to the fact that there is no pointer/seq which can be used in
> > testing for it like in tcp-2.6 which has the highest_sack.
> 
> We can add highest_sack to 2.6.22 in order to fix a bug like this,
> if necessary.

...I think we can leave it as estimate for now, it has been like that
for years and nobody has complained... :-) This problem covers really 
marginal number of cases anyway I think (isn't the diff usually
negative: old - new after fragment should be negative unless mss_now 
bites).

After I found the comments and analyzed some sacked_out code with NewReno, 
I think that usually these estimates are indicated in the code with 
tcp_dec_pcount_approx(...) but it wasn't used in this specific case 
because it inputs skb instead of int, I'll add clarification of this into 
my tcp-2.6 todo list... 

> > Second problem is even more obvious: if adjustment here is being
> > done and the sacktag code then uses fastpath at the arrival of the
> > next ACK, the sacktag code will use a stale value from
> > fastpath_cnt_hint and fails to notice all that math TCP did here
> > unless we start clearing fastpath_skb_hint.
> 
> Let's try not to clear fastpath_skb_hint here if possible :-)

Np, however, whatever we do, it wouldn't really execute that
often... :-)

> Is it possible to update fastpath_cnt_hint properly perhaps?

I think that would be valid and even accurate as it can checks skb's
seq against fastpath_skb_hint->seq. I'm in a hurry and will be a week
out of reach of internet connectivity but here's quick attempt to deal
with this cleanly. Compile tested (be extra careful with this one, it's 
done i a hurry :-)), consider to net-2.6. Considering the marginality of 
this issue, stable might really be an overkill for this one, only a
remotely valid concern comes to my mind in this case: possibility
of fackets_out > packet_out might not be dealt that cleanly everywhere 
(but I'm sure that you can come to a good decicion about it):

[PATCH] [TCP]: SACK fastpath did override adjusted fackets_out

Do same adjustment to SACK fastpath counters provided that
they're valid.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 53232dd..f24dd36 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -699,6 +699,15 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 			tp->fackets_out -= diff;
 			if ((int)tp->fackets_out < 0)
 				tp->fackets_out = 0;
+			/* SACK fastpath might overwrite it unless dealt with */
+			if (tp->fastpath_skb_hint != NULL &&
+			    after(TCP_SKB_CB(tp->fastpath_skb_hint)->seq,
+				  TCP_SKB_CB(skb)->seq)) {
+				tp->fastpath_cnt_hint -= diff;
+				if ((int)tp->fastpath_cnt_hint < 0)
+					tp->fastpath_cnt_hint = 0;
+				  
+			}
 		}
 	}
 
-- 
1.5.0.6

---696243703-1304717728-1180696801=:28601--
