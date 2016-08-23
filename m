From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net-next] net: diag: support SOCK_DESTROY for UDP
 sockets
Date: Tue, 23 Aug 2016 11:02:00 -0600
Message-ID: <417574bb-d15d-f347-d951-49d0eede02c0@cumulusnetworks.com>
References: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr19f3E-z4Lat-YDwJ7U7-fmVBeissz08dsk2o+196OQRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35354 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753719AbcHWRCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 13:02:03 -0400
Received: by mail-pa0-f46.google.com with SMTP id hb8so31329162pac.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 10:02:03 -0700 (PDT)
In-Reply-To: <CAKD1Yr19f3E-z4Lat-YDwJ7U7-fmVBeissz08dsk2o+196OQRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/16 10:37 AM, Lorenzo Colitti wrote:
> On Wed, Aug 24, 2016 at 12:02 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> +int udp_abort(struct sock *sk, int err)
>> +{
>> +       lock_sock(sk);
>> +
>> +       sk->sk_err = err;
>> +       sk->sk_error_report(sk);
>> +       udp_disconnect(sk, 0);
> 
> I notice that udp_disconnect does "inet->inet_daddr = 0" but doesn't
> touch sk_v6_daddr. I wonder if that's correct. Even if it isn't,
> that's likely not specific to this patch, since udpv6_prot specifies
> udp_disconnect as its disconnect function pointer.

ack. can send a separate patch for that one.

> 
>> +       if (req->sdiag_family == AF_INET)
>> +               sk = __udp4_lib_lookup(net,
>> +                               req->id.idiag_dst[0], req->id.idiag_dport,
>> +                               req->id.idiag_src[0], req->id.idiag_sport,
>> +                               req->id.idiag_if, tbl, NULL);
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +       else if (req->sdiag_family == AF_INET6)
>> +               sk = __udp6_lib_lookup(net,
> 
> I think you need to check for mapped addresses like Eric added to
> inet_diag_find_one_icsk in 7c1306723 .
> 
>> +                               (struct in6_addr *)req->id.idiag_dst,
>> +                               req->id.idiag_dport,
>> +                               (struct in6_addr *)req->id.idiag_src,
>> +                               req->id.idiag_sport,
>> +                               req->id.idiag_if, tbl, NULL);
>> +#endif
> 
> If you want to be consistent with what the TCP code does, return
> -EINVAL here instead of -ENOENT if an invalid address family was
> passed in (e.g., if user passes in AF_INET6 and IPv6 is not compiled
> in).

ok, I'll make this lookup mirror inet_diag_find_one_icsk. That handles these 2 comments.

> 
>> +       if (sock_diag_check_cookie(sk, req->id.idiag_cookie)) {
>> +               sock_put(sk);
>> +               return -ENOENT;
>> +       }
>> +
>> +       return sock_diag_destroy(sk, ECONNABORTED);
> 
> Looking at the code again, it seems that there's a bug in
> sock_diag_destroy. If the destroy operation does not occur (e.g., if
> sock_diag_destroy returns EPERM, or the protocol doesn't support
> destroy), then it doesn't release the refcount. This affects the TCP
> code as well and as such is my fault, not yours. The most obvious way
> to fix this might be to call sock_gen_put in sock_diag_destroy.

sock_gen_put seems specific to tcp which is why I used sock_put here. Perhaps better to have the callers of sock_diag_destroy handle the refcnt? This function took it; it should release it success or fail. Same for tcp.
