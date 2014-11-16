From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest kernels? (trying to debug)
Date: Sun, 16 Nov 2014 10:11:35 -0800
Message-ID: <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
	 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
	 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <a927787503c2f0d71c330b879303b14f@visp.net.lb>
	 <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1405676214.10255.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0b0b74ab8d2222fa85b23e06c6e992ec@visp.net.lb>
	 <1405849675.10255.100.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6fc086a122bc3ac728a7aec9e812310f@visp.net.lb>
	 <1406016045.10255.122.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3f463c3912608f7959481edaa6d7668d@visp.net.lb>
	 <1406194817.3363.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb>
	 <2adbf5346b4dd2bebe1915096c1c567c@visp.net.lb>
	 <1415813254.17262.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <64ef227cf22945d373cb06271fe6e051@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34469 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbaKPSLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 13:11:34 -0500
Received: by mail-ie0-f175.google.com with SMTP id at20so5306091iec.20
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 10:11:33 -0800 (PST)
In-Reply-To: <64ef227cf22945d373cb06271fe6e051@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-16 at 10:54 +0200, Denys Fedoryshchenko wrote:
> As latest findings, when servers are going crazy because of tcp memory 
> invalid accounting.
> First of all i upgraded kernel to latest version 3.17.3 and added also 
> patch from upcoming kernel,
> "12) Don't call sock_kfree_s() with NULL pointers, this function also 
> has the side effect of adjusting
> the socket memory usage.  From Cong Wang.", but it didnt helped.
> 
> I added printk_ratelimited to places where suspicious values might 
> appear, and got some more information.
> First, is not very suspicious, no idea if it is a problem:
> [ 1413.031622] sk ffff8817184d8680 sk_mem_charge negative -10752 by 4352
> [ 1413.032027] sk ffff8817184d8680 sk_mem_charge negative -15104 by 4352
> [ 1415.768465] sk ffff881666842d80 sk_mem_charge negative -9984 by 4352
> [ 1415.768868] sk ffff881666842d80 sk_mem_charge negative -14336 by 4352
> [ 1415.769268] sk ffff881666842d80 sk_mem_charge negative -18688 by 4352
> [ 1415.769681] sk ffff881666842d80 sk_mem_charge negative -9088 by 4352
> [ 1418.933799] sk ffff8816dd640000 sk_mem_charge negative -9984 by 4352
> [ 1418.934205] sk ffff8816dd640000 sk_mem_charge negative -14336 by 4352
> [ 1418.934604] sk ffff8816dd640000 sk_mem_charge negative -18688 by 4352
> [ 1427.131310] sk ffff881731801a00 sk_mem_charge negative -11776 by 4352
> [ 1428.564640] sk ffff881731801a00 sk_mem_charge negative -11008 by 4352
> [ 1429.134279] sk ffff881731801a00 sk_mem_charge negative -11776 by 4352
> [ 1429.134691] sk ffff881731801a00 sk_mem_charge negative -16128 by 4352
> [ 1430.666541] sk ffff881731801a00 sk_mem_charge negative -10496 by 4352
> [ 1431.395099] sk ffff881731801a00 sk_mem_charge negative -12032 by 4352
> [ 1431.395506] sk ffff881731801a00 sk_mem_charge negative -16384 by 4352
> [ 1431.877862] sk ffff881731801a00 sk_mem_charge negative -11648 by 4352
> Second is always linked with crashes, it is sk_mem_uncharge and 
> sk_forward_alloc goes negative. Patch to show message
> for sk_mem_uncharge in sock.h is very simple:
> 
>   static inline void sk_mem_uncharge(struct sock *sk, int size)
> @@ -1480,6 +1485,8 @@
>          if (!sk_has_account(sk))
>                  return;
>          sk->sk_forward_alloc += size;
> +       if (sk->sk_forward_alloc < -8192)
> +           printk_ratelimited(KERN_WARNING"sk %p sk_mem_uncharge 
> negative %d by %d\n", sk, sk->sk_forward_alloc, size);
>   }
> 


Could you describe your hardware setup and networking setup ?
