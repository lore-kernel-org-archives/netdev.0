From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PACKET]: Fix /proc/net/packet crash due to bogus private pointer
Date: Sun, 16 Dec 2007 11:41:20 +0800
Message-ID: <20071216034119.GA1491@gondor.apana.org.au>
References: <200712160118.58611.m.kozlowski@tuxland.pl> <E1J3jqN-0000Jq-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, den@openvz.org, xemul@openvz.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2607 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756002AbXLPDlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 22:41:36 -0500
Content-Disposition: inline
In-Reply-To: <E1J3jqN-0000Jq-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2007 at 11:07:07AM +0800, Herbert Xu wrote:
>
> I suspect namespace borkage.  But just because you pin-pointed
> my patch I'll try to track it down :)

Surprise surprise.  The namespace seq patch missed two spots in
AF_PACKET.

[PACKET]: Fix /proc/net/packet crash due to bogus private pointer

The seq_open_net patch changed the meaning of seq->private.
Unfortunately it missed two spots in AF_PACKET, which still
used the old way of dereferencing seq->private, thus causing
weird and wonderful crashes when reading /proc/net/packet.

This patch fixes them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 485af56..43e49f4 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1878,7 +1878,7 @@ static void *packet_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 	++*pos;
 	return  (v == SEQ_START_TOKEN)
 		? sk_head(&net->packet.sklist)
@@ -1887,7 +1887,7 @@ static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static void packet_seq_stop(struct seq_file *seq, void *v)
 {
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 	read_unlock(&net->packet.sklist_lock);
 }
 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
