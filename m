From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 07:43:25 -0700
Message-ID: <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5448A72D.1050806@cumulusnetworks.com>
	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	Crestez Dan Leonard <cdleonard@gmail.com>,
	netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44113 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbaJWOn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 10:43:27 -0400
Received: by mail-pd0-f170.google.com with SMTP id z10so1138155pdj.29
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 07:43:26 -0700 (PDT)
In-Reply-To: <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 06:21 -0700, Eric Dumazet wrote:
> On Thu, 2014-10-23 at 02:58 -0400, Jonathan Toppins wrote:
> 
> > > +		if (!pool) {
> > > +			pool = kzalloc_node(sizeof(*pool), GFP_KERNEL,
> > GFP_DMA | GFP_KERNEL
> > This memory will possibly be used in a DMA correct? (thinking crypto
> > hardware offload)
> 
> I am not sure this is the case, but this certainly can be added.
> 

Yes, this is not the case.


The real problem is because sg_set_buf() does the following :


sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));

So it assumes a memory range is not spanning multiple pages.

So maybe a simpler patch would be :


diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e76d88c5852d8ba3392b22aa58d6453ab4d..53e355199437b00836635c5919f2f1a1ae237271 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2886,10 +2886,17 @@ static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
 
 static void __tcp_alloc_md5sig_pool(void)
 {
-	int cpu;
 	struct tcp_md5sig_pool __percpu *pool;
+	size_t sz;
+	int cpu;
 
-	pool = alloc_percpu(struct tcp_md5sig_pool);
+	/* sg_set_buf() assumes a contiguous memory area, but alloc_percpu()
+	 * can use vmalloc(). So make sure we ask an alignment so that
+	 * tcp_md5sig_pool is located in a single page.
+	 */
+	BUILD_BUG_ON(sizeof(struct tcp_md5sig_pool) > PAGE_SIZE);
+	sz = roundup_pow_of_two(sizeof(struct tcp_md5sig_pool));
+	pool = __alloc_percpu(sz, sz);
 	if (!pool)
 		return;
 
