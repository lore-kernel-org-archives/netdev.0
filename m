From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 24 Aug 2009 13:40:17 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908241334230.30487@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:59998 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752640AbZHXRtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 13:49:01 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F173982CB99
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 13:41:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YEzVm28R6fkW for <netdev@vger.kernel.org>;
	Mon, 24 Aug 2009 13:41:20 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 531DA82CB46
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 13:41:20 -0400 (EDT)
In-Reply-To: <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Sridhar Samudrala wrote:

> So it is possible that there is some other place in the stack where the packets
> are gettting dropped but not counted.

Such a deed occurs in ip_push_pending_frames():

        /* Netfilter gets whole the not fragmented skb. */
        err = ip_local_out(skb);
        if (err) {
                if (err > 0)
                        err = inet->recverr ? net_xmit_errno(err) : 0;
			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                if (err)
                        goto error;
        }

out:
        ip_cork_release(inet);
        return err;

error:
        IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
        goto out;


So if ip_local_out returns NET_XMIT_DROP then its simply going to be
replaced by 0. Then we check err again and there is no error!!!!

The statistics are only generated if IP_RECVERR is set.

Could we move the increment of IPSTATS_MIB_OUTDISCARDS up so that it
is incremented regardless of the setting of IP_RECVERR?

F.e?


Subject: Report TX drops

Incrementing of TX drop counters currently does not work if errors from the
network stack are suppressed (IP_RECVERR off). Increment the statistics
independently of the setting of IP_RECVERR.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 net/ipv4/ip_output.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

Index: linux-2.6/net/ipv4/ip_output.c
===================================================================
--- linux-2.6.orig/net/ipv4/ip_output.c	2009-08-24 17:04:27.000000000 +0000
+++ linux-2.6/net/ipv4/ip_output.c	2009-08-24 17:32:05.000000000 +0000
@@ -1300,20 +1300,21 @@ int ip_push_pending_frames(struct sock *

 	/* Netfilter gets whole the not fragmented skb. */
 	err = ip_local_out(skb);
-	if (err) {
-		if (err > 0)
-			err = inet->recverr ? net_xmit_errno(err) : 0;
-		if (err)
-			goto error;
+	if (err > 0) {
+		/* The packet was dropped by the network subsystem */
+		IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
+
+		/*
+		 * Errors are not passed on if the socket
+		 * does not process errors (see IP_RECVERR).
+		 * net_xmit_errno filters NET_XMIT_CN.
+		 */
+		err = inet->recverr ? net_xmit_errno(err) : 0;
 	}

 out:
 	ip_cork_release(inet);
 	return err;
-
-error:
-	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
-	goto out;
 }

 /*



