From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: fix potential corner case issue in segmentation (Was:
 Re: [PATCH] Do not use TSO/GSO when there is urgent data)
Date: Fri, 21 Nov 2008 15:07:32 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811211438420.3930@wrl-59.cs.helsinki.fi>
References: <200811211319.45515.ptesarik@suse.cz>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2123648892-1227272852=:3930"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Jan =?utf-8?q?=C5=A0embera?=" <jsembera@suse.cz>
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57702 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbYKUNHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 08:07:35 -0500
In-Reply-To: <200811211319.45515.ptesarik@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2123648892-1227272852=:3930
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 21 Nov 2008, Petr Tesarik wrote:

> This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=12014
> 
> Since most (if not all) implementations of TSO and even the in-kernel
> software GSO do not update the urgent pointer when splitting a large
> segment, it is necessary to turn off TSO/GSO for all outgoing traffic
> with the URG pointer set.

Good observation, I totally missed this possibility of T/GSO while 
looking.

> Looking at tcp_current_mss (and the preceding comment) I even think
> this was the original intention. However, this approach is insufficient,
> because TSO/GSO is turned off only for newly created frames, not for
> frames which were already pending at the arrival of a message with
> MSG_OOB set. These frames were created when TSO/GSO was enabled,
> so they may be large, and they will have the urgent pointer set
> in tcp_transmit_skb().
> 
> With this patch, such large packets will be fragmented again before
> going to the transmit routine.

I wonder if there's some corner case which still fails to fragment
in tcp_retransmit_xmit's in skb->len <= cur_mss case if cur_mss
grew very recently (and therefore skb-len now fits to a single segment).

Patch below, changed subject is due to patchwork as requested by DaveM
(if you'd find that strange).

> As a side note, at least the following NICs are known to screw up
> the urgent pointer in the TCP header when doing TSO:
> 
> 	Intel 82566MM (PCI ID 8086:1049)
> 	Intel 82566DC (PCI ID 8086:104b)
> 	Intel 82541GI (PCI ID 8086:1076)
> 	Broadcom NetXtreme II BCM5708 (PCI ID 14e4:164c)

Heh, it might already be longer than the list we would get from the 
working ones. Not very likely too many people consider urg too
seriously to get it right.

> Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
> CC: Jan Sembera <jsembera@suse.cz>
> CC: Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>
> 
> --
>  tcp_output.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -722,7 +722,8 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff 
> *skb)
>  static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
>  				 unsigned int mss_now)
>  {
> -	if (skb->len <= mss_now || !sk_can_gso(sk)) {
> +	if (skb->len <= mss_now || !sk_can_gso(sk) ||
> +	    tcp_urg_mode(tcp_sk(sk))) {
>  		/* Avoid the costly divide in the normal
>  		 * non-TSO case.
>  		 */
> @@ -1163,7 +1164,9 @@ static int tcp_init_tso_segs(struct sock *sk, struct 
> sk_buff *skb,
>  {
>  	int tso_segs = tcp_skb_pcount(skb);
>  
> -	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now)) {
> +	if (!tso_segs ||
> +	    (tso_segs > 1 && (tcp_skb_mss(skb) != mss_now ||
> +			      tcp_urg_mode(tcp_sk(sk))))) {
>  		tcp_set_skb_tso_segs(sk, skb, mss_now);
>  		tso_segs = tcp_skb_pcount(skb);
>  	}

It's a bit intrusive but I couldn't immediately come up with alternative 
that would have worked (came up with some not working ones :-)).

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>


-- 
 i.


--

[PATCH] tcp: fix potential corner case issue in segmentation

If cur_mss grew very recently so that the previously G/TSOed skb
now fits well into a single segment, it might get send up in
parts unless we calculate # of segments again. Whether it actually
would break something more than that I don't know. But this would
create a more significant problem with the urg t/gso problem that
was found by Petr Tesarik <ptesarik@suse.cz>.

Compile tested only.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a524627..129f46b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1944,6 +1944,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	if (skb->len > cur_mss) {
 		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
+	} else {
+		tcp_init_tso_segs(sk, skb, cur_mss);
 	}
 
 	/* Collapse two adjacent packets if worthwhile and we can. */
-- 
1.5.2.2

---696208474-2123648892-1227272852=:3930--
