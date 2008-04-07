From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-2.6 4/4] [TCP]: Don't allow FRTO to take place while MTU is being probed
Date: Mon,  7 Apr 2008 14:55:44 +0300
Message-ID: <1207569344-19687-5-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1207569344-19687-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1207569344-19687-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1207569344-19687-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Soeren Sonnenburg <kernel@nn7.de>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Alessandro Suardi <alessandro.suardi@gmail.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51302 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131AbYDGLzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 07:55:50 -0400
In-Reply-To: <1207569344-19687-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MTU probe can cause some remedies for FRTO because the normal
packet ordering may be violated allowing FRTO to make a wrong
decision (it might not be that serious threat for anything
though). Thus it's safer to not run FRTO while MTU probe is
underway.

It seems that the basic FRTO variant should also look for an
skb at probe_seq.start to check if that's retransmitted one
but I didn't implement it now (plain seqno in window check
isn't robust against wraparounds).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a2a06d6..2b09a89 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1691,11 +1691,16 @@ static inline void tcp_reset_reno_sack(struct t=
cp_sock *tp)
 int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
+	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct sk_buff *skb;
=20
 	if (!sysctl_tcp_frto)
 		return 0;
=20
+	/* MTU probe and F-RTO won't really play nicely along currently */
+	if (icsk->icsk_mtup.probe_size)
+		return 0;
+
 	if (IsSackFrto())
 		return 1;
=20
--=20
1.5.2.2

