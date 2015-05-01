From: Andrey Wagin <avagin@gmail.com>
Subject: Netlink socket leaks
Date: Fri, 1 May 2015 13:22:15 +0300
Message-ID: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34129 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbEAKWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 06:22:17 -0400
Received: by lbcga7 with SMTP id ga7so62484092lbc.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 03:22:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

I've found that netlink sockets start leaking after your patch:
commit c428ecd1a21f1457ca3beb4df71b8a079c410e41
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Mar 20 21:57:01 2015 +1100

    netlink: Move namespace into hash key

Could you look at this?

It can be reproduced by the following script:
ss -a | wc -l; ip netns add test && ip netns exec test ip a && ip
netns del test ; ss -a | wc -l

[root@jenkins ~]# uname -a
Linux jenkins.criu.org 4.1.0-rc1-00117-g4a152c3 #46 SMP Fri May 1
14:09:02 MSK 2015 x86_64 x86_64 x86_64 GNU/Linux


I have applied a patch with debug messages:
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 72c6b55..79aece4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1081,7 +1081,9 @@ static int netlink_insert(struct sock *sk, u32 portid)
                if (err == -EEXIST)
                        err = -EADDRINUSE;
                sock_put(sk);
+               printk("%s:%d: %p\n", __func__, __LINE__, sk);
        }
+       printk("%s:%d: %p\n", __func__, __LINE__, sk);

 err:
        release_sock(sk);
@@ -1097,7 +1099,9 @@ static void netlink_remove(struct sock *sk)
                                    netlink_rhashtable_params)) {
                WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
                __sock_put(sk);
+               printk("%s:%d: %p\n", __func__, __LINE__, sk);
        }
+       printk("%s:%d: %p\n", __func__, __LINE__, sk);

        netlink_table_grab();
        if (nlk_sk(sk)->subscriptions) {

And here is the output
[ 3868.202260] netlink_insert:1086: ffff8800d8c14000
[ 3868.202962] netlink_insert:1086: ffff8800d8c15800
[ 3868.202995] netlink_insert:1086: ffff8800d8c12000
[ 3868.203228] netlink_insert:1086: ffff8800d8c16000
[ 3868.203360] netlink_insert:1086: ffff8800d8c11000
[ 3868.203920] netlink_insert:1086: ffff8800d8c13000
[ 3868.203951] netlink_insert:1086: ffff8800d8c11800
[ 3868.204216] netlink_insert:1086: ffff8800d8c17000
[ 3868.205846] netlink_remove:1102: ffff8800d8c14000
[ 3868.205849] netlink_remove:1104: ffff8800d8c14000
[ 3868.208270] netlink_insert:1086: ffff8800d81d3800
[ 3868.215363] netlink_remove:1102: ffff8800d81d3800
[ 3868.215368] netlink_remove:1104: ffff8800d81d3800
[ 3868.216465] netlink_insert:1086: ffff8800d8c0a000
[ 3868.226320] netlink_remove:1102: ffff8800d8c0a000
[ 3868.226324] netlink_remove:1104: ffff8800d8c0a000
[ 3868.230662] netlink_insert:1086: ffff8800d8c0e800
[ 3868.235906] netlink_remove:1102: ffff8800d8c0e800
[ 3868.235910] netlink_remove:1104: ffff8800d8c0e800
[ 3868.280231] netlink_remove:1104: ffff8800d8c17000
[ 3868.280283] netlink_remove:1104: ffff8800d8c11800
[ 3868.286152] netlink_remove:1104: ffff8800d8c13000
[ 3868.318148] netlink_remove:1104: ffff8800d8c11000
[ 3868.318185] netlink_remove:1104: ffff8800d8c16000
[ 3868.318241] netlink_remove:1104: ffff8800d8c12000
[ 3868.318255] netlink_remove:1104: ffff8800d8c15800

So it looks like

netlink_insert() returns zero, but then rhashtable_remove_fast()
returns non-zero code

Thanks,
Andrew
