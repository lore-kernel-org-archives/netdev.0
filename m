From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Mon, 7 Dec 2009 16:01:53 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912071532080.7024@wel-95.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba>
 <4B1ADF79.6000101@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1334440251-1260194515=:7024"
Cc: Frederic Leroy <fredo@starox.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53033 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935111AbZLGOBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 09:01:49 -0500
In-Reply-To: <4B1ADF79.6000101@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1334440251-1260194515=:7024
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Sat, 5 Dec 2009, Damian Lukowski wrote:

> Could you please make another test and unplug the cable or drop ACKs for
> several seconds, so that some RTO retransmissions are performed?
> I'd like to see if retrans_stamp remains constant. In the dmesg output of
> the 11th run, it seems to change while icsk_retransmits also increases.
> This is kind of bad for connection timeout calculation in the RTO case ...

After taking some more look into this, this is partly a red herring. It 
looks like that because of the place of the printk that was still in the 
end of the function. You can see the full trace of what happens in .13., 
they come from independent incarnations of RTO recovery (when finally no 
error happens in tcp_retransmit_skb).

However, the problem itself could occur. Here's the patch which should 
prevent that (I'm rather convinced that this really isn't stable worthy 
but net-next or net-2.6 would be fine):

--
[PATCH] tcp: fix retrans_stamp advancing in error cases

It can happen, that tcp_retransmit_skb fails due to some error.
In such cases we might end up into a state where tp->retrans_out
is zero but that's only because we removed the TCPCB_SACKED_RETRANS
bit from a segment but couldn't retransmit it because of the error
that happened. Therefore some assumptions that retrans_out checks
are based do not necessarily hold, as there still can be an old
retransmission but that is only visible in TCPCB_EVER_RETRANS bit.
As retransmission happen in sequential order (except for some very
rare corner cases), it's enough to check the head skb for that bit.

Main reason for all this complexity is the fact that connection dying
time now depends on the validity of the retrans_stamp, in particular,
that successive retransmissions of a segment must not advance
retrans_stamp under any conditions. It seems after quick thinking that
this has relatively low impact as eventually TCP will go into CA_Loss
and either use the existing check for !retrans_stamp case or send a
retransmission successfully, setting a new base time for the dying
timer (can happen only once). At worst, the dying time will be
approximately the double of the intented time. In addition,
tcp_packet_delayed() will return wrong result (has some cc aspects
but due to rarity of these errors, it's hardly an issue).

One of retrans_stamp clearing happens indirectly through first going
into CA_Open state and then a later ACK lets the clearing to happen.
Thus tcp_try_keep_open has to be modified too.

Thanks to Damian Lukowski <damian@tvk.rwth-aachen.de> for hinting
that this possibility exists (though the particular case discussed
didn't after all have it happening but was just a debug patch
artifact).

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   35 ++++++++++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..5608691 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2717,6 +2717,35 @@ static void tcp_try_undo_dsack(struct sock *sk)
 	}
 }
 
+/* We can clear retrans_stamp when there are no retransmissions in the
+ * window. It would seem that it is trivially available for us in
+ * tp->retrans_out, however, that kind of assumptions doesn't consider
+ * what will happen if errors occur when sending retransmission for the
+ * second time. ...It could the that such segment has only
+ * TCPCB_EVER_RETRANS set at the present time. It seems that checking
+ * the head skb is enough except for some reneging corner cases that
+ * are not worth the effort.
+ *
+ * Main reason for all this complexity is the fact that connection dying
+ * time now depends on the validity of the retrans_stamp, in particular,
+ * that successive retransmissions of a segment must not advance
+ * retrans_stamp under any conditions.
+ */
+static int tcp_any_retrans_done(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+
+	if (tp->retrans_out)
+		return 1;
+
+	skb = tcp_write_queue_head(sk);
+	if (unlikely(skb && TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS))
+		return 1;
+
+	return 0;
+}
+
 /* Undo during fast recovery after partial ACK. */
 
 static int tcp_try_undo_partial(struct sock *sk, int acked)
@@ -2729,7 +2758,7 @@ static int tcp_try_undo_partial(struct sock *sk, int acked)
 		/* Plain luck! Hole if filled with delayed
 		 * packet, rather than with a retransmit.
 		 */
-		if (tp->retrans_out == 0)
+		if (!tcp_any_retrans_done(sk))
 			tp->retrans_stamp = 0;
 
 		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
@@ -2788,7 +2817,7 @@ static void tcp_try_keep_open(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int state = TCP_CA_Open;
 
-	if (tcp_left_out(tp) || tp->retrans_out || tp->undo_marker)
+	if (tcp_left_out(tp) || tcp_any_retrans_done(sk) || tp->undo_marker)
 		state = TCP_CA_Disorder;
 
 	if (inet_csk(sk)->icsk_ca_state != state) {
@@ -2803,7 +2832,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 
 	tcp_verify_left_out(tp);
 
-	if (!tp->frto_counter && tp->retrans_out == 0)
+	if (!tp->frto_counter && !tcp_any_retrans_done(sk))
 		tp->retrans_stamp = 0;
 
 	if (flag & FLAG_ECE)
-- 
1.5.6.3

--8323329-1334440251-1260194515=:7024--
