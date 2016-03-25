From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on
 pmtu events if possible
Date: Thu, 24 Mar 2016 17:15:18 -0700
Message-ID: <CAM_iQpVDN_LPsa2XgVWoqMjrOYpg9JNjPJVwEvTuxPgYyWRWmg@mail.gmail.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
	<1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Wei Wang <weiwan@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:34604 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbcCYAPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 20:15:19 -0400
Received: by mail-yw0-f175.google.com with SMTP id h129so80659880ywb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 17:15:19 -0700 (PDT)
In-Reply-To: <1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 1:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-03-24 at 12:25 -0700, Cong Wang wrote:
>
>>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>>  {
>> -     ip6_update_pmtu(skb, sock_net(sk), mtu,
>> -                     sk->sk_bound_dev_if, sk->sk_mark);
>> +     const struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
>> +     struct net *net = sock_net(sk);
>> +     struct dst_entry *ndst, *dst;
>> +     struct flowi6 fl6;
>> +     bool new = false;
>> +
>> +     memset(&fl6, 0, sizeof(fl6));
>> +
>> +     bh_lock_sock(sk);
>> +
>
>
> This is not clear why you need to acquire socket lock.
>
> sk_dst_cache is protected by an atomic operation.
>
> udp for example calls ip6_dst_store() without socket being locked.

My understanding is that bh_lock_sock() prevents concurrent
access to sock struct. Since this is in softirq context, multiple
CPU's could call this function concurrently, the whole pmtu
update needs to be done atomically.

UDP, on the other hand, doesn't do this logic, it just looks up
for dst and save it in sk_dst_cache.
