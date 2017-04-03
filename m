From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v3 0/6] net: mpls: Allow users to configure more
 labels per route
Date: Mon, 3 Apr 2017 09:14:58 +0100
Message-ID: <382ed537-9286-9bb0-b7c8-2dc1d96c07fa@brocade.com>
References: <1490969644-15499-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:33792 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752011AbdDCIPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 04:15:10 -0400
In-Reply-To: <1490969644-15499-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/03/17 15:13, David Ahern wrote:
> Increase the maximum number of new labels for MPLS routes from 2 to 30.
>
> To keep memory consumption in check, the labels array is moved to the end
> of mpls_nh and mpls_iptunnel_encap structs as a 0-sized array. Allocations
> use the maximum number of labels across all nexthops in a route for LSR
> and the number of labels configured for LWT.
>
> The mpls_route layout is changed to:
...
>
> Meaning the via follows its mpls_nh providing better locality as the
> number of labels increases. UDP_RR tests with namespaces shows no impact
> to a modest performance increase with this layout for 1 or 2 labels and
> 1 or 2 nexthops.
>
> mpls_route allocation size is limited to 4096 bytes allowing on the
> order of 30 nexthops with 30 labels (or more nexthops with fewer
> labels). LWT encap shares same maximum number of labels as mpls routing.
>
> v3
> - initialize n_labels to 0 in case RTA_NEWDST is not defined; detected
>   by the kbuild test robot
>
> v2
> - updates per Eric's comments
>   + added patch to ensure all reads of rt_nhn_alive and nh_flags in
>     the packet path use READ_ONCE and all writes via event handlers
>     use WRITE_ONCE
>
>   + limit mpls_route size to 4096 (PAGE_SIZE for most arch)
>
>   + mostly killed use of MAX_NEW_LABELS; it exists only for common
>     limit between lwt and routing paths
>
> David Ahern (6):
>   net: mpls: rt_nhn_alive and nh_flags should be accessed using
>     READ_ONCE
>   net: mpls: Convert number of nexthops to u8
>   net: mpls: change mpls_route layout
>   net:mpls: Limit memory allocation for mpls_route
>   net: mpls: bump maximum number of labels
>   net: mpls: Increase max number of labels for lwt encap
>
>  include/net/mpls_iptunnel.h |   5 +-
>  net/mpls/af_mpls.c          | 210 +++++++++++++++++++++++++++++---------------
>  net/mpls/internal.h         |  61 +++++++++----
>  net/mpls/mpls_iptunnel.c    |  13 ++-
>  4 files changed, 196 insertions(+), 93 deletions(-)
>

Acked-by: Robert Shearman <rshearma@brocade.com>
