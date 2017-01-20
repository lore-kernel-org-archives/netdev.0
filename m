From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] net: mpls: Fix multipath selection for LSR use case
Date: Fri, 20 Jan 2017 14:09:22 +0000
Message-ID: <3c207c3b-a831-fdf0-5b77-e2373a6d17bf@brocade.com>
References: <1484873463-11699-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:43777 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752203AbdATOJd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 09:09:33 -0500
In-Reply-To: <1484873463-11699-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/01/17 00:51, David Ahern wrote:
> MPLS multipath for LSR is broken -- always selecting the first nexthop
> in the one label case. For example:
>
>     $ ip netns exec ns1 ip -f mpls ro ls
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
> Removing the bos arg from mpls_multipath_hash uncovers a number of other
> problems with the hash loop that processes the MPLS label stack -- from
> incorrect assumptions on the skb (skb has already pulled the first mpls
> label in mpls_forward yet loop assumes it is there)

This was intentional because it doesn't really add anything to include 
the top-most label in the entropy since all traffic for the mpls_route 
will have the same top-most label, until support for sharing of 
mpls_routes is added.

Having said that, it costs very little to do this, makes the code 
simpler and avoids the need to remember to change this if sharing is 
added, so it's fine with me.

> to incorrect
> pskb_may_pull checks (label_index starts at 0 and pskb_may_pull checks
> all use sizeof() * label_index).
>
> This patch addresses all problems by moving the skb_pull in mpls_forward
> after mpls_select_multipath. This allows mpls_multipath_hash to see the
> skb with the entire label stack as it arrived.
>
> From there mpls_multipath_hash is modified to additively compute the
> total mpls header length on each pass (on pass N mpls_hdr_len is
> N * sizeof(mpls_shim_hdr)). When the label is found with the BOS set it
> verifies the skb has sufficient header for ipv4 or ipv6, and find the
> IPv4 and IPv6 header by using the last mpls_hdr pointer and adding 1 to
> advance past it.
>
> With these changes I have verified the code correctly sees the label,
> BOS, IPv4 and IPv6 addresses in the network header and icmp/tcp/udp
> traffic for ipv4 and ipv6 are distributed across the nexthops.
>
> Fixes: 1c78efa8319ca ("mpls: flow-based multipath selection")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Robert Shearman <rshearma@brocade.com>

Good catch, thanks for fixing.
