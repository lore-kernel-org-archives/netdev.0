From: Patrick McHardy <kaber@trash.net>
Subject: Re: deleting a conntrack record
Date: Thu, 17 Jun 2004 18:02:16 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <40D1C088.4090307@trash.net>
References: <876ef97a0406170807663b89e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, linux-net <linux-net@vger.kernel.org>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Tobias DiPasquale <codeslinger@gmail.com>
In-Reply-To: <876ef97a0406170807663b89e0@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Tobias DiPasquale wrote:
> Hello all,
> 
> I have a module that exports a /proc entry which takes a string with 4
> args in it (src IP/port and dst IP/port) and then attempts to delete
> the conntrack entry for the TCP connection associated with those
> arguments. Here's the code in question (keep reading past the code for
> a description of the problem I'm having):
> 
> <code>
> static inline int kill_ct_record( const struct ip_conntrack *c, void *p)
> {
>        struct ip_conntrack *q = (struct ip_conntrack *)p;
> 
>        if (!memcmp( &c->tuplehash[IP_CT_DIR_ORIGINAL],
>                     &q->tuplehash[IP_CT_DIR_ORIGINAL],
>                     sizeof( struct ip_conntrack_tuple_hash))) {
>                ip_conntrack_put( q);
>                return 1;
>        }
>        return 0;
> }
> 
> static int delete_ct_record( u_int32_t src, u_int16_t sport, u_int32_t
> dst, u_int16_t dport)
> {
>        struct ip_conntrack_tuple tuple;
>        struct ip_conntrack_tuple_hash *h;
> 
>        memset( &tuple, 0, sizeof( tuple));
>        tuple.src.ip = src;
>        tuple.src.u.tcp.port = sport;
>        tuple.dst.ip = dst;
>        tuple.dst.u.tcp.port = dport;
>        tuple.dst.protonum = IPPROTO_TCP;
>        h = ip_conntrack_find_get( &tuple, NULL);
>        if (!h)
>                return -ENOENT;
>        ip_ct_selective_cleanup( kill_ct_record, h->ctrack);
>        return 1;
> }
> </code>
> 
> The problem is as follows:
> 
> There is a userspace script that runs from cron every 5 minutes. It
> looks through the /proc/net/ip_conntrack listing to see if any 
> connections are "stale" (i.e. haven't seen a packet from them in
> some amount of time). It then feeds their connection information
> into my module's /proc entry so that those conntrack records can
> be destroyed.

Why don't you just adjust the timeout values in
/proc/sys/net/ipv4/netfilter ?

> 
> In the kill_ct_record() function in the module, if the 
> ip_conntrack_put() call is not commented out, this causes the box 
> to go into some infinite loop after some unspecified amount of time. 
> There is no LKCD dump and I don't know what happened since I wasn't 
> physically present for the crash in any of the instances.
> 
> On the other hand, when the ip_conntrack_put() call _is_ commented
> out, the system leaks memory from conntrack as indicated in the
> ip_conntrack line in /proc/slabinfo. But the crash doesn't happen
> under that condition.

The function passed to ip_ct_selective_cleanup is supposed to decide
if a conntrack should be destroyed by returning 0/1, not to do it
itself. ip_ct_selective_cleanup tries to destroy the already destroyed
conntrack.

> 
> So, is there a cleaner way to hand-delete a conntrack record? Or is
> this the only method? Or is there some error in the way that I am
> doing the above?
> 
> By the way, this is almost exactly what ctnetlink does to delete a
> conntrack record so any errors discovered here will almost surely have
> to be fixed there, as well.
> 

Thanks for pointing that out, I've fixed the ctnetlink code.

Regards
Patrick
