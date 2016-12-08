From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 4/4] udp: add batching to udp_rmem_release()
Date: Thu, 8 Dec 2016 10:52:58 -0800
Message-ID: <CANn89iJv202k-3bq=+MP74uTiMib_T9dz-OscHk=B1A=YDWyMQ@mail.gmail.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
 <1481218739-27089-5-git-send-email-edumazet@google.com> <1481221491.6120.11.camel@redhat.com>
 <CANn89iL8r9UD=sGn3WxVFZ+Z_QJYYM6aXxCFvafwvJ-bEtNhKQ@mail.gmail.com> <CANn89i+10fwMQ+oqs2AgVfE9CHnpZqecN_NxVqobyzD1riyMfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33410 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbcLHSxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:53:00 -0500
Received: by mail-io0-f170.google.com with SMTP id d9so16284832ioe.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:52:59 -0800 (PST)
In-Reply-To: <CANn89i+10fwMQ+oqs2AgVfE9CHnpZqecN_NxVqobyzD1riyMfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 10:38 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Thu, Dec 8, 2016 at 10:36 AM, Eric Dumazet <edumazet@google.com> wrote:
>> On Thu, Dec 8, 2016 at 10:24 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>
>>> Nice one! This sounds like a relevant improvement!
>>>
>>> I'm wondering if it may cause regressions with small value of
>>> sk_rcvbuf ?!? e.g. with:
>>>
>>> netperf -t UDP_STREAM  -H 127.0.0.1 -- -s 1280 -S 1280 -m 1024 -M 1024
>>>
>>
>> Possibly, then simply we can refine the test to :
>>
>> size = up->forward_deficit;
>> if (size < (sk->sk_rcvbuf >> 2)  && !skb_queue_empty(sk->sk_receive_buf))
>>      return;
>

I will also add this patch :

This really makes sure our changes to sk_forward_alloc wont be slowed
because producers see
the change to sk_rmem_alloc too soon.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8400d6954558..6bdcbe103390 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1191,13 +1191,14 @@ static void udp_rmem_release(struct sock *sk,
int size, int partial)
        }
        up->forward_deficit = 0;

-       atomic_sub(size, &sk->sk_rmem_alloc);
        sk->sk_forward_alloc += size;
        amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
        sk->sk_forward_alloc -= amt;

        if (amt)
                __sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
+
+       atomic_sub(size, &sk->sk_rmem_alloc);
 }

 /* Note: called with sk_receive_queue.lock held.
