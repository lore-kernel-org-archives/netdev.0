From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Restore socket refcount when sendmsg succeeds
Date: Fri, 01 Mar 2013 14:12:52 -0500 (EST)
Message-ID: <20130301.141252.1152926224695074046.davem@davemloft.net>
References: <20130301150202.GA3649@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: g.nault@alphalink.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130301150202.GA3649@alphalink.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 1 Mar 2013 16:02:02 +0100

> The sendmsg() syscall handler for PPPoL2TP doesn't decrease the socket
> reference counter after successful transmissions. Any successful
> sendmsg() call from userspace will then increase the reference counter
> forever, thus preventing the kernel's session and tunnel data from
> being freed later on.
> 
> The problem only happens when writing directly on L2TP sockets.
> PPP sockets attached to L2TP are unaffected as the PPP subsystem
> uses pppol2tp_xmit() which symmetrically increase/decrease reference
> counters.
> 
> This patch adds the missing call to sock_put() before returning from
> pppol2tp_sendmsg().
> 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Looking at how this code works, it is such a terrible design.  This
whole reference counting issue exists purely because
pppol2tp_sock_to_session() grabs the 'sk' reference.

In all but one case, it need not do this.

The socket system calls have an implicit reference to 'sk' via
socket->sk.  If you can get into the system call and socket->sk
is non-NULL then 'sk' is NOT going anywhere.

And all of these system call handlers have this pattern:

	session = pppol2tp_sock_to_session(sk);
	...
	sock_put(sk);

The only case where the reference count is really needed is that
sequence in pppol2tp_release().

Long term the right thing to do here is stop having this session
grabber function take the 'sk' reference.  Then in pppol2tp_release
we'll grab a reference explicitly.  At all the other call sites we
then blast aweay all of the sock_put(sk) paths.

Anyways, for now I'll apply this patch and queue it up for -stable,
thanks.
