From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH v2 net-next 0/4] batch calls to fib_flush and arp_ifdown
Date: Fri, 5 Feb 2016 14:37:57 -0800
Message-ID: <CAO7SqHA_pTzZb1EPVGXTdFzoXUo3ucdyLdmpZB3irMCbAVOnuA@mail.gmail.com>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36272 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbcBEWh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 17:37:58 -0500
Received: by mail-wm0-f52.google.com with SMTP id p63so45587804wmp.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 14:37:58 -0800 (PST)
In-Reply-To: <1454628956-4803-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgot to mention the rtnl_lock hold time gain with these changes.

I got the following benchmark results on one of our switches.
Without this patch, deleting 1k interfaces with 100k routes in the fib held
the rtnl_lock for 13 seconds. With the patch, rtnl_lock hold time went down
to 5 seconds. The gain is even more pronounced with 512k routes in the FIB.
In this case, without the patch, rtnl_lock was held for 36 seconds and with
the patch it was held for 5.5 seconds.

On Thu, Feb 4, 2016 at 3:35 PM, Salam Noureddine <noureddine@arista.com> wrote:
> Added changes suggested by Julian Anastasov in version 2.
>
> fib_flush walks the whole fib in a net_namespace and is called for
> each net_device being closed or unregistered. This can be very expensive
> when dealing with 100k or more routes in the fib and removal of a lot
> of interfaces. These four patches deal with this issue by calling fib_flush
> just once for each net namespace and introduce a new function arp_ifdown_all
> that does a similar optimization for the neighbour table.
>
> The benchmark tests were run on linux-3.18.
>
> Salam Noureddine (4):
>   net: add event_list to struct net and provide utility functions
>   net: dev: add batching to net_device notifiers
>   net: core: introduce neigh_ifdown_all for all down interfaces
>   net: fib: avoid calling fib_flush for each device when doing batch
>     close     and unregister
>
>  include/linux/netdevice.h   |  2 ++
>  include/net/arp.h           |  1 +
>  include/net/neighbour.h     |  1 +
>  include/net/net_namespace.h | 22 +++++++++++++++++++++
>  include/net/netns/ipv4.h    |  1 +
>  net/core/dev.c              | 48 ++++++++++++++++++++++++++++++++++++++++-----
>  net/core/neighbour.c        | 38 ++++++++++++++++++++++++++++-------
>  net/core/net_namespace.c    |  1 +
>  net/ipv4/arp.c              |  4 ++++
>  net/ipv4/fib_frontend.c     | 16 +++++++++++++--
>  10 files changed, 120 insertions(+), 14 deletions(-)
>
> --
> 1.8.1.4
>
