From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Tue, 25 Apr 2017 14:05:21 -0400 (EDT)
Message-ID: <20170425.140521.1068673881149333554.davem@davemloft.net>
References: <1493137049-16465-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, andreyknvl@google.com,
        mmanning@brocade.com, kafai@fb.com, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S971581AbdDYSFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 14:05:23 -0400
In-Reply-To: <1493137049-16465-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 25 Apr 2017 09:17:29 -0700

> Taking down the loopback device wreaks havoc on IPv6 routing. By
> extension, taking down a VRF device wreaks havoc on its table.
> 
> Dmitry and Andrey both reported heap out-of-bounds reports in the IPv6
> FIB code while running syzkaller fuzzer. The root cause is a dead dst
> that is on the garbage list gets reinserted into the IPv6 FIB. While on
> the gc (or perhaps when it gets added to the gc list) the dst->next is
> set to an IPv4 dst. A subsequent walk of the ipv6 tables causes the
> out-of-bounds access.
> 
> Andrey's reproducer was the key to getting to the bottom of this.
> 
> With IPv6, host routes for an address have the dst->dev set to the
> loopback device. When the 'lo' device is taken down, rt6_ifdown initiates
> a walk of the fib evicting routes with the 'lo' device which means all
> host routes are removed. That process moves the dst which is attached to
> an inet6_ifaddr to the gc list and marks it as dead.
> 
> The recent change to keep global IPv6 addresses added a new function,
> fixup_permanent_addr, that is called on admin up. That function restarts
> dad for an inet6_ifaddr and when it completes the host route attached
> to it is inserted into the fib. Since the route was marked dead and
> moved to the gc list, re-inserting the route causes the reported
> out-of-bounds accesses. If the device with the address is taken down
> or the address is removed, the WARN_ON in fib6_del is triggered.
> 
> All of those faults are fixed by regenerating the host route if the
> existing one has been moved to the gc list, something that can be
> determined by checking if the rt6i_ref counter is 0.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David!
