From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net] af_unix: fix struct pid memory leak
Date: Mon, 25 Jan 2016 02:06:27 +0100
Message-ID: <20160125010627.GB14576@1wt.eu>
References: <1453481401.1223.396.camel@edumazet-glaptop2.roam.corp.google.com> <20160123180010.GB1609@1wt.eu> <CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com> <20160123184007.GE1609@1wt.eu> <CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com> <20160124021145.GA12367@1wt.eu> <20160124023824.GA13942@1wt.eu> <CANn89i+KfDVX8SO3mLnh8naXGb3WiM80=aBuhQKBVstZyfS_xg@mail.gmail.com> <20160124030412.GA13949@1wt.eu> <1453672430.1223.456.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Michal Hocko <mhocko@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453672430.1223.456.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Sun, Jan 24, 2016 at 01:53:50PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported a struct pid leak detected by a syzkaller program.
> 
> Bug happens in unix_stream_recvmsg() when we break the loop when a
> signal is pending, without properly releasing scm.
> 
> Fixes: b3ca9b02b007 ("net: fix multithreaded signal handling in unix recv routines")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> ---
>  net/unix/af_unix.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index c5bf5ef2bf89..49d5093eb055 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2339,6 +2339,7 @@ again:
>  
>  			if (signal_pending(current)) {
>  				err = sock_intr_errno(timeo);
> +				scm_destroy(&scm);
>  				goto out;
>  			}

Good job on this one! FWIW, I managed to test it on 3.14 and I confirm it
completely fixes the leak there as well. I had to modify it a little bit
however since there's no scm local variable there :

-				scm_destroy(&scm);
+				scm_destroy(siocb->scm);

Cheers,
Willy
