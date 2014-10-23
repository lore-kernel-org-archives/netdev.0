From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 22:40:36 -0600
Message-ID: <544886C4.4020702@gmail.com>
References: <5447FDB2.2010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Crestez Dan Leonard <cdleonard@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34468 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaJWEkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 00:40:40 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so339288pde.12
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 21:40:40 -0700 (PDT)
In-Reply-To: <5447FDB2.2010906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/14, 12:55 PM, Crestez Dan Leonard wrote:
> Hello,
>
> It seems that the TCP MD5 feature allocates a percpu struct tcp_md5sig_pool and uses part of that memory for a scratch buffer to do crypto on. Here is the relevant code:

This is a forward port of a local change to address the problem (local 
kernel version is 3.4 so perhaps my quick bump to top of tree is off but 
it shows the general idea). Been on my to-do list to figure out why this 
is needed, but it seems related to your problem:

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e76d88c..833a676bd4b0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2941,7 +2941,7 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
     local_bh_disable();
     p = ACCESS_ONCE(tcp_md5sig_pool);
     if (p)
-       return raw_cpu_ptr(p);
+       return __va(per_cpu_ptr_to_phys(raw_cpu_ptr(p)));

     local_bh_enable();
     return NULL;

David
