From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: Simplify __udp*_lib_mcast_deliver.
Date: Wed, 16 Jul 2014 08:58:02 +0200
Message-ID: <1405493882.10255.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405377039-10082-1-git-send-email-drheld@google.com>
	 <20140715.171431.1611412835087664432.davem@davemloft.net>
	 <CAGa1Tm6hC5-JOidCHWHBHwni2mtpjUdqvQPByK7g9ZH2QHW=Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>
To: David Held <drheld@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:61608 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932812AbaGPG6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 02:58:07 -0400
Received: by mail-we0-f172.google.com with SMTP id x48so427367wes.3
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 23:58:06 -0700 (PDT)
In-Reply-To: <CAGa1Tm6hC5-JOidCHWHBHwni2mtpjUdqvQPByK7g9ZH2QHW=Jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 21:53 -0400, David Held wrote:
> On Tue, Jul 15, 2014 at 8:14 PM, David Miller <davem@davemloft.net> wrote:
> >
> >
> > I think you are changing the logic of the loop in the edge case.
> >
> > If we have exactly ARRAY_SIZE(stack) sockets to process, the old code
> > performs the flush_stack() outside of the hslot->lock, but with your
> > change we'll do it inside the lock.
> >
> > The tradeoff here is reducing hslot->lock hold times vs. avoiding
> > taking a hold on all the sockets in the stack[] array.
> >
> > I just wanted to point this out and make sure you are aware of and
> > are ok with this.
> 
> The followup patch makes it so we always take a hold on the sockets
> anyway (it makes things simpler and only changes things for the too
> large array case), so might as well reduce the lock time for the
> exactly ARRAY_SIZE case.

Note that my initial motivation for this array was to convert the
multicast lookup into a RCU one, but I never finished this.

If we hold a spinlock, there is no need for this array in the first
place.

If we dont hole a spinlock, we are forced to temporarily store the
sockets into the array, just in case we restart the lookup because we
are directed into another chain.
