From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Wed, 11 Nov 2015 09:23:30 -0800
Message-ID: <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	 <877fnc7i0i.fsf@bytheb.org>
	 <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
	 <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
	 <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33960 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbbKKRXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 12:23:32 -0500
Received: by padhx2 with SMTP id hx2so36403455pad.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 09:23:31 -0800 (PST)
In-Reply-To: <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 09:05 -0800, Tom Herbert wrote:
> On Tue, Nov 10, 2015 at 10:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2015-11-10 at 21:41 -0800, Tom Herbert wrote:
> >> Tolga, are you still planning to respin this patch (when tree opens?)
> >
> > I was planning to add an union on skc_tx_queue_mapping and
> > sk_max_ack_backlog, so that adding a check on sk_max_ack_backlog in
> > listener lookup would not add an additional cache line miss.
> >
> > This would remove false sharing because sk_ack_backlog is often dirtied
> > when a socket is added into accept queue.
> >
> That's sounds like good fixes, but my question was more about the
> problem originally described by Tolga where we are transitioning
> processing for a listener port from one process to another. I think
> the conclusion in this thread was to modify the code so that
> listen(fd, 0) would stop new connections from being assigned to a
> socket (as opposed to explicit SO_REUSEPORT_LISTEN_OFF option). Does
> this still seem reasonable?

Actually listen(fd, 0) is not going to work well :

For request_sock that were created (by incoming SYN packet) before this
listen(fd, 0) call, the 3rd packet (ACK coming from client) would not be
able to create a child attached to this listener.

sk_acceptq_is_full() test in tcp_v4_syn_recv_sock() would simply drop
the thing.

I was mainly objecting adding yet another socket option.

Maybe setsockopt(... SO_REUSEPORT, &off, sizeof(off)) could detect the
condition automatically ?

(I am not sure current behavior of setting sk->sk_reuseport = valbool;
is correct if valbool==0 and current sk_reuseport is 1)
