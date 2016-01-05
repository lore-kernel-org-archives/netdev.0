From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next] soreuseport: change consume_skb to kfree_skb in
 error case
Date: Tue, 5 Jan 2016 12:47:44 -0500
Message-ID: <CAEfhGiyu0iRJcnOUiippoOtRZzUwoSihGVb3240G9hBSh0t5bw@mail.gmail.com>
References: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
	<1452015516.8255.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:33197 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbcAERrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:47:47 -0500
Received: by mail-lb0-f196.google.com with SMTP id bc4so11117079lbc.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:47:46 -0800 (PST)
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com. [209.85.217.179])
        by smtp.gmail.com with ESMTPSA id d18sm660094lfb.1.2016.01.05.09.47.44
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 09:47:44 -0800 (PST)
Received: by mail-lb0-f179.google.com with SMTP id sv6so171353266lbb.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:47:44 -0800 (PST)
In-Reply-To: <1452015516.8255.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 5, 2016 at 12:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-01-05 at 10:57 -0500, Craig Gallek wrote:
>> From: Craig Gallek <kraig@google.com>
>>
>> Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
>> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
>> Signed-off-by: Craig Gallek <kraig@google.com>
>> ---
>>  net/core/sock_reuseport.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
>> index ae0969c0fc2e..1df98c557440 100644
>> --- a/net/core/sock_reuseport.c
>> +++ b/net/core/sock_reuseport.c
>> @@ -173,7 +173,7 @@ static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
>>
>>       /* temporarily advance data past protocol header */
>>       if (!pskb_pull(skb, hdr_len)) {
>> -             consume_skb(nskb);
>> +             kfree_skb(nskb);
>>               return NULL;
>>       }
>>       index = bpf_prog_run_save_cb(prog, skb);
>
> Note that we always call reuseport_select_sock() after pulling the
> headers in skb->head anyway, so the pskb_pull() can never fail.
>
> It really could be __skb_pull()
>
> BTW, why UDP calls reuseport_select_sock() with hdr_len == 0 sometimes ?
hdr_len only matters when you have an skb to work with.  In both of
the call sites of your suggested patch, NULL is passed for the skb
parameter so hdr_len is never used.  When no skb is available, the
code falls back to the hash-based method used in the non-BPF case.

> I believe the following patch is needed.
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 835378365f25..52387096dbba 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -514,7 +514,8 @@ begin:
>                                 struct sock *sk2;
>                                 hash = udp_ehashfn(net, daddr, hnum,
>                                                    saddr, sport);
> -                               sk2 = reuseport_select_sock(sk, hash, NULL, 0);
> +                               sk2 = reuseport_select_sock(sk, hash, NULL,
> +                                                           sizeof(struct udphdr));
>                                 if (sk2) {
>                                         result = sk2;
>                                         goto found;
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 56fcb55fda31..da0a5fa02b0f 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -272,7 +272,8 @@ begin:
>                                 struct sock *sk2;
>                                 hash = udp6_ehashfn(net, daddr, hnum,
>                                                     saddr, sport);
> -                               sk2 = reuseport_select_sock(sk, hash, NULL, 0);
> +                               sk2 = reuseport_select_sock(sk, hash, NULL,
> +                                                           sizeof(struct udphdr));
>                                 if (sk2) {
>                                         result = sk2;
>                                         goto found;
>
>
