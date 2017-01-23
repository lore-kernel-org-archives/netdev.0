From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2] net: mpls: Fix multipath selection for LSR use
 case
Date: Mon, 23 Jan 2017 12:48:35 -0500 (EST)
Message-ID: <20170123.124835.2196368258125086262.davem@redhat.com>
References: <1484945914-32085-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34270 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750723AbdAWRsh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 12:48:37 -0500
In-Reply-To: <1484945914-32085-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 20 Jan 2017 12:58:34 -0800

> MPLS multipath for LSR is broken -- always selecting the first nexthop
> in the one label case. For example:
> 
>     $ ip -f mpls ro ls
>     100
>             nexthop as to 200 via inet 172.16.2.2  dev virt12
>             nexthop as to 300 via inet 172.16.3.2  dev virt13
>     101
>             nexthop as to 201 via inet6 2000:2::2  dev virt12
>             nexthop as to 301 via inet6 2000:3::2  dev virt13
> 
> In this example incoming packets have a single MPLS labels which means
> BOS bit is set. The BOS bit is passed from mpls_forward down to
> mpls_multipath_hash which never processes the hash loop because BOS is 1.
> 
> Update mpls_multipath_hash to process the entire label stack. mpls_hdr_len
> tracks the total mpls header length on each pass (on pass N mpls_hdr_len
> is N * sizeof(mpls_shim_hdr)). When the label is found with the BOS set
> it verifies the skb has sufficient header for ipv4 or ipv6, and find the
> IPv4 and IPv6 header by using the last mpls_hdr pointer and adding 1 to
> advance past it.
> 
> With these changes I have verified the code correctly sees the label,
> BOS, IPv4 and IPv6 addresses in the network header and icmp/tcp/udp
> traffic for ipv4 and ipv6 are distributed across the nexthops.
> 
> Fixes: 1c78efa8319ca ("mpls: flow-based multipath selection")
> Acked-by: Robert Shearman <rshearma@brocade.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - rebase against net/master; v1 was mistakenly based against net-next
> - updated commit message based on Robert's comment about skipping the
>   first label

Applied and queued up for -stable, thanks.
