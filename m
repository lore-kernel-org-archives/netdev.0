From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Mon, 4 Feb 2013 14:14:25 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1302041327210.4561@wel-95.cs.helsinki.fi>
References: <20130123161238.GE8912@reaktio.net>  <20130123214445.GA16641@order.stressinduktion.org>  <20130123215151.GF8912@reaktio.net>  <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>  <20130123234116.GC16641@order.stressinduktion.org>
 <1358984831.12374.1227.camel@edumazet-glaptop>  <20130124135120.GD16641@order.stressinduktion.org>  <1359777110.30177.58.camel@edumazet-glaptop>  <20130202142832.GP8912@reaktio.net>  <1359818075.30177.78.camel@edumazet-glaptop>
 <CADVnQykbufy-kQrEnJm0bbt=n7C8OfE1=Kr-2KfP7Mbu5Eq58w@mail.gmail.com>  <1359826377.30177.86.camel@edumazet-glaptop> <1359918785.30177.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-296175798-1359979150=:4561"
Cc: Neal Cardwell <ncardwell@google.com>,
	"=?ISO-8859-15?Q?Pasi_K=E4rkk=E4inen?=" <pasik@iki.fi>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854Ab3BDMTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 07:19:33 -0500
In-Reply-To: <1359918785.30177.111.camel@edumazet-glaptop>
Content-ID: <alpine.DEB.2.00.1302041406440.4561@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-296175798-1359979150=:4561
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1302041406441.4561@wel-95.cs.helsinki.fi>

On Sun, 3 Feb 2013, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start())
> uncovered a bug in FRTO code :
> tcp_process_frto() is setting snd_cwnd to 0 if the number
> of in flight packets is 0.
> 
> As Neal pointed out, if no packet is in flight we lost our
> chance to disambiguate whether a loss timeout was spurious.
> 
> We should assume it was a proper loss.
> 
> Reported-by: Pasi Kärkkäinen <pasik@iki.fi>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 8aca4ee..680c422 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3484,7 +3484,8 @@ static bool tcp_process_frto(struct sock *sk, int flag)
>  	    ((tp->frto_counter >= 2) && (flag & FLAG_RETRANS_DATA_ACKED)))
>  		tp->undo_marker = 0;
>  
> -	if (!before(tp->snd_una, tp->frto_highmark)) {
> +	if (!before(tp->snd_una, tp->frto_highmark) ||
> +	    !tcp_packets_in_flight(tp)) {

I think this condition becomes now too broad because there is transient
during FRTO. I think the patch below would be enough to resolve this,
what do you think?

--
[PATCH 1/1] tcp: fix for zero packets_in_flight was too broad

There are transients during normal FRTO procedure during which
the packets_in_flight can go to zero between write_queue state
updates and firing the resulting segments out. As FRTO processing
occurs during that window the check must be more precise to
not match "spuriously" :-). More specificly, e.g., when
packets_in_flight is zero but FLAG_DATA_ACKED is true the problematic
branch that set cwnd into zero would not be taken and new segments
might be sent out later.

Only compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pasi Kärkkäinen <pasik@iki.fi>
---
 net/ipv4/tcp_input.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 680c422..500c2da 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3484,8 +3484,7 @@ static bool tcp_process_frto(struct sock *sk, int flag)
 	    ((tp->frto_counter >= 2) && (flag & FLAG_RETRANS_DATA_ACKED)))
 		tp->undo_marker = 0;
 
-	if (!before(tp->snd_una, tp->frto_highmark) ||
-	    !tcp_packets_in_flight(tp)) {
+	if (!before(tp->snd_una, tp->frto_highmark)) {
 		tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 2 : 3), flag);
 		return true;
 	}
@@ -3505,6 +3504,11 @@ static bool tcp_process_frto(struct sock *sk, int flag)
 		}
 	} else {
 		if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter == 1)) {
+			if (!tcp_packets_in_flight(tp)) {
+				tcp_enter_frto_loss(sk, 2, flag);
+				return true;
+			}
+				
 			/* Prevent sending of new data. */
 			tp->snd_cwnd = min(tp->snd_cwnd,
 					   tcp_packets_in_flight(tp));
-- 
1.7.0.4

--8323329-296175798-1359979150=:4561--
