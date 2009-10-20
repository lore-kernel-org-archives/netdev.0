From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: Kernel oops when clearing bgp neighbor info with
 TCP MD5SUM enabled
Date: Mon, 19 Oct 2009 18:13:41 -0700 (PDT)
Message-ID: <20091019.181341.104579802.davem@davemloft.net>
References: <20091019121327.GA11423@redhat.com>
	<Pine.LNX.4.64.0910191745050.20086@sleet.zeugmasystems.local>
	<Pine.LNX.4.64.0910191756420.20086@sleet.zeugmasystems.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oleg@redhat.com, ani@anirban.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: asinha@zeugmasystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758122AbZJTBNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 21:13:19 -0400
In-Reply-To: <Pine.LNX.4.64.0910191756420.20086@sleet.zeugmasystems.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Sinha <asinha@zeugmasystems.com>
Date: Mon, 19 Oct 2009 18:08:21 -0700 (PDT)

> @@ -363,7 +363,7 @@ void tcp_twsk_destructor(struct sock *sk)
>  #ifdef CONFIG_TCP_MD5SIG
>         struct tcp_timewait_sock *twsk = tcp_twsk(sk);
>         if (twsk->tw_md5_keylen)
> -               tcp_put_md5sig_pool();
> +               tcp_free_md5sig_pool();
>  #endif
>  }

This has been fixed in the tree for a month of so:

commit 657e9649e745b06675aa5063c84430986cdc3afa
Author: Robert Varga <nite@hq.alert.sk>
Date:   Tue Sep 15 23:49:21 2009 -0700

    tcp: fix CONFIG_TCP_MD5SIG + CONFIG_PREEMPT timer BUG()
    
    I have recently came across a preemption imbalance detected by:
    
    <4>huh, entered ffffffff80644630 with preempt_count 00000102, exited with 00000101?
    <0>------------[ cut here ]------------
    <2>kernel BUG at /usr/src/linux/kernel/timer.c:664!
    <0>invalid opcode: 0000 [1] PREEMPT SMP
    
    with ffffffff80644630 being inet_twdr_hangman().
    
    This appeared after I enabled CONFIG_TCP_MD5SIG and played with it a
    bit, so I looked at what might have caused it.
    
    One thing that struck me as strange is tcp_twsk_destructor(), as it
    calls tcp_put_md5sig_pool() -- which entails a put_cpu(), causing the
    detected imbalance. Found on 2.6.23.9, but 2.6.31 is affected as well,
    as far as I can tell.
    
    Signed-off-by: Robert Varga <nite@hq.alert.sk>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 045bcfd..624c3c9 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -363,7 +363,7 @@ void tcp_twsk_destructor(struct sock *sk)
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
 	if (twsk->tw_md5_keylen)
-		tcp_put_md5sig_pool();
+		tcp_free_md5sig_pool();
 #endif
 }
 
