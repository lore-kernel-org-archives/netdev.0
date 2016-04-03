From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Sat, 2 Apr 2016 19:33:49 -0700
Message-ID: <20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
 <1459551391-69969-4-git-send-email-kafai@fb.com>
 <CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39822 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750819AbcDCCeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 22:34:01 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 04:13:41PM -0700, Cong Wang wrote:
> On Fri, Apr 1, 2016 at 3:56 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> > +       bh_lock_sock(sk);
> > +       if (!sock_owned_by_user(sk))
> > +               ip6_datagram_dst_update(sk, false);
> > +       bh_unlock_sock(sk);
>
>
> My discussion with Eric shows that we probably don't need to hold
> this sock lock here, and you are Cc'ed in that thread, so
>
> 1) why do you still take the lock here?
> 2) why didn't you involve in our discussion if you disagree?
It is because I agree with the last thread discussion that updating
sk->sk_dst_cache does not need a sk lock.  I also don't see
a lock is need for other operations in that thread.

I am thinking another case that needs a lock, so I start
another RFC thread.  A quick recall for this commit message:
>> It is done under '!sock_owned_by_user(sk)' condition because
>> the user may make another ip6_datagram_connect() while
>> dst lookup and update are happening.
If that could not happen, then the lock is not needed.

One thing to note is that this patch uses the addresses from the sk
instead of iph when updating sk->sk_dst_cache.  It is basically the
same logic that the __ip6_datagram_connect() is doing, so some
refactoring works in the first two patches.

AFAIK, a UDP socket can become connected after sending out some
datagrams in un-connected state.  or It can be connected
multiple times to different destinations.  I did some quick
tests but I could be wrong.

I am thinking if there could be a chance that the skb->data, which
has the original outgoing iph, is not related to the current
connected address.  If it is possible, we have to specifically
use the addresses in the sk instead of skb->data (i.e. iph) when
updating the sk->sk_dst_cache.

If we need to use the sk addresses (and other info) to find out a
new dst for a connected udp socket, it is better not doing it while
the userland is connecting to somewhere else.

If the above case is impossible, we can keep using the info from iph to
do the dst update for a connected-udp sk without taking the lock.

>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index ed44663..f7e6a6d 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1417,8 +1417,19 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);
>>
>>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>>  {
>> +	struct dst_entry *dst;
>> +
>>  	ip6_update_pmtu(skb, sock_net(sk), mtu,
>>  			sk->sk_bound_dev_if, sk->sk_mark);
iph's addresses are used to update the pmtu.  It is fine
because it does not update the sk->sk_dst_cache.

>>> +
>> +	dst = __sk_dst_get(sk);
>> +	if (!dst || dst->ops->check(dst, inet6_sk(sk)->dst_cookie))
>> +		return;
>> +
>> +	bh_lock_sock(sk);
>> +	if (!sock_owned_by_user(sk))
sk is not connecting to another address.  Find a new dst
for the connected address.
>> +		ip6_datagram_dst_update(sk, false);
>> +	bh_unlock_sock(sk);
>>  }
