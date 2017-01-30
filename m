From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Mon, 30 Jan 2017 09:26:29 -0800
Message-ID: <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
         <20161006.205052.1380596858044266995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: anoob.soman@citrix.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35784 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbdA3R0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 12:26:36 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so23707452pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 09:26:36 -0800 (PST)
In-Reply-To: <20161006.205052.1380596858044266995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-06 at 20:50 -0400, David Miller wrote:
> From: Anoob Soman <anoob.soman@citrix.com>
> Date: Wed, 5 Oct 2016 15:12:54 +0100
> 
> > If a socket has FANOUT sockopt set, a new proto_hook is registered
> > as part of fanout_add(). When processing a NETDEV_UNREGISTER event in
> > af_packet, __fanout_unlink is called for all sockets, but prot_hook which was
> > registered as part of fanout_add is not removed. Call fanout_release, on a
> > NETDEV_UNREGISTER, which removes prot_hook and removes fanout from the
> > fanout_list.
> > 
> > This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in netdev_run_todo()
> > 
> > Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
> 
> Applied and queued up for -stable, thanks.

This commit (6664498280cf "packet: call fanout_release, while
UNREGISTERING a netdev")
looks buggy :

We end up calling fanout_release() while holding a spinlock
( spin_lock(&po->bind_lock); )

But fanout_release() grabs a mutex ( mutex_lock(&fanout_mutex) ), and
this is absolutely not valid while holding a spinlock.

Anoob, can you cook a fix, I guess you have a way to reproduce the thing
that wanted a kernel patch ?

(Please build your test kernel with CONFIG_LOCKDEP=y)

Thanks.
