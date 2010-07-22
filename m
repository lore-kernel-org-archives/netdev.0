From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Wed, 21 Jul 2010 21:06:36 -0700 (PDT)
Message-ID: <20100721.210636.197931242.davem@davemloft.net>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
	<20100721.114509.37203355.davem@davemloft.net>
	<201007220338.o6M3citW076383@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007220338.o6M3citW076383@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Your analysis is wrong, and what Tomoyo is doing is so fundamentally
different than what the existing SELINUX hooks do.

The existing LSM hooks do not break BSD socket behavior.  Do you know
why?  Because someone who understood all of this spent a great deal
of time carefully designing them.

The existing hooks do not drop packets on recvmsg() when a security
check does not pass, they signal the error long before the socket
receive queue is even looked at.  It is just like seeing a -EFAULT,
-ENFILE, or similar error.

Checks are always made _BEFORE_ major state changes are made to the
socket.

That is critically important, and it's what you seem to fail to see.

The hooks you propose _LOSE_ information.  So even if another process
has the 'fd' for a socket, and they would be allowed to receive the
packet by LSM checks, the post hook does not allow that to happen
because the failing 'fd' just frees up the packet and loses it
forever.

The existing hooks signal before we pull the new connection out of the
accept queue during accept(), therefore avoiding the illegal situation
your post ->accept() hook would create since there is absolutely no
way (and there should not be a way) to push a connection back into the
sock accept queue after we've taken it from the protocol layer.

And again here, the proposed hooks _LOSE_ information.  The accepted
connection is lost forever, another process with valid security
credentials cannot accept the connection.  It is completely gone.

And I'm not even going to entertain adding facilities to allow pushing
things back into the socket state after they've been removed for
inspection.

I think we've been through this issue enough times that we have covered
the issues in their entirety, and nothing you have written convinces
me that my position is wrong and that it is valid to put the Tomoyo
post-recvmsg and post-accept hooks into the tree.

Sorry, but I'm not applying your patches, they are fundamentally flawed
unlike the existing hooks.
