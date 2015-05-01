From: Andrey Wagin <avagin@gmail.com>
Subject: Re: Netlink socket leaks
Date: Sat, 2 May 2015 02:31:09 +0300
Message-ID: <CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com>
References: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35234 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbbEAXbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 19:31:11 -0400
Received: by labbd9 with SMTP id bd9so72616325lab.2
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 16:31:09 -0700 (PDT)
In-Reply-To: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-05-01 13:22 GMT+03:00 Andrey Wagin <avagin@gmail.com>:
> Hi Herbert,
>
> I've found that netlink sockets start leaking after your patch:
> commit c428ecd1a21f1457ca3beb4df71b8a079c410e41
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Mar 20 21:57:01 2015 +1100
>
>     netlink: Move namespace into hash key
>
> Could you look at this?

A socket leaks if it is released by sk_release_kernel(). The problem
is that netlink_insert() and netlink_remove() is called when a socket
has different values of sk->sk_net.

The following patch fixes this problem, but I am not sure that it
breaks nothing else.
diff --git a/net/core/sock.c b/net/core/sock.c
index e891bcf..292f422 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1474,8 +1474,8 @@ void sk_release_kernel(struct sock *sk)
                return;

        sock_hold(sk);
-       sock_net_set(sk, get_net(&init_net));
        sock_release(sk->sk_socket);
+       sock_net_set(sk, get_net(&init_net));
        sock_put(sk);
 }
 EXPORT_SYMBOL(sk_release_kernel);

>
> It can be reproduced by the following script:
> ss -a | wc -l; ip netns add test && ip netns exec test ip a && ip
> netns del test ; ss -a | wc -l
>
> [root@jenkins ~]# uname -a
> Linux jenkins.criu.org 4.1.0-rc1-00117-g4a152c3 #46 SMP Fri May 1
> 14:09:02 MSK 2015 x86_64 x86_64 x86_64 GNU/Linux
>
>
> I have applied a patch with debug messages:
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 72c6b55..79aece4 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1081,7 +1081,9 @@ static int netlink_insert(struct sock *sk, u32 portid)
>                 if (err == -EEXIST)
>                         err = -EADDRINUSE;
>                 sock_put(sk);
> +               printk("%s:%d: %p\n", __func__, __LINE__, sk);
>         }
> +       printk("%s:%d: %p\n", __func__, __LINE__, sk);
>
>  err:
>         release_sock(sk);
> @@ -1097,7 +1099,9 @@ static void netlink_remove(struct sock *sk)
>                                     netlink_rhashtable_params)) {
>                 WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
>                 __sock_put(sk);
> +               printk("%s:%d: %p\n", __func__, __LINE__, sk);
>         }
> +       printk("%s:%d: %p\n", __func__, __LINE__, sk);
>
>         netlink_table_grab();
>         if (nlk_sk(sk)->subscriptions) {
>
> And here is the output
> [ 3868.202260] netlink_insert:1086: ffff8800d8c14000
> [ 3868.202962] netlink_insert:1086: ffff8800d8c15800
> [ 3868.202995] netlink_insert:1086: ffff8800d8c12000
> [ 3868.203228] netlink_insert:1086: ffff8800d8c16000
> [ 3868.203360] netlink_insert:1086: ffff8800d8c11000
> [ 3868.203920] netlink_insert:1086: ffff8800d8c13000
> [ 3868.203951] netlink_insert:1086: ffff8800d8c11800
> [ 3868.204216] netlink_insert:1086: ffff8800d8c17000
> [ 3868.205846] netlink_remove:1102: ffff8800d8c14000
> [ 3868.205849] netlink_remove:1104: ffff8800d8c14000
> [ 3868.208270] netlink_insert:1086: ffff8800d81d3800
> [ 3868.215363] netlink_remove:1102: ffff8800d81d3800
> [ 3868.215368] netlink_remove:1104: ffff8800d81d3800
> [ 3868.216465] netlink_insert:1086: ffff8800d8c0a000
> [ 3868.226320] netlink_remove:1102: ffff8800d8c0a000
> [ 3868.226324] netlink_remove:1104: ffff8800d8c0a000
> [ 3868.230662] netlink_insert:1086: ffff8800d8c0e800
> [ 3868.235906] netlink_remove:1102: ffff8800d8c0e800
> [ 3868.235910] netlink_remove:1104: ffff8800d8c0e800
> [ 3868.280231] netlink_remove:1104: ffff8800d8c17000
> [ 3868.280283] netlink_remove:1104: ffff8800d8c11800
> [ 3868.286152] netlink_remove:1104: ffff8800d8c13000
> [ 3868.318148] netlink_remove:1104: ffff8800d8c11000
> [ 3868.318185] netlink_remove:1104: ffff8800d8c16000
> [ 3868.318241] netlink_remove:1104: ffff8800d8c12000
> [ 3868.318255] netlink_remove:1104: ffff8800d8c15800
>
> So it looks like
>
> netlink_insert() returns zero, but then rhashtable_remove_fast()
> returns non-zero code
>
> Thanks,
> Andrew
