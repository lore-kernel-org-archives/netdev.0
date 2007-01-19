From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Fri, 19 Jan 2007 12:06:41 +0100
Message-ID: <20070119110641.GA3135@ff.dom.local>
References: <45AE2EDF.4060709@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:51008 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965059AbXASLE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 06:04:28 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45AE2EDF.4060709@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-01-2007 15:12, Michael Tokarev wrote:
> Herbert Xu wrote:
>> On Tue, Jan 16, 2007 at 11:08:51AM +0300, Michael Tokarev wrote:
>>> Ok.  Here's another trace, from that remote network that triggers
>>> this thing more-or-less reliable (every 2nd transfer at least) --
>>> http://www.corpit.ru/mjt/bh-bad-cksum-dmp.bin . It's a full session
>>> between 216.168.29.244 - the requesting/receiving side -- and
>>> 81.13.94.6 -- our sending side (the file being transferred is some
>>> trojan horse I found on a friend's PC, so be careful ;)
>> I'll have a look at this tomorrow.
>>
>> Since you're certain that this is being seen on the wire, one
>> possibility is that we've got a bug somewhere that's zeroing
>> skb->ip_summed on a packet with a partial checksum.
> 
> Here's another sample, which may be more useful.  I've seen quite
> alot of very similar stuff while running tcpdump.
> 
>   http://www.corpit.ru/mjt/bad-cksum-session3-dmp.bin
> 
> The scenario looks like this.
> 
> A client (82.84.172.37 -- a zombie machine trying to send us spam
> in this case) connects to a port 25 here (81.13.94.6:25).  SYN+ACK
> sequence completes.  Next, our server send an initial SMTP greething
> message, but almost right after that, the client sends a FIN packet,
> WITHOUT acknowleging that it received the (first and only) data
> packet.  So some time later our machine re-sends the data, AND adds
> FIN flag to the packet (also replying to the FIN received from the
> client).  And *that* packet - original data packet which is modified
> to also include FIN - has incorrect checksum.
> 
> So it looks like the checksum isn't being updated WHEN ADDING MORE
> FLAGS to the original data packet.
> 

Hi,

Here is my patch proposal. If I'm not totally wrong,
there is a possibility that, during collapsing, empty
skb with FIN is added to "normal" packet and changes
its ip_summed field to CHECKSUM_NONE.

Regards,
Jarek P.

PS: probably there are also other possibilities...
---

[PATCH][NET] tcp_output: rare bad TCP checksum with 2.6.19

The patch "Replace CHECKSUM_HW by CHECKSUM_PARTIAL/CHECKSUM_COMPLETE"
changed to unconditional copying of ip_summed field from collapsed
skb. This patch reverts this change.   

All substantial work including heavy testing and diagnosing by:
Michael Tokarev <mjt@tls.msk.ru>

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.19-/net/ipv4/tcp_output.c linux-2.6.19/net/ipv4/tcp_output.c
--- linux-2.6.19-/net/ipv4/tcp_output.c	2006-11-29 22:57:37.000000000 +0100
+++ linux-2.6.19/net/ipv4/tcp_output.c	2007-01-19 07:58:39.000000000 +0100
@@ -1590,7 +1590,8 @@ static void tcp_retrans_try_collapse(str
 
 		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
 
-		skb->ip_summed = next_skb->ip_summed;
+		if (next_skb->ip_summed == CHECKSUM_PARTIAL)
+			skb->ip_summed = CHECKSUM_PARTIAL;
 
 		if (skb->ip_summed != CHECKSUM_PARTIAL)
 			skb->csum = csum_block_add(skb->csum, next_skb->csum, skb_size);
