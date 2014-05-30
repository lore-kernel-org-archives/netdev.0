From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 6/6] net: fec: Add software TSO support
Date: Thu, 29 May 2014 23:30:22 -0700
Message-ID: <1401431422.3645.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-7-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, davem@davemloft.net,
	ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	shawn.guo@linaro.org, bhutchings@solarflare.com,
	stephen@networkplumber.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:41962 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbaE3GaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 02:30:24 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp16so1379853pbb.34
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 23:30:23 -0700 (PDT)
In-Reply-To: <1401415552-2263-7-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 10:05 +0800, Fugang Duan wrote:

> +	if (((unsigned long) data) & FEC_ALIGNMENT) {
> +		memcpy(fep->tx_bounce[index], data, size);
> +		data = fep->tx_bounce[index];
> +	}

Now you have SG support, maybe you could avoid copying the whole part,
and only copy the beginning to reach the required alignment.

Not sure its a win, as it requires 2 descriptors instead of one,
and tso_count_descs() would have to be changed as well.

Do you have an idea of how often this bouncing happens for normal
workloads (ie not synthetic benchmarks) ?

Even for non TSO frames, we have an 32bit aligned IP header, so the
Ethernet header is not aligned to a 4 bytes boundary. I suspect this
driver had to bounce all TX frames ?

I am wondering if most part of the TSO gain you have comes from this
alignment problem you had before this patch and the SG one.

It looks like you could tweak tcp_sendmsg() to make sure a fragment
always start at a 16 bytes boundary or something...

It should not really matter with iperf because it naturally generates
aligned fragments (A new page starts with offset=0 and iperf uses 128KB
writes...)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eb1dde37e678..be99af2d54e6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1220,6 +1220,7 @@ new_segment:
 					merge = false;
 				}
 
+				pfrag->offset = ALIGN(pfrag->offset, 16);
 				copy = min_t(int, copy, pfrag->size - pfrag->offset);
 
 				if (!sk_wmem_schedule(sk, copy))
