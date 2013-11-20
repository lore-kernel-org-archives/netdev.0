From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 18:38:28 +0100
Message-ID: <20131120173828.GL8581@1wt.eu>
References: <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu> <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu> <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu> <20131117141940.GA18569@1wt.eu> <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com> <20131120171227.GG8581@1wt.eu> <1384968607.10637.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50796 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab3KTRiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 12:38:54 -0500
Content-Disposition: inline
In-Reply-To: <1384968607.10637.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 09:30:07AM -0800, Eric Dumazet wrote:
> Well, all TCP performance results are highly dependent on the workload,
> and both receivers and senders behavior.
> 
> We made many improvements like TSO auto sizing, DRS (dynamic Right
> Sizing), and if the application used some specific settings (like
> SO_SNDBUF / SO_RCVBUF or other tweaks), we can not guarantee that same
> exact performance is reached from kernel version X to kernel version Y.

Of course, which is why I only care when there's a significant
difference. If I need 6 streams in a version and 8 in another one to
fill the wire, I call them identical. It's only when we dig into the
details that we analyse the differences.

> We try to make forward progress, there is little gain to revert all
> these great works. Linux had this tendency to favor throughput by using
> overly large skbs. Its time to do better.

I agree. Unfortunately our mails have crossed each other, so just to
keep this tread mostly linear, your next patch here :

   http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=98e09386c0ef4dfd48af7ba60ff908f0d525cdee

Fixes that regression and the performance is back to normal which is
good.

> As explained, some drivers are buggy, and need fixes.

Agreed!

> If nobody wants to fix them, this really means no one is interested
> getting them fixed.

I was exactly reading the code when I found a window with your patch
above that I was looking for :-)

> I am willing to help if you provide details, because otherwise I need
> a crystal ball ;)
> 
> One known problem of TCP is the fact that an incoming ACK making room in
> socket write queue immediately wakeup a blocked thread (POLLOUT), even
> if only one MSS was ack, and write queue has 2MB of outstanding bytes.

Indeed.

> All these scheduling problems should be identified and fixed, and yes,
> this will require a dozen more patches.
> 
> max (128KB , 1-2 ms) of buffering per flow should be enough to reach
> line rate, even for a single flow, but this means the sk_sndbuf value
> for the socket must take into account the pipe size _plus_ 1ms of
> buffering.

Which is the purpose of your patch above and I confirm it fixes the
problem.

Now looking at how to workaround this lack of Tx IRQ.

Thanks!
Willy
