From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
Date: Mon, 19 Jul 2010 14:16:18 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007191319010.13002@wel-95.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C404FC5.6040107@nets.rwth-aachen.de> <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi> <4C440771.7080107@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-380630650-1279538179=:13002"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tejun Heo <tj@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C440771.7080107@nets.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-380630650-1279538179=:13002
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Mon, 19 Jul 2010, Lennart Schulte wrote:

> I ran tests for about 2 hours with this patch and I got no output from the
> debug patch. This seems to have solved at least my problem :)
> 
> Thanks!
> > [PATCH] tcp: fix crash in tcp_xmit_retransmit_queue
> > 
> > It can happen that there are no packets in queue while calling
> > tcp_xmit_retransmit_queue(). tcp_write_queue_head() then returns
> > NULL and that gets deref'ed to get sacked into a local var.
> > 
> > There is no work to do if no packets are outstanding so we just
> > exit early.
> > 
> > There may still be another bug affecting this same function.

Thanks for testing.

DaveM, I think this oops was introduced for 2.6.28 (in 
08ebd1721ab8fd362e90ae17b461c07b23fa2824 it seems, to be exact) so to 
stables it should go too please. I've only tweaked the message (so no need 
for Lennart to retest v2 :-)).

--
[PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue

It can happen that there are no packets in queue while calling
tcp_xmit_retransmit_queue(). tcp_write_queue_head() then returns
NULL and that gets deref'ed to get sacked into a local var.

There is no work to do if no packets are outstanding so we just
exit early.

This oops was introduced by 08ebd1721ab8fd (tcp: remove tp->lost_out
guard to make joining diff nicer).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Tested-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
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

--8323329-380630650-1279538179=:13002--
