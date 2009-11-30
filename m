From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: warning: massive change to conditional coding style in net?
Date: Mon, 30 Nov 2009 05:36:21 -0500
Message-ID: <4B13A025.7000103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:44611 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbZK3KgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 05:36:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Over the past several days, David Miller (with help from Joe Perches)
made sweeping changes to the format of conditional statements in the
net tree -- the equivalent of mass patches that change spaces.

This makes writing patches for multiple versions of the tree very
difficult, and will make future pullups problematic.  It's enough to
make a grown man cry....  Patching conflicts everywhere!

CodingStyle is mute on this issue.  Does Linus have a preference?

My personal practice (based on decades of open source projects) has
been to use a form already used in the same file or section of code,
matching the existing practice.

If this is to be done everywhere, CodingStyle (and SubmittingPatches)
should be updated.

Currently, roughly 19% (7855 lines) of the -2.6 tree uses leading form:

	if (condition
	    && condition
	    && (condition
	        || condition
	        || condition)) {

Single spaced is also fairly common:

	if (condition
	 && condition
	 && (condition
	  || condition
	  || condition)) {

The advantage of the leading form is *readability* due to indentation,
ease of patching and reading patches (changes affect only 1 line,
instead of previous and following lines), and especially conditionals
within #if sections.  Also, shorter lines (by 3 characters).

The other 81% uses trailing form, often with odd random line breaks:

	if (condition &&
             condition && (condition || condition ||
	    condition)) {

Miller (with Perches) changed hundreds (thousands?) of these to
trailing form.  This results in a number of hilarious examples --
lines with both leading and trailing, lines with only &&, etc.  A
small sample for illustration:

===

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 322b408..b78e615 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -264,9 +264,11 @@ int ip_mc_output(struct sk_buff *skb)

  		   This check is duplicated in ip_mr_input at the moment.
  		 */
-		    && ((rt->rt_flags&RTCF_LOCAL) || !(IPCB(skb)->flags&IPSKB_FORWARDED))
+		    &&
+		    ((rt->rt_flags & RTCF_LOCAL) ||
+		     !(IPCB(skb)->flags & IPSKB_FORWARDED))
  #endif
-		) {
+		   ) {
  			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
  			if (newskb)
  				NF_HOOK(PF_INET, NF_INET_POST_ROUTING, newskb,
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index cccc2e9..b26dee7 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -1403,8 +1403,8 @@ irnet_connect_indication(void *		instance,
    /* Socket already connecting ? On primary ? */
    if(0
  #ifdef ALLOW_SIMULT_CONNECT
-     || ((irttp_is_primary(server->tsap) == 1)	/* primary */
-	 && (test_and_clear_bit(0, &new->ttp_connect)))
+     || ((irttp_is_primary(server->tsap) == 1) &&	/* primary */
+	 (test_and_clear_bit(0, &new->ttp_connect)))
  #endif /* ALLOW_SIMULT_CONNECT */
       )
      {
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 7034ea4..dd9414e 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -170,21 +170,23 @@ restart:
  	for (s = sht[h1]; s; s = s->next) {
  		if (dst[RSVP_DST_LEN-1] == s->dst[RSVP_DST_LEN-1] &&
  		    protocol == s->protocol &&
-		    !(s->dpi.mask & (*(u32*)(xprt+s->dpi.offset)^s->dpi.key))
+		    !(s->dpi.mask &
+		      (*(u32*)(xprt+s->dpi.offset)^s->dpi.key)) &&
  #if RSVP_DST_LEN == 4
-		    && dst[0] == s->dst[0]
-		    && dst[1] == s->dst[1]
-		    && dst[2] == s->dst[2]
+		    dst[0] == s->dst[0] &&
+		    dst[1] == s->dst[1] &&
+		    dst[2] == s->dst[2] &&
  #endif
-		    && tunnelid == s->tunnelid) {
+		    tunnelid == s->tunnelid) {

  			for (f = s->ht[h2]; f; f = f->next) {
  				if (src[RSVP_DST_LEN-1] == f->src[RSVP_DST_LEN-1] &&
  				    !(f->spi.mask & (*(u32*)(xprt+f->spi.offset)^f->spi.key))
  #if RSVP_DST_LEN == 4
-				    && src[0] == f->src[0]
-				    && src[1] == f->src[1]
-				    && src[2] == f->src[2]
+				    &&
+				    src[0] == f->src[0] &&
+				    src[1] == f->src[1] &&
+				    src[2] == f->src[2]
  #endif
  				    ) {
  					*res = f->res;


