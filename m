From: Wakko Warner <wakko@animx.eu.org>
Subject: Re: [PATCH net] ipv4: only create late gso-skb if skb is already set
 up with CHECKSUM_PARTIAL
Date: Thu, 25 Feb 2016 19:45:49 -0500
Message-ID: <20160226004549.GA670@animx.eu.org>
References: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
 <20160226000706.GA25882@animx.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tn-76-7-162-101.sta.embarqhsd.net ([76.7.162.101]:40875 "EHLO
	animx.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbcBZApv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 19:45:51 -0500
Content-Disposition: inline
In-Reply-To: <20160226000706.GA25882@animx.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wakko Warner wrote:
> Hannes Frederic Sowa wrote:
> > Otherwise we break the contract with GSO to only pass CHECKSUM_PARTIAL
> > skbs down. This can easily happen with UDP+IPv4 sockets with the first
> > MSG_MORE write smaller than the MTU, second write is a sendfile.
> > 
> > Returning -EOPNOTSUPP lets the callers fall back into normal sendmsg path,
> > were we calculate the checksum manually during copying.
> > 
> > Commit d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked
> > sockets") started to exposes this bug.
> > 
> > Fixes: d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")
> > Reported-by: Jiri Benc <jbenc@redhat.com>
> > Cc: Jiri Benc <jbenc@redhat.com>
> > Reported-by: Wakko Warner <wakko@animx.eu.org>
> > Cc: Wakko Warner <wakko@animx.eu.org>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> I just tested this with 2 of my VMs.  It appears to have fixed the issue.

Now there's another one:
[  777.315931] ------------[ cut here ]------------
[  777.316099] WARNING: CPU: 0 PID: 1404 at /usr/src/linux/dist/4.4-nobklcd/net/ipv4/af_inet.c:155 inet_sock_destruct+0x1cb/0x1f0()
[  777.316189] Modules linked in: nfsv3 af_packet scsi_transport_iscsi nfsd auth_rpcgss oid_registry exportfs nfs lockd grace sunrpc ipv6 ata_piix libata evdev virtio_balloon virtio_net unix
[  777.316416] CPU: 0 PID: 1404 Comm: kworker/0:1H Not tainted 4.4.0 #2
[  777.316468] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  777.316547] Workqueue: rpciod xprt_autoclose [sunrpc]
[  777.316598]  ffffffff815053f0 ffffffff811d46ee 0000000000000000 ffffffff81041383
[  777.316680]  ffff88003d268b40 ffff88003d268cc0 ffff88003d07b3f8 ffff88003d07b368
[  777.316763]  0000000000000000 ffffffff8136f53b ffff88003d268b40 ffff8800160f2d40
[  777.316845] Call Trace:
[  777.316868]  [<ffffffff811d46ee>] ? dump_stack+0x47/0x69
[  777.316911]  [<ffffffff81041383>] ? warn_slowpath_common+0x73/0xa0
[  777.316963]  [<ffffffff8136f53b>] ? inet_sock_destruct+0x1cb/0x1f0
[  777.317018]  [<ffffffff812fe003>] ? sk_destruct+0x13/0xc0
[  777.317061]  [<ffffffff8136e301>] ? inet_release+0x31/0x50
[  777.317108]  [<ffffffff812f7ad5>] ? sock_release+0x15/0x70
[  777.317153]  [<ffffffffa00c6109>] ? xs_close+0x9/0x20 [sunrpc]
[  777.317206]  [<ffffffffa00c40bd>] ? xprt_autoclose+0x2d/0x60 [sunrpc]
[  777.317261]  [<ffffffff81054be9>] ? process_one_work+0x129/0x3f0
[  777.317313]  [<ffffffff81054ef2>] ? worker_thread+0x42/0x490
[  777.317367]  [<ffffffff81054eb0>] ? process_one_work+0x3f0/0x3f0
[  777.317421]  [<ffffffff81059ae8>] ? kthread+0xb8/0xd0
[  777.317465]  [<ffffffff81059a30>] ? kthread_worker_fn+0x100/0x100
[  777.317521]  [<ffffffff813a29bf>] ? ret_from_fork+0x3f/0x70
[  777.317564]  [<ffffffff81059a30>] ? kthread_worker_fn+0x100/0x100
[  777.317618] ---[ end trace 220e17a0bf3ec971 ]---

This one happened on the client side VM.  There was only 1 NFS mount.  The
server VM didn't show anything nor did the host.

> > ---
> >  net/ipv4/ip_output.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 64878efa045c13..565bf64b2b7d60 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -1236,13 +1236,16 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
> >  	if (!skb)
> >  		return -EINVAL;
> >  
> > -	cork->length += size;
> >  	if ((size + skb->len > mtu) &&
> >  	    (sk->sk_protocol == IPPROTO_UDP) &&
> >  	    (rt->dst.dev->features & NETIF_F_UFO)) {
> > +		if (skb->ip_summed != CHECKSUM_PARTIAL)
> > +			return -EOPNOTSUPP;
> > +
> >  		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
> >  		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> >  	}
> > +	cork->length += size;
> >  
> >  	while (size > 0) {
> >  		if (skb_is_gso(skb)) {
> > -- 
> > 2.5.0
> > 
> -- 
>  Microsoft has beaten Volkswagen's world record.  Volkswagen only created 22
>  million bugs.
-- 
 Microsoft has beaten Volkswagen's world record.  Volkswagen only created 22
 million bugs.
