From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv6: make ECMP route replacement less greedy
Date: Mon, 13 Mar 2017 23:21:44 +0800
Message-ID: <CADvbK_e21HQ1PMkR2otbOxZsfYW9XZ_c1R3g085eDfsJC82Kkw@mail.gmail.com>
References: <df56147ddfe635a61f29f651785c02c8c7c56e3d.1489403578.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        Michal Kubecek <mkubecek@suse.cz>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35963 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdCMPVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:21:46 -0400
Received: by mail-qk0-f196.google.com with SMTP id n141so37536819qke.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:21:45 -0700 (PDT)
In-Reply-To: <df56147ddfe635a61f29f651785c02c8c7c56e3d.1489403578.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 8:28 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> Commit 27596472473a ("ipv6: fix ECMP route replacement") introduced a
> loop that removes all siblings of an ECMP route that is being
> replaced. However, this loop doesn't stop when it has replaced
> siblings, and keeps removing other routes with a higher metric.
> We also end up triggering the WARN_ON after the loop, because after
> this nsiblings < 0.
>
> Instead, stop the loop when we have taken care of all routes with the
> same metric as the route being replaced.
>
>   Reproducer:
>   ===========
>     #!/bin/sh
>
>     ip netns add ns1
>     ip netns add ns2
>     ip -net ns1 link set lo up
>
>     for x in 0 1 2 ; do
>         ip link add veth$x netns ns2 type veth peer name eth$x netns ns1
>         ip -net ns1 link set eth$x up
>         ip -net ns2 link set veth$x up
>     done
>
>     ip -net ns1 -6 r a 2000::/64 nexthop via fe80::0 dev eth0 \
>             nexthop via fe80::1 dev eth1 nexthop via fe80::2 dev eth2
>     ip -net ns1 -6 r a 2000::/64 via fe80::42 dev eth0 metric 256
>     ip -net ns1 -6 r a 2000::/64 via fe80::43 dev eth0 metric 2048
>
>     echo "before replace, 3 routes"
>     ip -net ns1 -6 r | grep -v '^fe80\|^ff00'
>     echo
>
>     ip -net ns1 -6 r c 2000::/64 nexthop via fe80::4 dev eth0 \
>             nexthop via fe80::5 dev eth1 nexthop via fe80::6 dev eth2
>
>     echo "after replace, only 2 routes, metric 2048 is gone"
>     ip -net ns1 -6 r | grep -v '^fe80\|^ff00'
>
> Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Xin Long <lucien.xin@gmail.com>
