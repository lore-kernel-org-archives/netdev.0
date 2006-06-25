From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] skb_find_text ignores to argument
Date: Sun, 25 Jun 2006 07:52:00 -0700
Message-ID: <20060625145200.GA32074@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:51217
	"HELO linuxace.com") by vger.kernel.org with SMTP id S932425AbWFYOwA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 10:52:00 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

skb_find_text takes a "to" argument which is supposed to limit how
far into the skb it will search for the given text.  At present,
it seems to ignore that argument on the first skb, and instead
return a match even if the text occurs beyond the limit.

Patch below fixes this, after adjusting for the "from" starting
point.  This consequently fixes the netfilter string match's "--to"
handling, which currently is broken.

Phil

Signed-off-by: Phil Oester <kernel@linuxace.com>



--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-skbfindtext

diff -ruN linux-orig/net/core/skbuff.c linux-new/net/core/skbuff.c
--- linux-orig/net/core/skbuff.c	2006-06-25 01:26:02.000000000 -0400
+++ linux-new/net/core/skbuff.c	2006-06-25 01:29:40.000000000 -0400
@@ -1739,12 +1739,15 @@
 			   unsigned int to, struct ts_config *config,
 			   struct ts_state *state)
 {
+	unsigned int ret;
+
 	config->get_next_block = skb_ts_get_next_block;
 	config->finish = skb_ts_finish;
 
 	skb_prepare_seq_read(skb, from, to, TS_SKB_CB(state));
 
-	return textsearch_find(config, state);
+	ret = textsearch_find(config, state);
+	return (ret <= to - from ? ret : UINT_MAX);
 }
 
 /**

--T4sUOijqQbZv57TR--
