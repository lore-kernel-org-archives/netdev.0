From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Tue, 21 Oct 2008 12:36:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
References: <20081021090002.21e64151@topolino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56974 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbYJUJgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 05:36:43 -0400
In-Reply-To: <20081021090002.21e64151@topolino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ah, I forgot to add bugzilla back last time, so added it there now.

On Tue, 21 Oct 2008, Aldo Maggi wrote:

> just as matter of information, two other cases similar to mine were
> reported in ubuntu bug pages:
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/272896
> https://bugs.launchpad.net/ubuntu/+bug/285430
> i originated the first one and gave Jarek's first solution:
> tcp_sack=0
> which worked for the two other users.
> 
> maybe they could be contacted in order to perform further tests in a
> different environment.

It's hardly surprising that I couldn't reproduce this, the non-compliance 
here is most probably in isp's device or in some end-user sold embedded 
device.

Can you try this another debug patch below (on 2.6.27.2 is fine). It moves 
the mss to the last position but should keep timestamps in place by making 
wscale as first option. It is well possible that you won't get it working 
at all except with all ts,sack and wscale set to 0 (the most likely 
result). Please try with all wscale,sack,ts combinations (no need to 
provide dumps, just working/not working per case)... This should 
tell us for quite high certaintity what is the actual option which is 
causing this (would it not be the mss-at-beginning which is the most 
likely cause), however, your finding may well be specific to your network 
while the other people might a bit different results.

In order to provide maximal compatibility, I think we just restore the 
previous ordering of the fields (basically the first patch you tested).
It has no additional cost, so it won't hurt any, but it's quite ridiculous 
still that some devices care so little about basic tcp spec which has 
devastating effect on interoperatibility here, they should really fix
the devices instead but knowing how little most of the isp & etc. care
(or even understand) I'm not expecting too much to happen on that
front, and those who care probably run some semi-sane stuff already
anyway... :-). ...Sadly, it's much easier and cheaper to blame the 
end-user's equipment or Linux (if/once it becomes known that it's in use) 
and do nothing in case one is fool enough to complain to them.


-- 
 i.


--
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de54f02..63b0a3f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -376,6 +376,13 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*md5_hash = NULL;
 	}
 
+	if (unlikely(opts->ws)) {
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_WINDOW << 16) |
+			       (TCPOLEN_WINDOW << 8) |
+			       opts->ws);
+	}
+
 	if (likely(OPTION_TS & opts->options)) {
 		if (unlikely(OPTION_SACK_ADVERTISE & opts->options)) {
 			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
@@ -392,12 +399,6 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(opts->mss)) {
-		*ptr++ = htonl((TCPOPT_MSS << 24) |
-			       (TCPOLEN_MSS << 16) |
-			       opts->mss);
-	}
-
 	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
 		     !(OPTION_TS & opts->options))) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
@@ -406,11 +407,10 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			       TCPOLEN_SACK_PERM);
 	}
 
-	if (unlikely(opts->ws)) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_WINDOW << 16) |
-			       (TCPOLEN_WINDOW << 8) |
-			       opts->ws);
+	if (unlikely(opts->mss)) {
+		*ptr++ = htonl((TCPOPT_MSS << 24) |
+			       (TCPOLEN_MSS << 16) |
+			       opts->mss);
 	}
 
 	if (unlikely(opts->num_sack_blocks)) {
