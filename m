From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: fix use after free race in send path when
 dev is released
Date: Tue, 19 Nov 2013 15:33:18 -0800
Message-ID: <1384903998.8604.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384902503-1588-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:39429 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624Ab3KSXdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 18:33:24 -0500
Received: by mail-yh0-f54.google.com with SMTP id a41so4129590yho.27
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 15:33:21 -0800 (PST)
In-Reply-To: <1384902503-1588-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 00:08 +0100, Daniel Borkmann wrote:
> Salam reported a use after free bug in PF_PACKET that occurs when
> we're sending out frames on a socket bound device and suddenly the
> netdevice is being unregistered. It appears that commit 827d9780
> introduced a possible race condition between {t,}packet_snd and
> packet_notifier. In the case of a bound socket, packet_notifier can
> drop the last reference to the net_device and {t,}packet_snd might
> end up sending a packet over a freed net_device.
> 
> To avoid reverting 827d9780 entirely, we could make use of po->running
> member that gets reset when we're calling __unregister_prot_hook() in
> packet_notifier() when we receive NETDEV_DOWN or NETDEV_UNREGISTER
> notification. Plus, we still need to hold ref to the netdev, so
> that we can assure it won't be released while we're in send path.
> We try to avoid holding the bind lock all over send code as this
> would likely make it worse when multiple threads want to send on
> the same socket (in mmap code we're holding the pg_vec_lock mutex
> all over the send code; we should try to get rid of that at some
> point in time!). This at least buys us the possibility that we don't
> have to walk over the entire dev list in dev_get_by_index() that we
> would need to do as before 827d9780, which can just hurt as well
> with many devices registered.
> 
> Fixes: 827d978037d7 ("af-packet: Use existing netdev reference for bound sockets.")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
> Tested-by: Salam Noureddine <noureddine@aristanetworks.com>
> Cc: Ben Greear <greearb@candelatech.com>
> ---
>  net/packet/af_packet.c | 33 ++++++++++++++++++++-------------
>  1 file changed, 20 insertions(+), 13 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 2e8286b..385b2cc 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1045,6 +1045,19 @@ static void *__prb_previous_block(struct packet_sock *po,
>  	return prb_lookup_block(po, rb, previous, status);
>  }
>  
> +static struct net_device *dev_get_packet_sock(struct packet_sock *po)
> +{
> +	struct net_device *dev;
> +
> +	spin_lock(&po->bind_lock);
> +	dev = po->prot_hook.dev;
> +	if (dev)
> +		dev_hold(dev);
> +	spin_unlock(&po->bind_lock);
> +
> +	return dev;
> +}
> +

...

dev_get_by_index() would be faster in fact.

Are you sure rcu_read_lock() is not possible ?

rcu_read_lock();
dev = rcu_dereference(po->active_device);
if (dev)
	dev_hold(dev);
rcu_read_unlock();
