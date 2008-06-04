From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: fix skb vs fack_count out-of-sync condition
Date: Wed, 4 Jun 2008 13:42:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806041330030.16829@wrl-59.cs.helsinki.fi>
References: <4815BCDF.6070704@andyfurniss.entadsl.com>
 <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
 <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
 <481986FD.8070108@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi>
 <48199342.9010406@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805021342480.30402@wrl-59.cs.helsinki.fi>
 <481C54AF.1050109@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805121349400.1888@wrl-59.cs.helsinki.fi>
 <483E0848.6030307@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-312798771-1212576163=:16829"
Cc: Netdev <netdev@vger.kernel.org>, int 986 <int986@gmail.com>,
	Brian Vowell <brian.vowell@gmail.com>,
	Robin Johnson <robbat2@gentoo.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Andy Furniss <lists@andyfurniss.entadsl.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46334 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbYFDKmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 06:42:46 -0400
In-Reply-To: <483E0848.6030307@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-312798771-1212576163=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 29 May 2008, Andy Furniss wrote:

> ? wrote:
> > On Sat, 3 May 2008, Andy Furniss wrote:
> > 
> > > Ilpo J?rvinen wrote:
> > >
> > > > Since I've not yet found any other path that could lead to it except the
> > > > yesterday's false-positive, getting the write queue state more
> > > > accurately
> > > > captured by the debug patch on the very first occassion might help.
> > > > Here's
> > > > less spammy version of the debug patch (I added one printout as well to
> > > > get
> > > > more usefulness to transitional state reported).
> > > >
> > > OK, increased CONFIG_LOG_BUF_SHIFT from 14 to 18 and reversed old /
> > > applied
> > > new patch.
> > 
> > Any luck so far?
> > 
> 
> Finally - looks like I got two together.
> 
> It doesn't start with WARNING - but dmesg isn't full.

Ok, here's finally the fix to those WARN_ON(!tp->sacked_out && 
tp->fackets_out) WARNINGs, both stable-2.6.25 and linus' tree affected.

-- 
 i.

--
[PATCH] tcp: fix skb vs fack_count out-of-sync condition

This bug is able to corrupt fackets_out in very rare cases.
In order for this to cause corruption:
  1) DSACK in the middle of previous SACK block must be generated.
  2) In order to take that particular branch, part or all of the
     DSACKed segment must already be SACKed so that we have that
     in cache in the first place.
  3) The new info must be top enough so that fackets_out will be
     updated on this iteration.
...then fack_count is updated while skb wasn't, then we walk again
that particular segment thus updating fack_count twice for
a single skb and finally that value is assigned to fackets_out
by tcp_sacktag_one.

It is safe to call tcp_sacktag_one just once for a segment (at
DSACK), no need to call again for plain SACK.

Potential problem of the miscount are limited to premature entry
to recovery and to inflated reordering metric (which could even
cancel each other out in the most the luckiest scenarios :-)).
Both are quite insignificant in worst case too and there exists
also code to reset them (fackets_out once sacked_out becomes zero
and reordering metric on RTO).

This has been reported by a number of people, because it occurred
quite rarely, it has been very evasive. Andy Furniss was able to
get it to occur couple of times so that a bit more info was
collected about the problem using a debug patch, though it still
required lot of checking around. Thanks also to others who have
tried to help here.

This is listed as Bugzilla #10346. The bug was introduced by
me in commit 68f8353b48 ([TCP]: Rewrite SACK block processing & 
sack_recv_cache use), I probably thought back then that there's
need to scan that entry twice or didn't dare to make it go
through it just once there. Going through twice would have
required restoring fack_count after the walk but as noted above,
I chose to drop the additional walk step altogether here.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Cc: int 986 <int986@gmail.com>
Cc: Andy Furniss <lists@andyfurniss.entadsl.com>
Cc: Brian Vowell <brian.vowell@gmail.com>
---
 net/ipv4/tcp_input.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5d5b08b..a00c7f8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1392,9 +1392,9 @@ static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
 
 	if (before(next_dup->start_seq, skip_to_seq)) {
 		skb = tcp_sacktag_skip(skb, sk, next_dup->start_seq, fack_count);
-		tcp_sacktag_walk(skb, sk, NULL,
-				 next_dup->start_seq, next_dup->end_seq,
-				 1, fack_count, reord, flag);
+		skb = tcp_sacktag_walk(skb, sk, NULL,
+				     next_dup->start_seq, next_dup->end_seq,
+				     1, fack_count, reord, flag);
 	}
 
 	return skb;
-- 
1.5.2.2
---696208474-312798771-1212576163=:16829--
