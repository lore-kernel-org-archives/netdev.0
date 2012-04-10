From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] tcp: restore correct limit
Date: Tue, 10 Apr 2012 12:56:42 +0200
Message-ID: <1334055402.3126.87.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
	 <1334046444.3126.12.camel@edumazet-glaptop>
	 <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>
	 <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu>
	 <1334049896.3126.23.camel@edumazet-glaptop>  <4F83FD7A.5010602@monstr.eu>
	 <1334050698.3126.30.camel@edumazet-glaptop>
	 <1334052194.3126.66.camel@edumazet-glaptop> <4F8407F7.8070703@monstr.eu>
	 <4F840B99.8040409@redhat.com>  <1334054436.3126.80.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: monstr@monstr.eu, netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54684 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab2DJK4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 06:56:47 -0400
Received: by bkcik5 with SMTP id ik5so4080904bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 03:56:46 -0700 (PDT)
In-Reply-To: <1334054436.3126.80.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c43b874d5d714f (tcp: properly initialize tcp memory limits) tried
to fix a regression added in commits 4acb4190 & 3dc43e3,
but still get it wrong.

Result is machines with low amount of memory have too small tcp_rmem[2]
value and slow tcp receives : Per socket limit being 1/1024 of memory
instead of 1/128 in old kernels, so rcv window is capped to small
values.

Fix this to match comment and previous behavior.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Glauber Costa <glommer@parallels.com>
---
v2: remove one useless "limit = max(limit, 128UL);" line

 net/ipv4/tcp.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5d54ed3..7758a83 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3302,8 +3302,7 @@ void __init tcp_init(void)
 
 	tcp_init_mem(&init_net);
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
-	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 10);
-	limit = max(limit, 128UL);
+	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 7);
 	max_share = min(4UL*1024*1024, limit);
 
 	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
