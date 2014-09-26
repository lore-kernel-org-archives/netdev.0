From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] fclone layout suboptimal
Date: Fri, 26 Sep 2014 06:07:39 -0700
Message-ID: <1411736859.16953.121.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49729 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbaIZNHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 09:07:41 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so2627527pad.29
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 06:07:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ast clones have following layout :

[sk_buff 1]
[sk_buff 2]
[atomic_t fclone_ref]


Main consumer is TCP stack for its write queue.

When tcp_ack()/tcp_clean_rtx_queue() frees skb,
kfree_skbmem() needs to fetch a cold cache line :

  0.72 =E2=94=82      je     b0
       =E2=94=826f:   add    $0x8,%rsp
       =E2=94=82      pop    %rbx
  0.07 =E2=94=82      pop    %rbp
       =E2=94=82      retq
       =E2=94=82      nop
  0.52 =E2=94=8280:   lock   decl   0x1b0(%rbx)
 90.23 =E2=94=82   =E2=94=8C=E2=94=80=E2=94=80je     90
       =E2=94=82   =E2=94=82  jmp    6f
       =E2=94=82   =E2=94=82  nop
       =E2=94=8290:=E2=94=94=E2=94=80 mov    0x5c4e29(%rip),%rdi
       =E2=94=82      mov    %rbx,%rsi
       =E2=94=82      callq  kmem_cache_free
  1.37 =E2=94=82      add    $0x8,%rsp
       =E2=94=82      pop    %rbx
       =E2=94=82      pop    %rbp
  0.91 =E2=94=82      retq
       =E2=94=82      nop
       =E2=94=82b0:   mov    0x5c4e09(%rip),%rdi
       =E2=94=82      lea    -0xd8(%rbx),%rsi
       =E2=94=82      callq  kmem_cache_free

It might be better to have :

[sk_buff skb1]
[atomic_t fclone_ref]
[sk_buff skb2]

__alloc(skb) would not have to dirty a cache line to perform the
atomic_set(fclone_ref, 1);

kfree_skbmem() would do the atomic_dec_and_test() on a hot cache line
(Because we had access to skb_shinfo() a bit earlier while doing
skb_release_all()

When TX completions has to free the cloned sk_buff, fetching fclone_ref
would use an already hot cache line as well (skb2->next / skb2->sk are
already in cpu cache)
