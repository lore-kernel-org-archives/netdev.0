From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] AF_RAW: Augment raw_send_hdrinc to expand skb to fit
	iphdr->ihl
Date: Wed, 28 Oct 2009 13:39:55 -0400
Message-ID: <20091028173955.GB7422@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44787 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227AbZJ1Rjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:39:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Augment raw_send_hdrinc to correct for incorrect ip header length values

A series of oopses was reported to me recently.  Apparently when using AF_RAW
sockets to send data to peers that were reachable via ipsec encapsulation,
people could panic or BUG halt their systems.

I've tracked the problem down to user space sending an invalid ip header over an
AF_RAW socket with IP_HDRINCL set to 1.

Basically what happens is that userspace sends down an ip frame that includes
only the header (no data), but sets the ip header ihl value to a large number,
one that is larger than the total amount of data passed to the sendmsg call.  In
raw_send_hdrincl, we allocate an skb based on the size of the data in the msghdr
that was passed in, but assume the data is all valid.  Later during ipsec
encapsulation, xfrm4_tranport_output moves the entire frame back in the skbuff
to provide headroom for the ipsec headers.  During this operation, the
skb->transport_header is repointed to a spot computed by
skb->network_header + the ip header length (ihl).  Since so little data was
passed in relative to the value of ihl provided by the raw socket, we point
transport header to an unknown location, resulting in various crashes.

So, what to do about this?  My first thought was to simply return -EINVAL, and
let user space sort it out.  I'm still thinking that might be the best way, but
I thought I'd try this first, just in case someone has reason to try to
send such a bogus frame through the kernel.  This solution simply checks the
value of ihl in raw_send_hdrinc and expands the skb to fit, filling the new
space with  IPOPT_NOOP options.  I've confirmed that it fixes the crashes that
were reported.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 raw.c |   42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)


diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 9ef8c08..412304f 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -351,13 +351,42 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	skb->transport_header = skb->network_header;
-	err = memcpy_fromiovecend((void *)iph, from, 0, length);
-	if (err)
-		goto error_fault;
+	err = -EFAULT;
+	if (memcpy_fromiovecend((void *)iph, from, 0, length))
+		goto error_free;
 
-	/* We don't modify invalid header */
 	iphlen = iph->ihl * 4;
-	if (iphlen >= sizeof(*iph) && iphlen <= length) {
+	/*
+	 * We don't modify invalid header, but we do want to be sure
+	 * that we have enough space in the skb to hold the header
+	 * and all its options, so if iph->ihl is greater than
+	 * the length of the iovec, we need to reallocate the skb, lest
+	 * odd things happen farther down the stack
+	 */
+	if (iphlen > length) {
+		size_t new_length;
+		int i;
+		char *pad;
+ 
+		/*
+		 * someone passed in a bogus ip header, in which the
+		 * the iph->ihl value was longer than the actual data
+		 * buffer.  We need to at least meet the ihl requirement
+		 * and since we don't mess with the ip header here
+		 * lets expand the skb
+		 */
+		new_length = iphlen - length;
+		err = -ENOMEM;
+		if (pskb_expand_head(skb, 0,
+		     new_length, GFP_KERNEL) < 0)
+			goto error_free;
+		pad = skb_put(skb, new_length);
+		for (i = 0; i < new_length; i++)
+			pad[i] = IPOPT_NOOP;
+ 
+	}
+ 
+	if (iphlen >= sizeof(*iph)) {
 		if (!iph->saddr)
 			iph->saddr = rt->rt_src;
 		iph->check   = 0;
@@ -380,8 +409,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 out:
 	return 0;
 
-error_fault:
-	err = -EFAULT;
+error_free:
 	kfree_skb(skb);
 error:
 	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
