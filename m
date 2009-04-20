From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Mon, 20 Apr 2009 18:22:29 -0400
Message-ID: <200904201822.29529.paul.moore@hp.com>
References: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp> <200904161423.04414.paul.moore@hp.com> <200904181734.ACB09871.QtVSOHMFJOLFOF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904181734.ACB09871.QtVSOHMFJOLFOF@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 18 April 2009 04:34:02 am Tetsuo Handa wrote:
> Hello.
>
> Thank you for answering my questions.

No problem.

> > I believe __skb_recv_datagram() is only called via userspace so sleeping
> > should not be an issue.
>
> NFS code needs to issue UDP send()/recv() requests from the
> kernel. Therefore, I think __skb_recv_datagram() is called from kernel
> space.

My mistake, I trusted (or misread) the comment at the start of the function.

> I'm worrying that __skb_recv_datagram() is called with a
> spinlock held.

It looks like you've already solved that issue.

> > > Q4: Is there a way to distinguish requests from userland programs and
> > > requests from kernel code?
> >
> > I'm not sure if this is the 100% correct way to do it, but in the past I
> > have always checked current->mm, for kernel threads this will be NULL.
>
> Nowadays, it will be "current->mm && !(current->flags & PF_
> KTHREAD)" because get_task_mm() says a kernel workthread may temporarily
> have a user mm to do its AIO.

Thanks, that is good to know.

> Sorry for confusing question. What I wanted to know is not "how
> can I distinguish kernel processes and userland processes". What I
> wanted to know is "how can I distinguish requests issued for processing a
> request from userland process".

I do not know of a way but someone else reading this might.

> By the way, I need to tell you one more thing about
> security_socket_post_accept() hook's usage. Not now, but in future,
> I want to introduce task's state variable which is used for dividing
> permissions within a domain.
>
>   # Example policy for /usr/sbin/sshd
>   allow_network TCP accept 10.0.0.0-10.255.255.255.255 1024-
> 65535 ; set task.state[0]=1
>   allow_network TCP accept 192.168.0.0-192.168.255.255 1024-
> 65535 ; set task.state[0]=2
>   allow_execute /bin/bash if task.state[0]=1
>   allow_execute /bin/rbash if task.state[0]=2
>
> The above example policy allows an instance of /usr/sbin/sshd to
> (a) execute /bin/bash if that instance accepted a TCP connection
>  from
>     10.0.0.0/8
> (b) execute /bin/rbash if that instance accepted a TCP
> connection from
>     192.168.0.0/16.
> (c) abort TCP connections if that instance accepted a TCP
> connection from
>     neither 10.0.0.0/8 nor 192.168.0.0/16.
>
> The security_socket_post_accept() hook is used for not only
> aborting TCP connections from unwanted peers but also associating client's
> information with a process who handles that TCP connection. The task's state
> variable definitely requires a LSM hook which is called after sock->ops->
> accept() call.

I don't have a problem with using a socket_post_accept() hook to assign/modify 
state, however, I still not like the idea of using the socket_post_accept() 
hook to abort connections.

-- 
paul moore
linux @ hp

