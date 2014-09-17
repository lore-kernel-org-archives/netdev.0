From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 17 Sep 2014 07:54:50 -0700
Message-ID: <1410965690.7106.233.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
		<20140909.150000.1647602729214485795.davem@davemloft.net>
	 <CAN8CM3xEnQXVgrLpV0rfAJoZ75v6Xv64pAGJ-9SAPACAT8WJ_w@mail.gmail.com>
	 <54199AC7.1040502@martingkelly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Martin Kelly <martin@martingkelly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37603 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaIQOyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 10:54:52 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so2284622pde.33
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 07:54:51 -0700 (PDT)
In-Reply-To: <54199AC7.1040502@martingkelly.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-17 at 07:29 -0700, Martin Kelly wrote:
> On 09/10/2014 02:37 PM, Martin Kelly wrote:
> >> The synchronize_net() is also there to protect against the prot hook
> >> which can run asynchronously from the core packet input path on any
> >> cpu.
> >>
> > 
> > Yes, understood. What I'm not clear about is whether it is safe to do
> > the following:
> > 
> > unregister_prot_hook(sk, false);
> > sock_orphan(sk);
> > sock->sk = NULL;
> > call_rcu(...);

Can you describe the ... ?

> > close socket, return to userspace
> > 
> > instead of
> > 
> > unregister_prot_hook(sk, false);
> > synchronize_net();
> > sock_orphan(sk);
> > sock->sk = NULL;
> > close socket, return to userspace
> > 
> > If you don't call synchronize_net() immediately, then other readers
> > could see the protocol hook in the protocol list and try to use it.
> > They could call into prot_hook.func. However, it appears that  such
> > functions ( e.g. packet_rcv() ) touch the socket buffer but not the
> > socket itself, so orphaning the socket before all RCUs have been
> > processed is safe. In addition, no new packets will come in after
> > packet_release() and touch the socket because the socket fd will be
> > removed from the process fd list.



> > 
> > From my testing, I'm not seeing any obvious issues, but I could be
> > missing something. Is orphaning the socket before all RCUs have
> > finished unsafe?
> > 
> 
> (friendly ping)

What problem do you want to solve exactly ?

I believe its not safe, you missed sk_data_ready() call
(sock_def_readable()) 
