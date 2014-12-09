From: Dann Frazier <dann.frazier@canonical.com>
Subject: Re: [bisect] 3.18 oops in tcp_v4_send_reset()
Date: Tue, 9 Dec 2014 10:10:08 -0700
Message-ID: <CALdTtnuazPdMNsOHzzersmyHvLjwxSq1BZoA5ZAdU-0QZtwUsg@mail.gmail.com>
References: <20141209160023.GA31520@fluid.dannf>
	<1418141783.14835.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<1418141914.14835.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<1418142520.14835.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:39411 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbaLIRKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 12:10:10 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so2449445wiw.3
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 09:10:08 -0800 (PST)
In-Reply-To: <1418142520.14835.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 9:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-12-09 at 08:18 -0800, Eric Dumazet wrote:
>> On Tue, 2014-12-09 at 08:16 -0800, Eric Dumazet wrote:
>> > On Tue, 2014-12-09 at 09:00 -0700, dann frazier wrote:
>> > > I'm observing a very reproducible oops which I have bisected down to
>> > > commit ca777ef:
>>
>> >
>> > Following patch should have fixed this
>> >
>> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c3658e8d0f10147fc86018be7f11668246c156d3
>> >
>>
>> Oh well, fix was not complete. I'll submit a followup patch.
>>
>
> Could you try following fix before I send official patch ?

This patch does appear to resolve the issue, thanks Eric!

 -dann

> Thanks !
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 33f5ff068c7958515e0f63792883a58fb5d6a341..a3f72d7fc06c07c43e1c00b67970eaee074e4593 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -623,6 +623,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
>         arg.iov[0].iov_base = (unsigned char *)&rep;
>         arg.iov[0].iov_len  = sizeof(rep.th);
>
> +       net = sk ? sock_net(sk) : dev_net(skb_dst(skb)->dev);
>  #ifdef CONFIG_TCP_MD5SIG
>         hash_location = tcp_parse_md5sig_option(th);
>         if (!sk && hash_location) {
> @@ -633,7 +634,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
>                  * Incoming packet is checked with md5 hash with finding key,
>                  * no RST generated if md5 hash doesn't match.
>                  */
> -               sk1 = __inet_lookup_listener(dev_net(skb_dst(skb)->dev),
> +               sk1 = __inet_lookup_listener(net,
>                                              &tcp_hashinfo, ip_hdr(skb)->saddr,
>                                              th->source, ip_hdr(skb)->daddr,
>                                              ntohs(th->source), inet_iif(skb));
> @@ -681,7 +682,6 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
>         if (sk)
>                 arg.bound_dev_if = sk->sk_bound_dev_if;
>
> -       net = dev_net(skb_dst(skb)->dev);
>         arg.tos = ip_hdr(skb)->tos;
>         ip_send_unicast_reply(net, skb, &TCP_SKB_CB(skb)->header.h4.opt,
>                               ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
>
>
