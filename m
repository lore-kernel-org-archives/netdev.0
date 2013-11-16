From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] socket: don't return uninitialized addresses on concurrent socket shutdown
Date: Sat, 16 Nov 2013 07:39:56 +0100
Message-ID: <20131116063956.GI26901@order.stressinduktion.org>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com> <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com> <20131116054344.GG26901@order.stressinduktion.org> <20131116054814.GH26901@order.stressinduktion.org> <1384583569.8604.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46511 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab3KPGj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 01:39:57 -0500
Content-Disposition: inline
In-Reply-To: <1384583569.8604.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 15, 2013 at 10:32:49PM -0800, Eric Dumazet wrote:
> On Sat, 2013-11-16 at 06:48 +0100, Hannes Frederic Sowa wrote:
> > If a blocking read waits on a socket which gets concurrently shut down we
> > return 0 as error and so indicate success to the socket functions which
> > thus copy an uninitialized stack allocated address back to the user.
> > Fix this by clearing the 128 byte size (on x86-64) address first.
> > 
> > This patch fixes the problem for recvfrom, recvmsg and recvmmsg.
> > 
> > Reported-by: mpb <mpb.mail@gmail.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> Are you clearing 128 bytes on every recvfrom() system call, just in case
> of this shutdown() issue ?

Yes, that gave me a bad feeling, too (so I explicitly mentioned it in the
changelog and hoped for some discussion).

> Can't we avoid this overhead ?
> 
> msg.msg_namelen should be set to 0 in this case.

I don't see how, currently. Either we tunnel a new return value through
->recvmsg or we use the address structure, mark it with a special AF_FOO and
check if we get back that same value.

I don't see how msg.msg_namelen set to zero can help?
