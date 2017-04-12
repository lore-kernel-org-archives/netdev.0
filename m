From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Wed, 12 Apr 2017 10:51:09 -0600
Message-ID: <822ee9b5-09d6-6987-deb3-6af9d537c891@cumulusnetworks.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36664 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754959AbdDLQvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:51:15 -0400
Received: by mail-pg0-f44.google.com with SMTP id g2so17348464pge.3
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 09:51:09 -0700 (PDT)
In-Reply-To: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 8:21 AM, Robert Shearman wrote:
> Attempting to create a TCP socket not bound to a VRF device when a TCP
> socket bound to a VRF device with the same port exists (and vice
> versa) fails with EADDRINUSE. This limits the ability to use programs
> in selected mixed VRF/non-VRF contexts.
> 
> This patch series solves the problem by extending the l3mdev be aware
> of the special semantics of the main table and fixing issues arising
> from the split local/main tables. A VRF master device created linking
> to the main table and used for these programs in the same way as those
> created for VRF tables can.
> 
> Robert Shearman (3):
>   ipv6: Fix route handling when using l3mdev set to main table
>   ipv4: Fix route handling when using l3mdev set to main table
>   l3mdev: Fix lookup in local table when using main table
> 
>  net/ipv4/af_inet.c      |  4 +++-
>  net/ipv4/fib_frontend.c | 14 +++++++++-----
>  net/ipv4/raw.c          |  5 ++++-
>  net/ipv6/addrconf.c     | 12 +++++++++---
>  net/ipv6/route.c        | 23 ++++++++++++++++++-----
>  net/l3mdev/l3mdev.c     | 26 ++++++++++++++++++++------
>  6 files changed, 63 insertions(+), 21 deletions(-)
> 

the patches look ok to me, but in testing them I see I refcnt problem.
simple reproducer:

ip li add red type vrf table 254
ip link set dev eth1 vrf red
ip addr add 127.0.0.1/8 dev red
ip link set dev eth1 up
ip li set red up
ping -c1 -w1 -I red 127.0.0.1
ip li del red
--> hangs with 'uregister_netdevice: waiting for red to become free.'
