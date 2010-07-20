From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] LSM: Add post accept() hook.
Date: Tue, 20 Jul 2010 15:52:29 -0400
Message-ID: <201007201552.29539.paul.moore@hp.com>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <201007191815.52124.paul.moore@hp.com> <201007200136.o6K1aVc5015269@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jmorris@namei.org,
	sam@synack.fr, serge@hallyn.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007200136.o6K1aVc5015269@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, July 19, 2010 09:36:31 pm Tetsuo Handa wrote:
> Paul Moore wrote:
> > I think you need to show how you plan to use this hook in an LSM before
> > we can consider merging it with mainline.  What you are proposing here
> > is giving an LSM the ability to drop a connection _after_ allowing it to
> > be established in the first place; this seems very wrong to me and I
> > want to make sure everyone else is aware of that before accepting this
> > code into the kernel.  I understand that TOMOYO's security model does
> > not allow it to reject incoming connections at the beginning of the
> > connection request like some of the LSMs currently in use, but I'm just
> > not very happy with the idea of finishing a connection handshake only to
> > later drop the connection on the floor.
> 
> Yes. I'm planning to use security_socket_post_accept() for two purposes.
> 
> One is for dropping connections from unwanted hosts. Administrators define
> policy before enabling enforcing mode (the mode which connections are
> dropped if operation was not granted by policy). Administrators specify
> acceptable hosts (i.e. hosts which this host needs to communicate with)
> and unacceptable hosts (i.e. hosts which this host needn't to communicate
> with).

You can enforce per-host access controls without the need for a post-accept() 
hooks, e.g. security_sock_rcv_skb() and the netfilter hooks 
(NF_INET_POST_ROUTING, NF_INET_FORWARD, NF_INET_LOCAL_OUT).  Or are you 
interested in controlling which hosts an _application_ can communicate with?

> Dropping connections would happen if some process was hijacked and the
> process attempted to communicate with other processes using TCP
> connections. But dropping connections should not happen in normal
> circumstance.

It doesn't matter if dropping connections is normal or not, what matters is 
that it can happen.

> The other is for updating process's state variable upon accept() operation.
> LKM version of TOMOYO has per a task_struct variable that is used for
> implementing stateful permissions. (As of now, not implemented for LSM
> version of TOMOYO.)

I'm open to re-introducing a post-accept() hook that does not have a return 
value, in other words, a hook that can only be used to update LSM state and 
not affect the connection.  Although I do think you could probably achieve the 
same thing using some of the existing LSM hooks (look at how SELinux updates 
its state upon accept()) but that is something you would have to look it and 
see if it works for TOMOYO.

-- 
paul moore
linux @ hp
