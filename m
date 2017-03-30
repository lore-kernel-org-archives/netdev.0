From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/6] net: mpls: Allow users to configure more labels per route
Date: Thu, 30 Mar 2017 09:18:18 -0700
Message-ID: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32826 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933356AbdC3QSb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:18:31 -0400
Received: by mail-pg0-f50.google.com with SMTP id x125so44441833pgb.0
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 09:18:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase the maximum number of new labels for MPLS routes from 2 to 30.

To keep memory consumption in check, the labels array is moved to the end
of mpls_nh and mpls_iptunnel_encap structs as a 0-sized array. Allocations
use the maximum number of labels across all nexthops in a route for LSR
and the number of labels configured for LWT.

The mpls_route layout is changed to:

   +----------------------+
   | mpls_route           |
   +----------------------+
   | mpls_nh 0            |
   +----------------------+
   | alignment padding    |   4 bytes for odd number of labels; 0 for even
   +----------------------+
   | via[rt_max_alen] 0   |
   +----------------------+
   | alignment padding    |   via's aligned on sizeof(unsigned long)
   +----------------------+
   | ...                  |

Meaning the via follows its mpls_nh providing better locality as the
number of labels increases. UDP_RR tests with namespaces shows no impact
to a modest performance increase with this layout for 1 or 2 labels and
1 or 2 nexthops.

mpls_route allocation size is limited to 4096 bytes allowing on the
order of 30 nexthops with 30 labels (or more nexthops with fewer
labels). LWT encap shares same maximum number of labels as mpls routing.

v2
- updates per Eric's comments
  + added patch to ensure all reads of rt_nhn_alive and nh_flags in
    the packet path use READ_ONCE and all writes via event handlers
    use WRITE_ONCE

  + limit mpls_route size to 4096 (PAGE_SIZE for most arch)

  + mostly killed use of MAX_NEW_LABELS; it exists only for common
    limit between lwt and routing paths

David Ahern (6):
  net: mpls: rt_nhn_alive and nh_flags should be accessed using
    READ_ONCE
  net: mpls: Convert number of nexthops to u8
  net: mpls: change mpls_route layout
  net:mpls: Limit memory allocation for mpls_route
  net: mpls: bump maximum number of labels
  net: mpls: Increase max number of labels for lwt encap

 include/net/mpls_iptunnel.h |   5 +-
 net/mpls/af_mpls.c          | 210 +++++++++++++++++++++++++++++---------------
 net/mpls/internal.h         |  61 +++++++++----
 net/mpls/mpls_iptunnel.c    |  13 ++-
 4 files changed, 196 insertions(+), 93 deletions(-)

-- 
2.1.4
