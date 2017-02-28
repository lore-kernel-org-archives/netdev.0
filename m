From: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 17:24:10 -0500
Message-ID: <20170228222410.GA32635@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com>
 <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
 <20170228163833.GI31155@oracle.com>
 <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Actually, I'm not sure if I can assert that these are all manifestations
of the same bug- was a netns-delete involved in this one as well?

I see:

> BUG: KASAN: use-after-free in memcmp+0xe3/0x160 lib/string.c:768 at
    :
>  memcmp+0xe3/0x160 lib/string.c:768
    :
>  rds_find_bound+0x4fe/0x8a0 net/rds/bind.c:63
>  rds_recv_incoming+0x5f3/0x12c0 net/rds/recv.c:349
>  rds_loop_xmit+0x1c5/0x490 net/rds/loop.c:82
    :
This appears to be for a looped back packet, and looks like there
are problems with  some rds_sock that got removed from the bind_hash_table..

According to the report, socket was created at
> Allocated:
> PID = 5235
    :
>  sk_prot_alloc+0x65/0x2a0 net/core/sock.c:1334
>  sk_alloc+0x105/0x1010 net/core/sock.c:1396
>  rds_create+0x11c/0x600 net/rds/af_rds.c:504

and closed at some point:
> Freed:
> PID = 5235
     :
>  rds_release+0x3a1/0x4d0 net/rds/af_rds.c:89
>  sock_release+0x8d/0x1e0 net/socket.c:599

This is all uspace created rds sockets, and while there may be an
unrelated bug here, I'm not sure I see  the netns/kernel-socket
connection.. can you please clarify if this was also seen in some netns
context?

--Sowmini





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
