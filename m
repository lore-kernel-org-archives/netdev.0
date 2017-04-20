From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Thu, 20 Apr 2017 09:16:56 -0600
Message-ID: <7204751a-70f9-5803-d5af-06b62530b762@cumulusnetworks.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
 <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
 <ec8e470e-73d0-b357-4f65-a4f7e020db7f@brocade.com>
 <8dcaa797-c566-a9dc-d9a1-99e8d1acfe15@cumulusnetworks.com>
 <277d8c4b-5a18-cda2-6edc-66837cae6469@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f180.google.com ([209.85.213.180]:35233 "EHLO
        mail-yb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969435AbdDTPQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:16:59 -0400
Received: by mail-yb0-f180.google.com with SMTP id 6so28266072ybq.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:16:59 -0700 (PDT)
In-Reply-To: <277d8c4b-5a18-cda2-6edc-66837cae6469@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/17 9:05 AM, Robert Shearman wrote:
> The key thing I think is the ip rules:
> 
> $ ip rule
> 0:    from all lookup local
> 1000:    from all lookup [l3mdev-table]
> 32766:    from all lookup main
> 32767:    from all lookup default
> 
> Maybe you have the local rule moved down at startup?

yes that would be a problem. With this test the 127.0.0.1 lookup is
matching on the wrong table:

perf probe fib_table_lookup%return ret=%ax
perf record -e fib:*,probe:* -a -- ping -c1 -w1 -I red 127.0.0.1
...
perf script

            ping  2803 [000] 70559.086446: fib:fib_table_lookup: table
255 oif 31 iif 1 src 0.0.0.0 dst 127.0.0.1 tos 0 scope 0 flags 4
            ping  2803 [000] 70559.086451: fib:fib_table_lookup_nh:
nexthop dev lo oif 1 src 127.0.0.1
            ping  2803 [000] 70559.086453: probe:fib_table_lookup:
(ffffffff8146aaaa <- ffffffff81470734) ret=0x0
            ping  2803 [000] 70559.086458: fib:fib_table_lookup: table
255 oif 31 iif 1 src 127.0.0.1 dst 127.0.0.1 tos 0 scope 0 flags 4
            ping  2803 [000] 70559.086459: fib:fib_table_lookup_nh:
nexthop dev lo oif 1 src 127.0.0.1
            ping  2803 [000] 70559.086460: probe:fib_table_lookup:
(ffffffff8146aaaa <- ffffffff81470734) ret=0x0
            ping  2803 [000] 70559.086752: fib:fib_table_lookup: table
255 oif 31 iif 1 src 0.0.0.0 dst 127.0.0.1 tos 0 scope 0 flags 4
            ping  2803 [000] 70559.086754: fib:fib_table_lookup_nh:
nexthop dev lo oif 1 src 127.0.0.1
            ping  2803 [000] 70559.086755: probe:fib_table_lookup:
(ffffffff8146aaaa <- ffffffff81470734) ret=0x0
            ping  2803 [000] 70559.086768: fib:fib_table_lookup: table
255 oif 31 iif 1 src 127.0.0.1 dst 127.0.0.1 tos 0 scope 0 flags 5
            ping  2803 [000] 70559.086769: fib:fib_table_lookup_nh:
nexthop dev lo oif 1 src 127.0.0.1
            ping  2803 [000] 70559.086770: probe:fib_table_lookup:
(ffffffff8146aaaa <- ffffffff81470734) ret=0x0
            ping  2803 [000] 70559.086781: fib:fib_table_lookup: table
255 oif 31 iif 1 src 127.0.0.1 dst 127.0.0.1 tos 0 scope 0 flags 4
            ping  2803 [000] 70559.086782: fib:fib_table_lookup_nh:
nexthop dev lo oif 1 src 127.0.0.1
            ping  2803 [000] 70559.086782: probe:fib_table_lookup:
(ffffffff8146aaaa <- ffffffff81470734) ret=0x0
            ping  2803 [000] 70559.086787: fib:fib_table_lookup: table
255 oif 31 iif 1 src 127.0.0.1 dst 127.0.0.1 tos 0 scope 0 flags 5
            ping  2803 [000] 70559.086788: fib:fib_table_lookup_nh:
nexthop dev lo oif 1 src 127.0.0.1
            ping  2803 [000] 70559.086789: probe:fib_table_lookup:
(ffffffff8146aaaa <- ffffffff81470734) ret=0x0

Table 255 is the wrong table. That is the ultimate problem here.
