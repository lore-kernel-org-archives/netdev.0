From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Date: Sun, 05 Dec 2010 13:24:39 +0100
Message-ID: <1291551879.2806.253.camel@edumazet-laptop>
References: <906429.41845.qm@web111015.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Andrew Watts <akwatts@ymail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37981 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755178Ab0LEMYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 07:24:47 -0500
Received: by wwa36 with SMTP id 36so11807915wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 04:24:46 -0800 (PST)
In-Reply-To: <906429.41845.qm@web111015.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 12:46 -0800, Andrew Watts a =C3=A9=
crit :

> Eric, I echo the thanks on the lightning patch.
> Impressive turnaround!
>=20
> There's an open bug report on the kernel's bugzilla
> for 2.6.36 (#24102). What is the best way to tie these
> together?

Thanks Andy, here is the official patch submission I am going to make.

[PATCH net-2.6] net: fix skb_defer_rx_timestamp()

After commit c1f19b51d1d8 (net: support time stamping in phy devices.),
kernel might crash if CONFIG_NETWORK_PHY_TIMESTAMPING=3Dy and
skb_defer_rx_timestamp() handles a packet without an ethernet header.

=46ixes kernel bugzilla #24102

Reference: https://bugzilla.kernel.org/show_bug.cgi?id=3D24102
Reported-and-tested-by: Andrew Watts <akwatts@ymail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: stable@kernel.org
---
 net/core/timestamping.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 0ae6c22..c4fbf85 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -96,11 +96,13 @@ bool skb_defer_rx_timestamp(struct sk_buff *skb)
 	struct phy_device *phydev;
 	unsigned int type;
=20
-	skb_push(skb, ETH_HLEN);
+	if (skb->data - ETH_HLEN < skb->head)
+		return false;
+	__skb_push(skb, ETH_HLEN);
=20
 	type =3D classify(skb);
=20
-	skb_pull(skb, ETH_HLEN);
+	__skb_pull(skb, ETH_HLEN);
=20
 	switch (type) {
 	case PTP_CLASS_V1_IPV4:


