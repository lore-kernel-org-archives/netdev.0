From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/4] net: mpls: Allow users to configure more labels per route
Date: Sat, 25 Mar 2017 10:03:24 -0700
Message-ID: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36777 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbdCYRDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 13:03:41 -0400
Received: by mail-pf0-f172.google.com with SMTP id o126so8210988pfb.3
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 10:03:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump the maximum number of labels for MPLS routes from 2 to 12. To keep
memory consumption in check the labels array is moved to the end of mpls_nh
and mpls_iptunnel_encap structs as a 0-sized array. Allocations use the
maximum number of labels across all nexthops in a route for LSR and the
number of labels configured for LWT.

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

The new limit is set to 12 to cover all currently known segment
routing use cases.

David Ahern (4):
  mpls: Convert number of nexthops to u8
  net: mpls: change mpls_route layout
  net: mpls: bump maximum number of labels
  net: mpls: Increase max number of labels for lwt encap

 include/net/mpls_iptunnel.h |   4 +-
 net/mpls/af_mpls.c          | 108 ++++++++++++++++++++++++++------------------
 net/mpls/internal.h         |  52 ++++++++++++++-------
 net/mpls/mpls_iptunnel.c    |  13 ++++--
 4 files changed, 112 insertions(+), 65 deletions(-)

-- 
2.1.4
