From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: beet: fix pseudo header length value
Date: Mon, 23 Apr 2007 13:30:49 +0200
Message-ID: <462C98E9.4020504@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080401020006090700020003"
Cc: Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44257 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161411AbXDWLaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 07:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080401020006090700020003
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080401020006090700020003
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: beet: fix pseudo header length value

draft-nikander-esp-beet-mode-07.txt is not entirely clear on how the length
value of the pseudo header should be calculated, it states "The Header Length
field contains the length of the pseudo header, IPv4 options, and padding in
8 octets units.", but also states "Length in octets (Header Len + 1) * 8".
draft-nikander-esp-beet-mode-08-pre1.txt [1] clarifies this, the header length
should not include the first 8 byte.

This change affects backwards compatibility, but option encapsulation didn't
work until very recently anyway.

[1] http://users.piuha.net/jmelen/BEET/draft-nikander-esp-beet-mode-08-pre1.txt

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4b33b63040d82c55a90eb8ff2d6054bf719514f6
tree c23f5b82272fcef02e804314971b55728185cab7
parent 0f851021c0f91e5073fa89f26b5ac68e23df8e11
author Patrick McHardy <kaber@trash.net> Mon, 23 Apr 2007 13:26:27 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 23 Apr 2007 13:26:27 +0200

 net/ipv4/xfrm4_mode_beet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index f68dfd8..d419e15 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -52,7 +52,7 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 
 		ph = (struct ip_beet_phdr *)skb->h.raw;
 		ph->padlen = 4 - (optlen & 4);
-		ph->hdrlen = (optlen + ph->padlen + sizeof(*ph)) / 8;
+		ph->hdrlen = optlen / 8;
 		ph->nexthdr = top_iph->protocol;
 		if (ph->padlen)
 			memset(ph + 1, IPOPT_NOP, ph->padlen);
@@ -85,7 +85,7 @@ static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 		ph = (struct ip_beet_phdr *)(skb->h.ipiph + 1);
 
 		phlen = sizeof(*ph) + ph->padlen;
-		optlen = ph->hdrlen * 8 - phlen;
+		optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
 		if (optlen < 0 || optlen & 3 || optlen > 250)
 			goto out;
 

--------------080401020006090700020003--
