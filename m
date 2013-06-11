From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sctp: fix NULL pointer dereference in
 socket destruction
Date: Tue, 11 Jun 2013 02:49:45 -0700 (PDT)
Message-ID: <20130611.024945.708794798755946342.davem@davemloft.net>
References: <1370526827-23882-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab3FKJtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:49:46 -0400
In-Reply-To: <1370526827-23882-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu,  6 Jun 2013 15:53:47 +0200

> While stress testing sctp sockets, I hit the following panic:
 ...
> I did not hit this with the lksctp-tools functional tests, but with a
> small, multi-threaded test program, that heavily allocates, binds,
> listens and waits in accept on sctp sockets, and then randomly kills
> some of them (no need for an actual client in this case to hit this).
> Then, again, allocating, binding, etc, and then killing child processes.
> 
> This panic then only occurs when ``echo 1 > /proc/sys/net/sctp/auth_enable''
> is set. The cause for that is actually very simple: in sctp_endpoint_init()
> we enter the path of sctp_auth_init_hmacs(). There, we try to allocate
> our crypto transforms through crypto_alloc_hash(). In our scenario,
> it then can happen that crypto_alloc_hash() fails with -EINTR from
> crypto_larval_wait(), thus we bail out and release the socket via
> sk_common_release(), sctp_destroy_sock() and hit the NULL pointer
> dereference as soon as we try to access members in the endpoint during
> sctp_endpoint_free(), since endpoint at that time is still NULL. Now,
> if we have that case, we do not need to do any cleanup work and just
> leave the destruction handler.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks!
