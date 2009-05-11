From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 11 May 2009 16:32:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905111556300.10088@wrl-59.cs.helsinki.fi>
References: <200902262310.12791.elendil@planet.nl> <200905092014.35642.elendil@planet.nl>
 <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
 <200905111450.06749.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-543283065-1242047599=:10088"
Cc: Matthias Andree <matthias.andree@gmx.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60299 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbZEKNcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 09:32:23 -0400
In-Reply-To: <200905111450.06749.elendil@planet.nl>
Content-ID: <Pine.LNX.4.64.0905111615110.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-543283065-1242047599=:10088
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0905111615111.10088@wrl-59.cs.helsinki.fi>

On Mon, 11 May 2009, Frans Pop wrote:

> On Monday 11 May 2009, Ilpo Järvinen wrote:
> > I took my time to fix the urg_hole madness too. The patch below.
> 
> Hmm. I wonder if it wouldn't be better to keep the two issues separate. 
> The initial patch is a clear regression fix (4 people have reported it 
> against fetchmail for Debian). The URG part is IMO a separate issue which 
> I at least have never seen in practice.
> And my Tested-by doesn't cover the additional change either.

Disagreed. It's true that your testing very likely doesn't cover such a 
corner case. The URG thing is legacy which shouldn't exist anymore but it 
might still be that some people are crazy enough to use URG not inline 
(and at the same time are doing MSG_PEEK too). However, that URG part is
not a _separate_ issue, you might not just have a test case but it happens 
due to the very same reason and was broken by the very same commit.

This issue has nothing to do with fetchmail or so alone (regardless of how 
many bugs have been filed against it), it's generic TCP (in kernel) issue, 
whether it's triggered is just about right test pattern which here happens 
with fetchmail but it is by no means limited to it.

I don't care too much if distro people have some local policies regarding 
fixes and that here shouldn't be a bother to them anyway since there's the 
more limited fix available in the archives too if they specifically want 
that.

> That said, I have added the URG change (as an incremental patch) in my 
> local git repo and will give it a go when I next build a kernel (may take 
> a week). I don't expect to be able to confirm it fixes the URG race, but 
> I can at least check that it doesn't cause any false messages with my 
> (spectacularly unspectacular) network traffic.

There's no URG race you're implying! There's peek_seq != tp->copied_seq 
race check which can currently trigger spuriously because of more looping 
that what used to be done. Thus each adjustment of peek_seq (through *seq) 
in the loop must be countered by opposite adjustment for the purpose of 
the check. This urg_hole just covers the other of the two cases there are
to adjust *seq (the other is countered by the -copied part).

If you don't have URG holes, the v2 change yields to: -0 which equals to 
no-op. No testing is going to undo that :-). ...And that can be seen
already from the patch context.


-- 
 i.
---696208474-543283065-1242047599=:10088--
