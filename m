From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] udp: add recvmmsg implementation
Date: Wed, 30 Nov 2016 04:47:48 +0100
Message-ID: <1480477668.3699487.803285169.4BFDC4D6@webmail.messagingengine.com>
References: <cover.1480086321.git.pabeni@redhat.com>
 <68bfaa7480400457e712fb04ee781410d1bb9479.1480086321.git.pabeni@redhat.com>
 <1165706e-b828-cb12-4bea-b77ccca1cb95@stressinduktion.org>
 <20161129.192233.392359849404330043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
        brouer@redhat.com, sd@queasysnail.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:44404 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753042AbcK3Drt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 22:47:49 -0500
In-Reply-To: <20161129.192233.392359849404330043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 30, 2016, at 01:22, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 25 Nov 2016 18:09:00 +0100
> 
> > During review we discussed on how to handle major errors in the kernel:
> > 
> > The old code and the new code still can report back success even though
> > the kernel got back an EFAULT while copying from kernel space to user
> > space (due to bad pointers).
> > 
> > I favor that we drop all packets (also the already received batches) in
> > this case and let the code report -EFAULT and increase sk_drops for all
> > dropped packets from the queue.
> > 
> > Currently sk_err is set so the next syscall would get an -EFAULT, which
> > seems very bad and can also be overwritten by incoming icmp packets, so
> > we never get a notification that we actually had a bad pointer somewhere
> > in the mmsghdr. Also delivering -EFAULT on the follow-up syscalls really
> > will make people confused that use strace.
> > 
> > If people would like to know the amount of packets dropped we can make
> > sk_drops readable by an getsockopt.
> > 
> > Thoughts?
> > 
> > Unfortunately the interface doesn't allow for better error handling.
> 
> I think this is a major problem.
> 
> If, as a side effect of batch dequeueing the SKBs from the socket,
> you cannot stop properly mid-transfer if an error occurs, well then
> you simply cannot batch like that.
> 
> You have to stop the exact byte where an error occurs mid-stream,
> return the successful amount of bytes transferred, and then return
> the error on the next recvmmsg call.
> 
> There is no other sane error reporting strategy.

Actually I think there is no sane error handling strategy at all.

SIGSEGV and EFAULT should be delivered reliable in my opinion and all
the details become very difficult suddenly.

E.g. if we recvmmsg with -EFAULT and we try to deliver the fault on the
following socket call, I am pretty certain most programs don't bother
with close() return values, so the application might simply ignore it.
Also -EFAULT is not in our repository for error codes to return.

In case of UDP we can simply drop the packets and I would be okay with
that (in some cases we actually guarantee correctly ordered packets,
even for UDP, so we can't simply queue those packets back).

Also I would very much prefer ptrace/gdb to show me the syscall where
the memory management fault happened and not the next one.

> If I get 4 frames, and the kernel can successfully copy the first
> three and get an -EFAULT on the 4th.  Dammit you better tell the
> application this so it can properly process the first 3 packets and
> then determine how it is going to error out and recover for the 4th
> one.
> 
> If we need to add prioritized sk_err stuff, or another value like
> "sk_app_err" to handle the ICMP vs. -EFAULT issue, so be it.
> 
> I know what you guys are thinking, in that you can't figure out a
> way to avoid the transactional overhead if it is necessary to
> "put back" some SKBs if one of them in the batch gets a fault.

I prefer correctness over performance all the time. :)

> That's too bad, we need a proper implementation and proper error
> reporting.  Those performance numbers are useless if we effectively
> lose error notifications.

We have those problems right now and besides deprecating the syscalls I
have no idea how to fix this reliably and would probably need a lot of
changes (besides the sk_app_err solution, which I don't really favor at
all).

The syscall should have been designed in a way that the struct mmsghdr
-> msg_len would be ssize_t, so we could return error codes per fragment
and test before starting the batch that we have proper memory, so we
don't fail in the management code. :(

Bye,
Hannes
