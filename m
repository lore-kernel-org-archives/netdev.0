From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: Add early demux handler for UDP
 unicast
Date: Wed, 08 Mar 2017 10:40:46 -0800
Message-ID: <1488998446.28631.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488997457-24554-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35517 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753872AbdCHStw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 13:49:52 -0500
Received: by mail-pf0-f196.google.com with SMTP id 67so4622527pfg.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 10:49:42 -0800 (PST)
In-Reply-To: <1488997457-24554-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-08 at 11:24 -0700, Subash Abhinov Kasiviswanathan wrote:
> While running a single stream UDPv6 test, we observed that amount
> of CPU spent in NET_RX softirq was much greater than UDPv4 for an
> equivalent receive rate. The test here was run on an ARM64 based
> Android system. On further analysis with perf, we found that UDPv6
> was spending significant time in the statistics netfilter targets
> which did socket lookup per packet. These statistics rules perform
> a lookup when there is no socket associated with the skb. Since
> there are multiple instances of these rules based on UID, there
> will be equal number of lookups per skb.
> 
> By introducing early demux for UDPv6, we avoid the redundant lookups.
> This also helped to improve the performance (800Mbps -> 870Mbps) on a
> CPU limited system in a single stream UDPv6 receive test with 1450
> byte sized datagrams using iperf.

Well, this 'optimization' actually hurts when UDP sockets are not
connected, since this adds an extra cache line miss per incoming packet.

(DNS servers for example)



> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---

> +
> +	if (dst)
> +		dst = dst_check(dst, 0);


IPv6 uses a cookie to validate dst, not 0.
