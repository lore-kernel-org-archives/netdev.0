From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv3 net-next 2/4] ipv4: Use binary search to choose tcp
 PMTU probe_size
Date: Mon, 02 Mar 2015 17:29:50 +0800
Message-ID: <54F42D8E.2050601@gmail.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com> <1425093785-27380-3-git-send-email-fan.du@intel.com> <CABrhC0=ZPJwPOJFkuuJ+pJgn4CoVhZ2tJcrbce6kytVVtsy=9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, edumazet@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33814 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbbCBJeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 04:34:50 -0500
Received: by pabrd3 with SMTP id rd3so42200754pab.1
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 01:34:49 -0800 (PST)
In-Reply-To: <CABrhC0=ZPJwPOJFkuuJ+pJgn4CoVhZ2tJcrbce6kytVVtsy=9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8801=E6=97=A5 07:20, John Heffner =E5=86=
=99=E9=81=93:
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index a2a796c..c418829 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -1837,11 +1837,13 @@ static int tcp_mtu_probe(struct sock *sk)
>>          struct tcp_sock *tp =3D tcp_sk(sk);
>>          struct inet_connection_sock *icsk =3D inet_csk(sk);
>>          struct sk_buff *skb, *nskb, *next;
>> +       struct net *net =3D sock_net(sk);
>>          int len;
>>          int probe_size;
>>          int size_needed;
>>          int copy;
>>          int mss_now;
>> +       int interval;
>>
>>          /* Not currently probing/verifying,
>>           * not in recovery,
>> @@ -1854,11 +1856,17 @@ static int tcp_mtu_probe(struct sock *sk)
>>              tp->rx_opt.num_sacks || tp->rx_opt.dsack)
>>                  return -1;
>>
>> -       /* Very simple search strategy: just double the MSS. */
>> +       /* Use binary search for probe_size bewteen tcp_mss_base,
>> +        * and current mss_clamp. if (search_high - search_low)
>> +        * smaller than a threshold, backoff from probing.
>> +        */
>>          mss_now =3D tcp_current_mss(sk);
>> -       probe_size =3D 2 * tp->mss_cache;
>> +       probe_size =3D (icsk->icsk_mtup.search_high +
>> +                     icsk->icsk_mtup.search_low) >> 1;
>>          size_needed =3D probe_size + (tp->reordering + 1) * tp->mss=
_cache;
>> -       if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_h=
igh)) {
>> +       interval =3D icsk->icsk_mtup.search_high - icsk->icsk_mtup.s=
earch_low;
>> +       if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_h=
igh) ||
>> +           interval < net->ipv4.sysctl_tcp_probe_threshold) {
>>                  /* TODO: set timer for probe_converge_event */
>>                  return -1;
>>          }
>
> A couple things: the local variable probe_size here is TCP segment
> size, while search_low and search_high are IP datagram sizes.  Use
> tcp_mtu_to_mss to subtract headers.  Also, I think if you set
> sysctl_tcp_probe_threshold <=3D 0, this will keep probing indefinitel=
y
> at search_low (not useful).  You probably want to test interval <
> max(1, sysctl_tcp_probe_threshold).
Thanks for the comments, will update in next version.
btw, I'm little confused about two points here:

1. Checking if there is enough user data available in write queue with =
size_needed,
    Is there any special consideration here involving (tp->reordering +=
 1) * tp->mss_cache ?
    Since the assembly always copies "probe_size" bytes data from the w=
rite queue.

    size_needed =3D probe_size + (tp->reordering + 1) * tp->mss_cache;

2. Traverse write queue to build probing packet with "probe_size" bytes=
 segment,
    when will the final nskb len exceeding probe_size? which trigger th=
e break in line:1971

1971                 if (len >=3D probe_size)
1972                         break;
1973         }
1974         tcp_init_tso_segs(sk, nskb, nskb->len);


>    -John
>
