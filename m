From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net 2/2] geneve: Fix races between socket add and release.
Date: Wed, 17 Dec 2014 10:48:40 -0800
Message-ID: <CAEP_g=_-hgeosH83FdPZLb9mvi5DSW6mbe+Xe5x0YoR7mKaTPA@mail.gmail.com>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
 <1418783132-99230-2-git-send-email-jesse@nicira.com> <20141217165454.GE28766@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:42126 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750954AbaLQStB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:49:01 -0500
Received: by mail-qa0-f49.google.com with SMTP id s7so11349039qap.8
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:49:00 -0800 (PST)
In-Reply-To: <20141217165454.GE28766@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 8:54 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/16/14 at 06:25pm, Jesse Gross wrote:
>> diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
>> index 5a47188..95e47c9 100644
>> --- a/net/ipv4/geneve.c
>> +++ b/net/ipv4/geneve.c
>> @@ -296,6 +296,7 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
>>                                   geneve_rcv_t *rcv, void *data,
>>                                   bool no_share, bool ipv6)
>>  {
>> +     struct geneve_net *gn = net_generic(net, geneve_net_id);
>>       struct geneve_sock *gs;
>>
>>       gs = geneve_socket_create(net, port, rcv, data, ipv6);
>> @@ -305,15 +306,15 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
>>       if (no_share)   /* Return error if sharing is not allowed. */
>>               return ERR_PTR(-EINVAL);
>>
>> +     spin_lock(&gn->sock_lock);
>>       gs = geneve_find_sock(net, port);
>
> Perhaps remove the _rcu of the iterator in the geneve_find_sock?
> Also, the kfree_rcu() seems no longer needed as all read accesses
> are protected by the spinlock.
>
>> -     if (gs) {
>> -             if (gs->rcv == rcv)
>> -                     atomic_inc(&gs->refcnt);
>> -             else
>> +     if (gs && ((gs->rcv != rcv) ||
>> +                !atomic_add_unless(&gs->refcnt, 1, 0)))
>>                       gs = ERR_PTR(-EBUSY);
>
> Since you are taking gn->sock_lock in geneve_sock_release()
> anyway, all accesses to refcnt could eventually be converted
> to non-atomic ops.

I generally agree (with the exception of kfree_rcu() - I believe that
is still needed since incoming packets reference it using RCU).
However, since this patch is targeted a net- I wanted to make a
minimal change and not completely redo the locking. A lot of the
locking here was pulled over from VXLAN and I think it can be
simplified since I don't expect that the Geneve code will bring in all
of that logic.

The one part that is not entirely clear is the workqueue in VXLAN used
for destroying the socket. This was added by Stephen in "vxlan: listen
on multiple ports" but it's not obvious to me what problem it is
trying to avoid and I don't see a comment. If possible, it would be
nice to simplify this as well if the issue doesn't apply to Geneve.
