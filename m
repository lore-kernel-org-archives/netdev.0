From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net-next] net: diag: support SOCK_DESTROY for UDP
 sockets
Date: Tue, 23 Aug 2016 11:16:57 -0600
Message-ID: <e0d15dd5-28d1-6df5-c62c-1cc272a6a164@cumulusnetworks.com>
References: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr19f3E-z4Lat-YDwJ7U7-fmVBeissz08dsk2o+196OQRQ@mail.gmail.com>
 <417574bb-d15d-f347-d951-49d0eede02c0@cumulusnetworks.com>
 <CAKD1Yr0FM9YKHFTYMeYipvyTWDLoM8EvcxVpcYwAWFHQZuS+6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36554 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751032AbcHWRQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 13:16:59 -0400
Received: by mail-pf0-f182.google.com with SMTP id h186so45487087pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 10:16:59 -0700 (PDT)
In-Reply-To: <CAKD1Yr0FM9YKHFTYMeYipvyTWDLoM8EvcxVpcYwAWFHQZuS+6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/16 11:13 AM, Lorenzo Colitti wrote:
> On Wed, Aug 24, 2016 at 2:02 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> Looking at the code again, it seems that there's a bug in
>>> sock_diag_destroy. If the destroy operation does not occur (e.g., if
>>> sock_diag_destroy returns EPERM, or the protocol doesn't support
>>> destroy), then it doesn't release the refcount. This affects the TCP
>>> code as well and as such is my fault, not yours. The most obvious way
>>> to fix this might be to call sock_gen_put in sock_diag_destroy.
>>
>> sock_gen_put seems specific to tcp which is why I used sock_put here.
> 
> I thought sock_gen_put can be used on UDP as well, but it does seem a
> bit counterintuitive.
> 
>> Perhaps better to have the callers of sock_diag_destroy handle the refcnt? This
>> function took it; it should release it success or fail. Same for tcp.
> 
> So you'd remove the sock_put and sock_gen_put calls from tcp_abort and
> just add one sock_gen_put in tcp_diag_destroy? That does seem simpler.
> 

untested and mangled on a copy and paste but the intent is:

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f1a9a0a8a1f3..54c5d0a8f6e9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3176,7 +3176,6 @@ int tcp_abort(struct sock *sk, int err)
                        local_bh_enable();
                        return 0;
                }
-               sock_gen_put(sk);
                return -EOPNOTSUPP;
        }

@@ -3205,7 +3204,6 @@ int tcp_abort(struct sock *sk, int err)
        bh_unlock_sock(sk);
        local_bh_enable();
        release_sock(sk);
-       sock_put(sk);
        return 0;
 }
 EXPORT_SYMBOL_GPL(tcp_abort);
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 4d610934fb39..a748c74aa8b7 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -54,11 +54,16 @@ static int tcp_diag_destroy(struct sk_buff *in_skb,
 {
        struct net *net = sock_net(in_skb->sk);
        struct sock *sk = inet_diag_find_one_icsk(net, &tcp_hashinfo, req);
+       int err;

        if (IS_ERR(sk))
                return PTR_ERR(sk);

-       return sock_diag_destroy(sk, ECONNABORTED);
+       err = sock_diag_destroy(sk, ECONNABORTED);
+
+       sock_gen_put(sk);     <---- if (!sk_fullsock(sk)) needed here? seems like this works for all TCP
+
+       return err;
 }
 #endif
