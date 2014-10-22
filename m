From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 19:38:31 -0400
Message-ID: <54483FF7.4090208@cumulusnetworks.com>
References: <5447FDB2.2010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: Crestez Dan Leonard <cdleonard@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:60229 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbaJVXie convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 19:38:34 -0400
In-Reply-To: <5447FDB2.2010906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/14, 2:55 PM, Crestez Dan Leonard wrote:
> sg_init_one does virt_addr on the pointer which assumes it is directly accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu which can return memory from the vmalloc area after the pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting crashes on mips and I believe this to be the cause.

Thinking about this more if the issue really is sg_init_one assumes a
directly accessible memory region, can we just modify the zone
allocation to GFP_DMA using alloc_percpu_gfp()? Does this satisfy the
assumptions made by sg_init_one?

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e7..6924320 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2889,7 +2889,7 @@ static void __tcp_alloc_md5sig_pool(void)
        int cpu;
        struct tcp_md5sig_pool __percpu *pool;

-       pool = alloc_percpu(struct tcp_md5sig_pool);
+       pool = alloc_percpu_gfp(struct tcp_md5sig_pool, GFP_DMA);
        if (!pool)
                return;
