From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: a problem tcp_v4_err()
Date: Fri, 12 Nov 2010 21:29:59 +0300
Message-ID: <20101112182959.GA20459@ms2.inr.ac.ru>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com> <00c201cb81eb$84e18160$8ea48420$@com> <1289578108.3083.95.camel@localhost.localdomain> <1289578532.3185.265.camel@edumazet-laptop> <20101112163543.GB122902@jupiter.n2.diac24.net> <4CDD7145.8070606@trash.net> <20101112175715.GB16544@ms2.inr.ac.ru> <1289585578.3185.268.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Lamparter <equinox@diac24.net>,
	Eric Paris <eparis@redhat.com>, Hua Zhong <hzhong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, paul.moore@hp.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1289585578.3185.268.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On Fri, Nov 12, 2010 at 07:12:58PM +0100, Eric Dumazet wrote:
> I see socket is locked around line 368,
> 
>         bh_lock_sock(sk);
>         /* If too many ICMPs get dropped on busy
>          * servers this needs to be solved differently.
>          */
>         if (sock_owned_by_user(sk))
>                 NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
> 
> 
> Hmm, maybe some goto is missing ;)

It is not missing, sock_owned_by_user() is checked later when some operation which
cannot be done without lock is required. It was done to save error in sk_err_soft even
when socket is locked.

This code also _understands_ this: look at

                } else if (sock_owned_by_user(sk)) {
                        /* RTO revert clocked out retransmission,
                         * but socket is locked. Will defer. */
                        inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
                                                  HZ/20, TCP_RTO_MAX);

but somehow it considers the manipulations with rto/backoff/write_queue as safe.
Seems, they are not.

Alexey
