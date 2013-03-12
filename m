From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH] l2tp: Restore socket refcount when sendmsg succeeds
Date: Tue, 12 Mar 2013 11:36:50 +0100
Message-ID: <20130312103650.GA4512@alphalink.fr>
References: <20130301150202.GA3649@alphalink.fr>
 <20130301.141252.1152926224695074046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130301.141252.1152926224695074046.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 01, 2013 at 02:12:52PM -0500, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Fri, 1 Mar 2013 16:02:02 +0100
> 
> > The sendmsg() syscall handler for PPPoL2TP doesn't decrease the socket
> > reference counter after successful transmissions. Any successful
> > sendmsg() call from userspace will then increase the reference counter
> > forever, thus preventing the kernel's session and tunnel data from
> > being freed later on.
> > 
> > The problem only happens when writing directly on L2TP sockets.
> > PPP sockets attached to L2TP are unaffected as the PPP subsystem
> > uses pppol2tp_xmit() which symmetrically increase/decrease reference
> > counters.
> > 
> > This patch adds the missing call to sock_put() before returning from
> > pppol2tp_sendmsg().
> > 
> > Cc: <stable@vger.kernel.org>
> > Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> 
> Looking at how this code works, it is such a terrible design.  This
> whole reference counting issue exists purely because
> pppol2tp_sock_to_session() grabs the 'sk' reference.
> 
> In all but one case, it need not do this.
> 
> The socket system calls have an implicit reference to 'sk' via
> socket->sk.  If you can get into the system call and socket->sk
> is non-NULL then 'sk' is NOT going anywhere.
> 
> And all of these system call handlers have this pattern:
> 
> 	session = pppol2tp_sock_to_session(sk);
> 	...
> 	sock_put(sk);
> 
> The only case where the reference count is really needed is that
> sequence in pppol2tp_release().
> 
> Long term the right thing to do here is stop having this session
> grabber function take the 'sk' reference.  Then in pppol2tp_release
> we'll grab a reference explicitly.  At all the other call sites we
> then blast aweay all of the sock_put(sk) paths.
> 
Could this also apply to l2tp_sock_to_tunnel() (in l2tp_core.h)? As per
my understanding, none of its callers needs to take a socket reference.
So sock_hold() could be removed in both pppol2tp_sock_to_session() and
l2tp_sock_to_tunnel() functions. The corresponding sock_put() calls
would then be removed from all calling functions but pppol2tp_release().
If this is correct, I'll send a patch for net-next.
