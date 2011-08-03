From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Wed, 3 Aug 2011 21:20:46 +0900
Message-ID: <201108032120.CHC60420.OVOFQFHMJLSOtF@I-love.SAKURA.ne.jp>
References: <20110802.050115.1714327089688495866.davem@davemloft.net>
	<201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
	<201108030325.p733Pplb030986@www262.sakura.ne.jp>
	<20110802.203836.40056483416201909.davem@davemloft.net>
	<20110803134752.31347b64@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eparis@parisplace.org, casey@schaufler-ca.com, mjt@tls.msk.ru,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: anton@samba.org, davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110803134752.31347b64@kryten>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 2 Aug 2011 20:52:05 +0900
> 
> > David Miller wrote:
> >> Actually, I change my mind. :-)
> >> 
> >> I think sendmmsg() needs to unconditionally not report an error if any
> >> datagrams were sent successfully.
> > 
> > What about adding
> 
> I much prefer to make the error handling more correct, rather than
> making sendmmsg() have fundamentally different semantics depending
> upon the underlying LSM.
> 

Well, the way how sendmmsg() returns error code is tricky. But recvmmsg() has
been doing in this way for a while. So, for symmetry reason, maybe sendmmsg()
should do as with recvmmsg() since it is too late to change recvmmsg()'s way.

So, programmers should be warned (in the man pages) that they should always
call getsockopt(SO_ERROR) (in order to clear the error code) if sendmmsg() or
recvmmsg() returned less than requested.

It is inevitable that sendmmsg() behaves differently depending upon the
underlying LSM. If the underlying LSM is SMACK (or TOMOYO), sendmmsg() might
return before all datagrams are sent due to security_socket_sendmsg() returning
an error at the middle of the datagram array. In that case, calling senddmsg()
again (after clearing error code using getsockopt(SO_ERROR)) from (previous'
sendmmsg()'s return value)th element of the datagram array will likely fail
because security_socket_sendmsg() will return the same error again. Thus,
programmers should be warned that they must not expect that resuming sendmmsg()
 from (previous' sendmmsg()'s return value)th element will eventually succeed.

By the way, don't we want integer overflow check and/or cond_resched() here?
I don't know whether there is an arch where userspace can allocate
(1 << BITS_PER_INT) * sizeof(struct msghdr) bytes using malloc() and kernel can
allocate huge memory for the socket buffer.

#include <stdio.h>
int main(int argc, char *argv[])
{
        int datagrams = 0;
        unsigned int vlen = 4294967290U;
        while (datagrams < vlen)
                datagrams++;
        printf("%u\n", datagrams);
        return 0;
}

I think this program (on x86_32) will print an IS_ERR() value upon success.
