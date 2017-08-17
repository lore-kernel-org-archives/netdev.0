From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: put host and anycast routes on device
 with address
Date: Thu, 17 Aug 2017 10:56:54 -0600
Message-ID: <3b4eb556-a25b-75a8-9d29-1974607044cf@gmail.com>
References: <1502923076-12292-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34761 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHQQ5B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 12:57:01 -0400
Received: by mail-pg0-f67.google.com with SMTP id y192so10756084pgd.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 09:57:01 -0700 (PDT)
In-Reply-To: <1502923076-12292-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/17 4:37 PM, David Ahern wrote:
> One nagging difference between ipv4 and ipv6 is host routes for ipv6
> addresses are installed using the loopback device or VRF / L3 Master
> device. e.g.,
> 
>     2001:db8:1::/120 dev veth0 proto kernel metric 256 pref medium
>     local 2001:db8:1::1 dev lo table local proto kernel metric 0 pref medium
> 
> Using the loopback device is convenient -- necessary for local tx, but
> has some nasty side effects, most notably setting the 'lo' device down
> causes all host routes for all local IPv6 address to be removed from the
> FIB and completely breaks IPv6 networking across all interfaces.
> 
> This patch puts FIB entries for IPv6 routes against the device. This
> simplifies the routes in the FIB, for example by making dst->dev and
> rt6i_idev->dev the same (a future patch can look at removing the device
> reference taken for rt6i_idev for FIB entries). For example:
> 
>     $ ip -6 r ls table all | grep veth1
>     2001:db8:99::/120 dev veth1 proto kernel metric 256 pref medium
>     anycast 2001:db8:99:: dev veth1 table local proto kernel metric 0 pref medium
>     local 2001:db8:99::1 dev veth1 table local proto kernel metric 0 pref medium
> 
> When copies are made on FIB lookups, the cloned route has dst->dev
> set to loopback (or the L3 master device). This is needed for the
> local Tx of packets to local addresses.
> 
> With fib entries allocated against the real network device, the addrconf
> code that reinserts host routes on admin up of 'lo' is no longer needed.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>  net/ipv6/addrconf.c | 42 ------------------------------------------
>  net/ipv6/route.c    | 46 ++++++++++++++++++++++++++++++++++------------
>  2 files changed, 34 insertions(+), 54 deletions(-)
>

DaveM: please drop this one. I found a use case that is failing: UDP
packets to a local linklocal address with no server are not getting the
ICMP unreachable. Will send a v2 when tests complete.
