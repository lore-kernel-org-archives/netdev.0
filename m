From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/6] dccp: Silently ignore options with nonsensical lengths
Date: Wed, 27 Aug 2008 07:35:21 +0200
Message-ID: <1219815325-13778-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
 <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46922 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752053AbYH0Ffj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 01:35:39 -0400
In-Reply-To: <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates the option-parsing code with regard to RFC 4340, 5.8:
 "[..] options with nonsensical lengths (length byte less than two or more
  than the remaining space in the options portion of the header) MUST be
  ignored, and any option space following an option with nonsensical length
  MUST likewise be ignored."

Hence in the following cases erratic options will be ignored:
 1. The type byte of a multi-byte option is the last byte of the header
    options (i.e. effective option length of 1).
 2. The value of the length byte is less than the minimum 2. This has been
    changed from previously 3: although no multi-byte option with a length
    less than 3 yet exists (cf. table 3 in 5.8), a length of 2 is valid.
    (The switch-statement in dccp_parse has further per-option length checks.)
 3. The option length exceeds the length of the remaining option space.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -81,11 +81,11 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		/* Check if this isn't a single byte option */
 		if (opt > DCCPO_MAX_RESERVED) {
 			if (opt_ptr == opt_end)
-				goto out_invalid_option;
+				goto out_nonsensical_length;
 
 			len = *opt_ptr++;
-			if (len < 3)
-				goto out_invalid_option;
+			if (len < 2)
+				goto out_nonsensical_length;
 			/*
 			 * Remove the type and len fields, leaving
 			 * just the value size
@@ -95,7 +95,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			opt_ptr += len;
 
 			if (opt_ptr > opt_end)
-				goto out_invalid_option;
+				goto out_nonsensical_length;
 		}
 
 		/*
@@ -283,6 +283,8 @@ ignore_option:
 	if (mandatory)
 		goto out_invalid_option;
 
+out_nonsensical_length:
+	/* RFC 4340, 5.8: ignore option and all remaining option space */
 	return 0;
 
 out_invalid_option:
