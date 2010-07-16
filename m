From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Fri, 16 Jul 2010 16:19:46 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C404FC5.6040107@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-830568000-1279286387=:13946"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tejun Heo <tj@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46479 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965605Ab0GPNTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 09:19:48 -0400
In-Reply-To: <4C404FC5.6040107@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-830568000-1279286387=:13946
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 16 Jul 2010, Lennart Schulte wrote:

> On 16.07.2010 14:02, Ilpo Järvinen wrote:
> > 
> > > > > [ 2754.413150] NULL head, pkts 0
> > > > > [ 2754.413156] Errors caught so far 1
> > > > >          
> > Thanks for reporting the results.
> > 
> > Could you post the oops too or double check do the timestamps really match
> > (and there wasn't more "Errors caught" prints in between)? Since this
> > condition doesn't seem to crash the kernel as also send_head should be
> > NULL, which saves the day here exiting the loop (unless send head would
> > too be corrupt).

Doh, I think we'll deref skb already to get the sacked (wouldn't be 
absolutely necessary but better to not trust side-effects) so it 
certainly is bad even with the send_head exit.

> I can try to do some more testing, perhaps then I will get other results. But
> until now I've always gotten something like above.

It might then be useful to remove if (!caught_it) which was to prevent 
infinite printout if the problem is such that it would have persisted 
forever (now w/o the crash), but since there's no evidence of that.

> With the debug patch the kernel doesn't crash, but I have an oops from a run
> before the patch:

Right, no crash of course, stupid me :-).

Lets start with this (I'm not sure if this helps Tejun's case but 
much doubt it does):

--
[PATCH] tcp: fix crash in tcp_xmit_retransmit_queue

It can happen that there are no packets in queue while calling
tcp_xmit_retransmit_queue(). tcp_write_queue_head() then returns
NULL and that gets deref'ed to get sacked into a local var.

There is no work to do if no packets are outstanding so we just
exit early.

There may still be another bug affecting this same function.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
---
 net/ipv4/tcp_output.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b4ed957..7ed9dc1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2208,6 +2208,9 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	int mib_idx;
 	int fwd_rexmitting = 0;
 
+	if (!tp->packets_out)
+		return;
+
 	if (!tp->lost_out)
 		tp->retransmit_high = tp->snd_una;
 
-- 
1.5.6.5

---696250871-830568000-1279286387=:13946--
