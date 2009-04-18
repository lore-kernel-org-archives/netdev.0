From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Sat, 18 Apr 2009 17:34:02 +0900
Message-ID: <200904181734.ACB09871.QtVSOHMFJOLFOF@I-love.SAKURA.ne.jp>
References: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp>
	<200904141859.57965.paul.moore@hp.com>
	<200904150512.n3F5CfDA008806@www262.sakura.ne.jp>
	<200904161423.04414.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904161423.04414.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Thank you for answering my questions.

Paul Moore wrote:
> > Q1: Can I use skb_kill_datagram() here?
> >
> >     skb_kill_datagram() uses spin_lock_bh() while __skb_recv_datagram()
> > uses spin_lock_irqsave(). Since this codepath is called inside
> >     __skb_recv_datagram(), I used spin_lock_irqsave() rather than calling
> >     skb_kill_datagram().
> 
> Since __skb_recv_datagram() is already using spin_lock_irqsave() it seems 
> reasonable to do the same in your changes.
I see. I'll use spin_lock_irqsave() here.

> > > > +no_peek:
> > > > +	kfree_skb(skb);
> >
> > Q2: Do I need to use skb_free_datagram() here rather than kfree_skb()?
> >
> >     In the past ( http://lkml.org/lkml/2007/11/16/406 ), there was no
> >     difference between skb_free_datagram() and kfree_skb().
> >
> >     | void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
> >     | {
> >     | 	kfree_skb(skb);
> >     | }
> >
> >     But now (as of 2.6.30-rc2), there is a difference.
> >
> >     | void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
> >     | {
> >     | 	consume_skb(skb);
> >     | 	sk_mem_reclaim_partial(sk);
> >     | }
> 
> I don't know for certain, I would have to go look at other users of 
> skb_free_datagram(), but it does look like using skb_free_datagram() instead
 
> of skb_free() might be preferable.
I see. I'll use skb_free_datagram() here.

Also, I'll need to protect skb_free_datagram() with lock_sock()/
release_sock().
(Thanks to Eric Dumazet.)

> > Q3: Is __skb_recv_datagram() called from contexts that are not permitted 
to
> >     sleep?
> >
> >     If so, TOMOYO has to check whether it is allowed to sleep, for TOMOYO
> > will prompt the user "whether to allow App1 to read this datagram or not".
> 
> I believe __skb_recv_datagram() is only called via userspace so sleeping 
> should not be an issue.
> 
NFS code needs to issue UDP send()/recv() requests from the 
kernel. Therefore,
I think __skb_recv_datagram() is called from kernel space.

I'm worrying that __skb_recv_datagram() is called with a 
spinlock held.

> > Q4: Is there a way to distinguish requests from userland programs and
> > requests from kernel code?
> 
> I'm not sure if this is the 100% correct way to do it, but in the past I 
have 
> always checked current->mm, for kernel threads this will be NULL.

Nowadays, it will be "current->mm && !(current->flags & PF_
KTHREAD)" because
get_task_mm() says a kernel workthread may temporarily have a 
user mm to do its
AIO.

Sorry for confusing question. What I wanted to know is not "how 
can I
distinguish kernel processes and userland processes". What I 
wanted to know is
"how can I distinguish requests issued for processing a request 
>from userland
process".

(a) If a file is on a simple filesystem like ext3, an open()/
read()/write()
    request from userspace application will not issue another
    open()/read()/write() request.

(b) If a file is on a stackable filesystem like unionfs, an open
()/create()/
    unlink() request from userspace application will issue 
another
    open()/create()/unlink() request from kernel space.

(c) If a file is on a networking filesystem like nfs, an open()/
create()/
    unlink() request from userspace application will issue send
()/recv()
    request from kernel space.

If (b) and (c) use a dedicated task_struct for handling requests
 from kernel
space, TOMOYO has nothing to do.
But unfortunately, (b) and (c) use a task_struct of the 
userspace application
for handling requests from kernel space. TOMOYO wants to 
distinguish
an open()/create()/unlink() request from userspace application 
and 
open()/create()/unlink()/send()/recv() requests needed for 
handling
the open()/create()/unlink() request from userspace application.
I wished that there is an indicator that tells TOMOYO that 
whether an
open()/create()/unlink()/send()/recv() request is issued for 
processing
a request from userland process.

I know little about NFS, but I think NFS does not use a kernel 
workthread for
sending/receiving UDP packets to handle an open()/read()/write()
 request from
a userspace application.

I'm afraid that checking "current->mm && !(current->flags & PF_
KTHREAD)" will
not help TOMOYO in distinguishing "direct request" and "indirect
 request".






By the way, I need to tell you one more thing about
security_socket_post_accept() hook's usage. Not now, but in 
future,
I want to introduce task's state variable which is used for 
dividing
permissions within a domain.

  # Example policy for /usr/sbin/sshd
  allow_network TCP accept 10.0.0.0-10.255.255.255.255 1024-
65535 ; set task.state[0]=1
  allow_network TCP accept 192.168.0.0-192.168.255.255 1024-
65535 ; set task.state[0]=2
  allow_execute /bin/bash if task.state[0]=1
  allow_execute /bin/rbash if task.state[0]=2

The above example policy allows an instance of /usr/sbin/sshd to
(a) execute /bin/bash if that instance accepted a TCP connection
 from
    10.0.0.0/8
(b) execute /bin/rbash if that instance accepted a TCP 
connection from
    192.168.0.0/16.
(c) abort TCP connections if that instance accepted a TCP 
connection from
    neither 10.0.0.0/8 nor 192.168.0.0/16.

The security_socket_post_accept() hook is used for not only 
aborting TCP
connections from unwanted peers but also associating client's 
information
with a process who handles that TCP connection. The task's state
 variable
definitely requires a LSM hook which is called after sock->ops->
accept() call.
