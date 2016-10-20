From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: must lock the socket in udp_disconnect()
Date: Thu, 20 Oct 2016 14:46:10 -0400 (EDT)
Message-ID: <20161020.144610.532749573029633695.davem@davemloft.net>
References: <05f766db-4a8c-933e-9d73-6daada21f491@gmail.com>
        <1476944754.7065.3.camel@edumazet-glaptop3.roam.corp.google.com>
        <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sploving1@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934225AbcJTSqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:46:12 -0400
In-Reply-To: <1476981580.7065.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2016 09:39:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Baozeng Ding reported KASAN traces showing uses after free in
> udp_lib_get_port() and other related UDP functions.
> 
> A CONFIG_DEBUG_PAGEALLOC=y kernel would eventually crash.
> 
> I could write a reproducer with two threads doing :
> 
> static int sock_fd;
> static void *thr1(void *arg)
> {
> 	for (;;) {
> 		connect(sock_fd, (const struct sockaddr *)arg,
> 			sizeof(struct sockaddr_in));
> 	}
> }
> 
> static void *thr2(void *arg)
> {
> 	struct sockaddr_in unspec;
> 
> 	for (;;) {
> 		memset(&unspec, 0, sizeof(unspec));
> 	        connect(sock_fd, (const struct sockaddr *)&unspec,
> 			sizeof(unspec));
>         }
> }
> 
> Problem is that udp_disconnect() could run without holding socket lock,
> and this was causing list corruptions.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Baozeng Ding <sploving1@gmail.com>

Applied, sounds like I should queue this up for -stable too right?
