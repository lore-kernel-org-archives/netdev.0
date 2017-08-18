From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ipv6: fix false-postive maybe-uninitialized
 warning
Date: Fri, 18 Aug 2017 10:49:40 -0700 (PDT)
Message-ID: <20170818.104940.305624900632112023.davem@davemloft.net>
References: <20170818113434.3037484-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, fw@strlen.de,
        dsahern@gmail.com, kafai@fb.com, weiwan@google.com,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818113434.3037484-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Aug 2017 13:34:22 +0200

> Adding a lock around one of the assignments prevents gcc from
> tracking the state of the local 'fibmatch' variable, so it can no
> longer prove that 'dst' is always initialized, leading to a bogus
> warning:
> 
> net/ipv6/route.c: In function 'inet6_rtm_getroute':
> net/ipv6/route.c:3659:2: error: 'dst' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This moves the other assignment into the same lock to shut up the
> warning.
> 
> Fixes: 121622dba8da ("ipv6: route: make rtm_getroute not assume rtnl is locked")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  net/ipv6/route.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> This kind of warning involving an unlock between variable initialization
> and use is relatively frequent for false-positives. I should try to
> seek clarification from the gcc developers on whether this can be
> improved.

This will have to do for now I suppose.

I guess the issue is that if the local variable ever sits on the stack
then the memory barriers in the locks block the full dataflow
analysis.

But this makes no sense from a dataflow perspective.  Even if the
local variable has a stack slot, there is no "escapability" of that
memory addres to foreign modifications.

If I had a nickel for every uninitialized variable warning we had to
work around....
