From: Calvin Owens <calvinowens@fb.com>
Subject: Re: [PATCH] net: Unbreak resetting default values for
 tcp_wmem/udp_wmem_min
Date: Mon, 10 Aug 2015 20:34:06 -0700
Message-ID: <20150811033406.GA1136819@mail.thefacebook.com>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
 <20150809.224114.818332231954008575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, <sorin@returnze.ro>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150809.224114.818332231954008575.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 08/09 at 22:41 -0700, David Miller wrote:
> From: Calvin Owens <calvinowens@fb.com>
> Date: Wed, 5 Aug 2015 13:26:54 -0700
> 
> > Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
> > SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
> > written to them are not less than SOCK_MIN_{RCV,SND}BUF.
> > 
> > This change is fine for tcp_rmem and udp_rmem_min, since SOCK_MIN_RCVBUF
> > is equal to equal to TCP_SKB_MIN_TRUESIZE. But it breaks tcp_wmem and
> > udp_wmem_min for previously valid values because SOCK_MIN_SNDBUF is
> > (2 * TCP_SKB_MIN_TRUESIZE), which ends up being greater than 4KB.
> > 
> > Thus, 4096 is no longer accepted as a valid value, despite still being
> > the default for udp_wmem_min, and for 'min' in tcp_wmem. A huge number
> > of sysctl configurations at FB use 4096 as 'min', so this change breaks
> > all of them.
> > 
> > This patch changes the sysctls to simply enforce that the value written
> > is greater than or equal to the default value of SK_MEM_QUANTUM.
> > 
> > Fixes: 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to SOCK_MIN...")
> > Signed-off-by: Calvin Owens <calvinowens@fb.com>
> 
> I think increasing the default makes more sense.
> 
> If we don't allow applications to set 4K, the kernel shouldn't start
> with that value either.

I'm really questioning the limitation itself: why enforce a minimum of
SOCK_MIN_SNDBUF here? Why not SK_MEM_QUANTUM?

Commit 8133534c760d4083 referred to b1cb59cf2efe7971, which choose to
use the SOCK_MIN constants as the lower limits to avoid nasty bugs. But
AFAICS, a limit of SOCK_MIN_SNDBUF isn't necessary to do that: the
BUG_ON cited in the commit message for b1cb59cf2efe7971 seems to have
happened because unix_stream_sendmsg() expects a minimum of a full page
(ie SK_MEM_QUANTUM) and the math broke, not because it had less than
SOCK_MIN_SNDBUF allocated.

Nothing seems to assume that it has at least SOCK_MIN_SNDBUF to play
with, so my argument is that enforcing a minimum of SK_MEM_QUANTUM
avoids the sort of bugs commit 8133534c760d4083 was trying to avoid, and
it does so without breaking anybody's sysctl configurations. What do you
think?

Thanks very much,
Calvin
