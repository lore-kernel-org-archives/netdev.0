From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: [PATCH v2] iproute2: Fix -o (oneline) being broken in xfrm & correct mark radix
Date: Thu, 19 Mar 2015 13:54:28 -0600
Message-ID: <20150319_195428_022337.philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Alexy Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:50072 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbbCSTyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:54:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't insert newline in -o (oneline) mode; print mark as hex.

Oneline mode is supposed to force all output to be on oneline and
machine-parsable, but this isn't the case for "ip xfrm" as shown:

% ip -o xfrm monitor
...
src 0.0.0.0/0 dst 0.0.0.0/0 \   dir out priority 2051 ptype main \  mark -1879048191/0xffffffff
    tmpl src 203.0.130.10 dst 198.51.130.30\        proto esp reqid 16384 mode tunnel\
...

as that's 2 lines, not one. Also, the "mark" is shown in signed
decimal, but the mask is in hex. This is confusing: let's use
hex for both.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 ip/ipxfrm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 659fa6b6457996cfc2a1beca1b6a8db11492c6d2..95f91a537759f90a07832537c92969d46d8a2921 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -689,7 +689,8 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 	if (tb[XFRMA_MARK]) {
 		struct rtattr *rta = tb[XFRMA_MARK];
 		struct xfrm_mark *m = (struct xfrm_mark *) RTA_DATA(rta);
-		fprintf(fp, "\tmark %d/0x%x\n", m->v, m->m);
+		fprintf(fp, "\tmark %#x/%#x", m->v, m->m);
+		fprintf(fp, "%s", _SL_);
 	}
 
 	if (tb[XFRMA_ALG_AUTH] && !tb[XFRMA_ALG_AUTH_TRUNC]) {
