From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] netfilter: Update ip_route_me_harder to consider
 L3 domain
Date: Thu, 3 Nov 2016 13:17:04 -0600
Message-ID: <5be3200f-d3c9-fa54-8ec4-749ed6d870e2@cumulusnetworks.com>
References: <1478195022-5724-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36209 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbcKCTRG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:17:06 -0400
Received: by mail-pf0-f182.google.com with SMTP id 189so36416503pfz.3
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 12:17:06 -0700 (PDT)
In-Reply-To: <1478195022-5724-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/16 11:43 AM, David Ahern wrote:
> ip_route_me_harder is not considering the L3 domain and sending lookups
> to the wrong table. For example consider the following output rule:
> 
> iptables -I OUTPUT -p tcp --dport 12345 -j REJECT --reject-with tcp-reset
> 
> using perf to analyze lookups via the fib_table_lookup tracepoint shows:
> 
> vrf-test  1187 [001] 46887.295927: fib:fib_table_lookup: table 255 oif 0 iif 0 src 0.0.0.0 dst 10.100.1.254 tos 0 scope 0 flags 0
>         ffffffff8143922c perf_trace_fib_table_lookup ([kernel.kallsyms])
>         ffffffff81493aac fib_table_lookup ([kernel.kallsyms])
>         ffffffff8148dda3 __inet_dev_addr_type ([kernel.kallsyms])
>         ffffffff8148ddf6 inet_addr_type ([kernel.kallsyms])
>         ffffffff8149e344 ip_route_me_harder ([kernel.kallsyms])
> 
> and
> 
> vrf-test  1187 [001] 46887.295933: fib:fib_table_lookup: table 255 oif 0 iif 1 src 10.100.1.254 dst 10.100.1.2 tos 0 scope 0 flags
>         ffffffff8143922c perf_trace_fib_table_lookup ([kernel.kallsyms])
>         ffffffff81493aac fib_table_lookup ([kernel.kallsyms])
>         ffffffff814998ff fib4_rule_action ([kernel.kallsyms])
>         ffffffff81437f35 fib_rules_lookup ([kernel.kallsyms])
>         ffffffff81499758 __fib_lookup ([kernel.kallsyms])
>         ffffffff8144f010 fib_lookup.constprop.34 ([kernel.kallsyms])
>         ffffffff8144f759 __ip_route_output_key_hash ([kernel.kallsyms])
>         ffffffff8144fc6a ip_route_output_flow ([kernel.kallsyms])
>         ffffffff8149e39b ip_route_me_harder ([kernel.kallsyms])
> 
> Updating both lookups to pull the L3 domain from the dst currently
> attached to the skb directs both lookups to the correct table.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> Pablo: from a code review it seems ip_route_me_harder is only called in
>        the output path and after skb_dst is set.

Correction: the 'output path' comment is wrong, but dst appears to always be set for both rx and tx paths.
