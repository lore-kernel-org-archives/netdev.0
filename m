From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Wed, 28 May 2014 12:07:20 -0300
Message-ID: <20140528150720.GB2764@kernel.org>
References: <20140512143451.GB13801@kernel.org>
 <20140521210535.GA5414@kernel.org>
 <537E0961.8040005@gmail.com>
 <20140526134647.GB8176@kernel.org>
 <20140526211706.GA25474@kernel.org>
 <5384BEC5.2080607@gmail.com>
 <20140527192115.GD25474@kernel.org>
 <CAKgNAkht1vubHueYPpkRu_W5B8OYW3rPUkHeLEq5WMVbCvO47w@mail.gmail.com>
 <20140527203010.GA2764@kernel.org>
 <5385D47A.3070401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	"linux-man@vger.kernel.org" <linux-man@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?utf-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <steve@chygwyn.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>, Paul Moore <paul@paul-moore.com>,
	Chris Friesen <chris.friesen@windriver.com>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5385D47A.3070401@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, May 28, 2014 at 02:20:10PM +0200, Michael Kerrisk (man-pages) escreveu:
> On 05/27/2014 10:30 PM, Arnaldo Carvalho de Melo wrote:
> > attached goes the updated patch, and this is the
> > diff to the last combined one:
> > 
> > diff --git a/net/socket.c b/net/socket.c
> > index 310a50971769..379be43879db 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -2478,8 +2478,7 @@ SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
> >  
> >  	datagrams = __sys_recvmmsg(fd, mmsg, vlen, flags, &timeout_sys);
> >  
> > -	if (datagrams > 0 &&
> > -	    copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
> > +	if (copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
> >  		datagrams = -EFAULT;
> >  
> >  	return datagrams;
> >  
> > ------------------------------------------
> > 
> > This is a quick thing just to show where the problem lies, need to think
> > how to report an -EFAULT at this point properly, i.e. look at

Ok, so I can live with the way things were before this fix, i.e. if the
user specifies a timeout, then if it fails when copying to remaining
time to userspace (copy_to_user call above), then we return -EFAULT.

I.e. there would be no change in behaviour, but then perhaps we should
go with the interface that is in place when we received some datagrams
and then some error happens, see comment in the existing code, below:

> > __sys_recvmmsg for something related (returning the number of
> > successfully copied datagrams to userspace while storing the error for
> > subsequent reporting):
> > 
> >         if (err == 0)
> >                 return datagrams;
> > 
> >         if (datagrams != 0) {
> >                 /*
> >                  * We may return less entries than requested (vlen) if
> >                  * the sock is non block and there aren't enough
> >                  * datagrams...
> >                  */
> >                 if (err != -EAGAIN) {
> >                         /*
> >                          * ... or  if recvmsg returns an error after we
> >                          * received some datagrams, where we record the
> >                          * error to return on the next call or if the
> >                          * app asks about it using getsockopt(SO_ERROR).
> >                          */
> >                         sock->sk->sk_err = -err;
> >                 }
> > 
> >                 return datagrams;
> >         }
> > 
> > I.e. userspace would have to use getsockopt(SO_ERROR)... need to think
> > more about it, sidetracked now, will be back to this.
> > 
> > Anyway, attached goes the current combined patch.
 
> So, I applied against net-next as you suggested offlist.
> Builds and generally tests fine. Some observations:
 
> * In the case that the call is interrupted by a signal handler and no
>   datagrams have been received, the call fails with EINTR, as expected.

Ok
 
> * The call always updates 'timeout', both in the success case and in the
>   EINTR case. (That seems fine.)

Agreed that it is how it should behave.
 
> But, another question...
> 
> In the case that the call is interrupted by a signal handler and some
> datagrams have already been received, then the call succeeds, and
> returns the number of datagrams received, and 'timeout' is updated with
> the remaining time. Maybe that's the right behavior, but I just want to

Note that what the comment in the existing code says should apply here,
namely that the next recv (m or mmsg) syscall on this socket will return
what is in sock->sk->sk_err, that is the signal:

  sys_recvmmsg()
      sock->ops->recvmsg() (e.g. inet_recvmsg)
          sk->prot->recvmsg() (e.g., udp_recvmsg)
              skb_recv_datagram()
                  wait_for_more_packets()
                      sock_intr_errno()
                        *err = -EINTR
      sock->sk->sk_err = err

Next recv will end up calling skb_recv_datagram and that does:

struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
                                    int *peeked, int *off, int *err, long *timeop)
{
        struct sk_buff *skb, *last;
        long timeo;
        /*
         * Caller is allowed not to check sk->sk_err before
         * skb_recv_datagram()
         */
        int error = sock_error(sk);

        if (error)
                goto no_packet;
<SNIP>
out:
	if (timeop)
		*timeop = timeo;
	return NULL;

no_packet:
	*err = error;
	goto out;
}

So, yes, the user _can_ process the packets already copied to userspace,
i.e. no packet loss, and then, on the next call, will receive the signal
notification.

So, the user can just try the next call and see the signal, and it is
also possible to notice that the timeout didn't expire and less than
vlen packets were received, so something went wrong and calling
getsockopt(SO_ERROR) will clarify things.

This is not some new error reporting facility, it predates recvmmsg,
that merely uses it for consistency.

How to properly report the -EFAULT when copying the remaining timeout to
userspace is the special case here, with my patches it will:

. copy n (less than vlen) packets to userspace successfully
. return -EFAULT, not n, just as before the patches being cooked now.

> check. There is at least one other possibility:
> 
> * Fetch no datagrams (i.e., the datagrams are left to receive in a
>   future call), and the call fails with EINTR, and 'timeout' is updated.

Humm, then we would have to go back to the protocol layer and re-add the
packets to queues, etc, etc, not feasible, I'd say, too much state was
lost already, we would have to have some sort of commit interface
(perhaps using peek, but that gets crazy quickly with multithreaded
apps), guess its a super intrusive path to follow, not worth it, I
think.

> Maybe that possibility is hard to implement (not sure). But my main point
> is to make the current behavior clear, note the alternative, and ask:
> is the current behavior the best choice. (I'm not saying it's not, but I
> do want the choice to be a conscious one.)

Well, my main pet peeve here is how to report that we managed to copy
the datagrams but failed to copy the remaining timeout and then don't
report how many datagrams were successfully copied.

I'm inclined to say that failing to copy the timeout is something so
unlikely, even more since we managed to copy it from userspace to kernel
space at that point in time, that we should keep the current behaviour
and report that something terribly wrong happened, i.e. -EFAULT when
copying the timeout.

Thanks a lot for testing all this, was a pity you were not around when
we first designed and implemented this syscall.

And also it would be really nice if the people in the CC list commented
on this last round of discussion about fixing the timeout behavior.

- Arnaldo
