From: Eric Paris <eparis@redhat.com>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Fri, 07 Mar 2014 17:52:02 -0500
Message-ID: <1394232722.17779.57.camel@flatline.rdu.redhat.com>
References: <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	 <87mwh5d1tf.fsf@xmission.com>
	 <20140304.192152.1234652192226780071.davem@davemloft.net>
	 <7457128.6VP2v68V93@x2> <87wqg8zfj4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Grubb <sgrubb@redhat.com>, rgb@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-audit@redhat.com, akpm@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wqg8zfj4.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As usual Eric, your commentary is anything but useful.  However your
technical thoughts are not off the mark.  Can we stick to those?

On Wed, 2014-03-05 at 10:06 -0800, Eric W. Biederman wrote:
> Steve Grubb <sgrubb@redhat.com> writes:
> 
> > On Tuesday, March 04, 2014 07:21:52 PM David Miller wrote:
> >> From: ebiederm@xmission.com (Eric W. Biederman)
> >> Date: Tue, 04 Mar 2014 14:41:16 -0800
> >> 
> >> > If we really want the ability to always appened to the queue of skb's
> >> > is to just have a version of netlink_send_skb that ignores the queued
> >> > limits.  Of course an evil program then could force the generation of
> >> > enough audit records to DOS the kernel, but we seem to be in that
> >> > situation now.  Shrug.
> >> 
> >> There is never a valid reason to bypass the socket limits.

Audit does have some pretty crazy/wacky/dumb ways of doing things.  And
they've worked really well.  I'm the first to agree that doesn't make
them right.  But also that I don't know how to do them better.  I'm
happy to try if I know how.  Audit is non-tolerant to failure and loss.
Many users of audit would prefer the system panic() than lose a message.
If someone shows me how to do it better I'll happily admit there are
likely places where what we do is just a 'little' too
strong/foolish/crazy.  Note that ALL users of these functions must have
at least 1 capability (CAP_AUDIT_CONTROL).  So if there is a malicious
app, it is a root malicious app...

The kernel audit has 3 different 'things' that send skbs to userspace.
All of them work a little crazy, but similar crazy.  The current task
calls into the kernel via netlink, and the kernel then builds one or
more skb(s) and passes those skb(s) (via differing mechanisms) to a
kthread which in turn calls netlink_unicast(,,,0) sending the response
back to the current task in 2 of the three cases.  In all cases, since
the timeout is infinite, we assume that the only possible reason this
call to netlink_unicast() will fail is because the other end of the
socket went away.  Simple drawing of 2 of the 3 cases.
     +------------------------------------------------------------------+
     |                                                                  |
     |               auditctl (audit tool run by root)                  |
     |         netlink send                         netlink receive     |
     +------------------------------------------------------------------+
                    +                                        ^
                    |                                        |
                    v                                        +
        +----------------------------+        +------------------------+
        | kernel audit generate skbs |        | send skbs to userspace |
        +----------------------------+        +------------------------+
                    +                                        ^
                    |        +------------------------+      |
                    +------->| send skbs to a kthread |+-----+
                             +------------------------+
The most important of the 3 cases and the one that people care the
absolute most about 'things cannot be lost' is the actual audit
messages.  Messages like 'process A just did action B to object C'.
These are handled by means of the current process generating an skb and
passing those to an audit specific queue.  This audit internal queue
depth is controllable by userspace.  If we overflow this queue we may
call panic() (admin choice, obviously non-default).  Again, the kthread
on the other end of that queue assumes that all calls to
netlink_unicast(,,,0) will eventually succeed (unless the receiving task
died).  It is actually imperative that the current process be blocked
until the message is on track to userspace.  Even Eric isn't trying to
change this one case in his patch.  This is the one case where the task
receiving the skb is not (likely) the current task (but could be)

The other two, the ones Eric patched, are much more flexible.  In both
cases a userspace task ask the kernel for a specific piece of
information (by sending a netlink message).  current is going to be the
task draining the netlink queue.  This is the reason the send is being
punted to a kthread.  So current can read from the netlink socket.  In
one case audit_send_reply_thread() the response is small and can't
really grow without bound.  Converting to a nonblocking socket might
well make sense here.

The second user Eric patched, audit_send_list(), can grow without bound.
The number of skb's is going to be the size of the number of audit rules
that root loaded.  We run the list of rules, generate an skb per rule,
and add all of them to an skb_buff_head.  We then pass the skb_buff_head
to a kthread so that current will be able to read/drain the socket.
There really is no limit to how big the skb_buff_head could possibly
grow.  This doesn't necessarily absolutely have to be lossless but it
can actually quite reasonably be a whole lot of data that needs to get
sent.  I know of no way to deliver unbounded lengths of data to the
current task via netlink without blocking on more space in the socket.
Even if the socket rmem was MAX_INT, how can we deliver more?  The rule
size is unbounded.  How do I get an unbounded amount of data onto this
side of the socket when I have to generate it all during the request...

Tell me how to architect it better and I'll look at it.
