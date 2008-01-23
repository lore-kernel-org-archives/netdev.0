From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 12:49:31 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801231215250.31652@kivilampi-30.cs.helsinki.fi>
References: <OF6C895B68.E4A75EFD-ON652573D9.0034E821-652573D9.0034BF2E@in.ibm.com>
 <Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1817212711-1201084868=:31652"
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34968 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbYAWKtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 05:49:33 -0500
In-Reply-To: <Pine.LNX.4.64.0801231140120.31652@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0801231245150.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1817212711-1201084868=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0801231245151.31652@kivilampi-30.cs.helsinki.fi>

On Wed, 23 Jan 2008, Ilpo Järvinen wrote:

> On Wed, 23 Jan 2008, Krishna Kumar2 wrote:
> 
> > Hi Ilpo,
> > 
> > > It's almost impossible to know which of these is the main cause and the
> > > first occuring due to reasons I'll not copy here. What a strange thing
> > > that it has been super quiet on this front until now everybody is seeing
> > > it, could there be something unrelated to TCP which has broken it all
> > > recently?
> > 
> > I have been getting this for atleast 3 weeks but I was quiet since those
> > were kernels that I had modified.
> 
> Since you can easily reproduce it, lets just figure out what's causing it 
> hard way, rather than digging the endless git-logs... :-)

Hmm, perhaps it could be something related to this (and some untested 
path somewhere which is now exposed):

commit 4a55b553f691abadaa63570dfc714e20913561c1
Author: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Date:   Thu Dec 20 20:36:03 2007 -0800

    [TCP]: Fix TSO deferring

Dave, what do you think? Wouldn't explain the one -rc only report though 
from Denys. Another one I'm a bit unsure of is this:

commit 757c32944b80fd95542bd66f06032ab773034d53
Author: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Date:   Thu Jan 3 20:39:01 2008 -0800

    [TCP]: Perform setting of common control fields in one place

->sacked field is cleared in tcp_retransmit_skb due to a subtle change, 
which might be buggy.... However, I find it rather unlikely that this 
would explain Kumar's case. Anyway, here's the one that reverts the 
problematic part of it. ...and this is net-2.6.25 as well so it won't 
solve Denys' case either.

-- 
 i.

--
[PATCH] [TCP]: Revert part of "[TCP]: Perform setting of common control..."

This commit reverts part of 757c32944b80fd95542bd66f06032ab773034d53
([TCP]: Perform setting of common control fields in one place)
because it's not valid to clear ->sacked field like that without
additional precautions with counters, mostly lost_out, sacked_out
should not be set due to reneging which kicks in much earlier than
this.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 648340f..f6cbc1f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1887,10 +1887,12 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
-			/* Reuse, even though it does some unnecessary work */
-			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
-					     TCP_SKB_CB(skb)->flags);
+			TCP_SKB_CB(skb)->seq = TCP_SKB_CB(skb)->end_seq - 1;
+			skb_shinfo(skb)->gso_segs = 1;
+			skb_shinfo(skb)->gso_size = 0;
+			skb_shinfo(skb)->gso_type = 0;
 			skb->ip_summed = CHECKSUM_NONE;
+			skb->csum = 0;
 		}
 	}
 
-- 
1.5.2.2

---696243703-1817212711-1201084868=:31652--
