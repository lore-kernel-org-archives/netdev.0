From: Martin Kelly <martin@martingkelly.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 10 Sep 2014 14:37:41 -0700
Message-ID: <CAN8CM3xEnQXVgrLpV0rfAJoZ75v6Xv64pAGJ-9SAPACAT8WJ_w@mail.gmail.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
	<20140909.150000.1647602729214485795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:59876 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbaIJVhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 17:37:43 -0400
Received: by mail-wg0-f52.google.com with SMTP id x13so5449827wgg.11
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 14:37:42 -0700 (PDT)
In-Reply-To: <20140909.150000.1647602729214485795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The synchronize_net() is also there to protect against the prot hook
> which can run asynchronously from the core packet input path on any
> cpu.
>

Yes, understood. What I'm not clear about is whether it is safe to do
the following:

unregister_prot_hook(sk, false);
sock_orphan(sk);
sock->sk = NULL;
call_rcu(...);
close socket, return to userspace

instead of

unregister_prot_hook(sk, false);
synchronize_net();
sock_orphan(sk);
sock->sk = NULL;
close socket, return to userspace

If you don't call synchronize_net() immediately, then other readers
could see the protocol hook in the protocol list and try to use it.
They could call into prot_hook.func. However, it appears that  such
functions ( e.g. packet_rcv() ) touch the socket buffer but not the
socket itself, so orphaning the socket before all RCUs have been
processed is safe. In addition, no new packets will come in after
packet_release() and touch the socket because the socket fd will be
removed from the process fd list.

>From my testing, I'm not seeing any obvious issues, but I could be
missing something. Is orphaning the socket before all RCUs have
finished unsafe?
