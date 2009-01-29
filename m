From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [ofa-general] Re: [PATCH 01/21] RDS: Socket interface
Date: Thu, 29 Jan 2009 19:24:25 +0300
Message-ID: <20090129162425.GA31947@ioremap.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-2-git-send-email-andy.grover@oracle.com>
	<20090127120840.GC2646@ioremap.net>
	<c0a09e5c0901282002k3e1083ebifb7fb31d15d93b8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <c0a09e5c0901282002k3e1083ebifb7fb31d15d93b8e@mail.gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Andy.

On Wed, Jan 28, 2009 at 08:02:49PM -0800, Andrew Grover (andy.grover@gmail.com) wrote:
> Hi Evgeniy thanks for your time in reviewing.

No problem :)

> >> +/* this is just used for stats gathering :/ */
> >
> > Shouldn't this be some kind of per-cpu data?
> > Global list of all sockets? This does not scale, maybe it should be
> > groupped into hash table or be per-device?
> 
> sch mentioned this too... is socket creation often a bottleneck? If so
> we can certainly improve scalability here.

It depends on the workload, but and it becomes a noticeble portion of
the overhead for multi-client short-living connections. Likely this
sockets will not be used for web-server like load, but something similar
will clearly show a bottleneck with this list.

> In any case, this is in the code to support a listing of RDS sockets
> via the rds-info utility. Instead of having our own custom program to
> list rds sockets we probably want to export an interface so netstat
> will list them. Unfortunately netstat seems to be hardcoded to look
> for particular entries in /proc/net, so both rds and netstat would
> need to be updated before this would work, and RDS's custom
> socket-listing interface dropped.

Other sockets use similar technique, but they are groupped into hash
table, so if you think that amount of socket will be noticebly large or
they will be frequently created and removed, it may worth pushing them
into the hash table.

> Is that an appropriate usage of sock_orphan()?

It is, I missed the process context socket detouch, things are correct.

> > Does RDS sockets work with high number of creation/destruction
> > workloads?
> 
> I'd guess from your comments that performance probably wouldn't be great :)

Something tells me the same :)

> >> +static unsigned int rds_poll(struct file *file, struct socket *sock,
> >> +                          poll_table *wait)
> >> +{
> >> +     struct sock *sk = sock->sk;
> >> +     struct rds_sock *rs = rds_sk_to_rs(sk);
> >> +     unsigned int mask = 0;
> >> +     unsigned long flags;
> >> +
> >> +     poll_wait(file, sk->sk_sleep, wait);
> >> +
> >> +     poll_wait(file, &rds_poll_waitq, wait);
> >> +
> >
> > Are you absolutely sure that provided poll_table callback
> > will not do the bad things here? It is quite unusual to add several
> > different queues into the same head in the poll callback.
> > And shouldn't rds_poll_waitq be lock protected here?
> 
> I don't know. I looked into the poll_wait code a little and it
> appeared to be designed to allow multiple.
> 
> I'm not very strong in this area and would love some more expert input here.

It depends on how poll_table was initialized and how its callback
(invoked from the poll_wait()) operates with the given queue and head.
If you introduce own polling, some care has to be taken there for the
ordering of the wait queues and what their callbacks return when polling
even found.

For example with the own initialization it is possible that with
multiple queues are registered in the same table, only one of them
will be awakened (its callback invoked).

If you just hook into existing machinery things should be ok though, so
this is just something to pay attention and does not show a bug.

> >> +     read_lock_irqsave(&rs->rs_recv_lock, flags);
> >> +     if (!rs->rs_cong_monitor) {
> >> +             /* When a congestion map was updated, we signal POLLIN for
> >> +              * "historical" reasons. Applications can also poll for
> >> +              * WRBAND instead. */
> >> +             if (rds_cong_updated_since(&rs->rs_cong_track))
> >> +                     mask |= (POLLIN | POLLRDNORM | POLLWRBAND);
> >> +     } else {
> >> +             spin_lock(&rs->rs_lock);
> >
> > Is there a possibility to have lock iteraction problem with above
> > rs_recv_lock read lock?
> 
> I didn't see anywhere where they were being acquired in reverse order,
> or simultaneously. This is the kind of thing that lockdep would find
> immediately, right? I think I've got that turned on but I'll double
> check.

If lockdep entered the bad race, then yes, it will fire this up.
I just wondered that we spin lock under the read lock, so some bad
iteration with writelock may happen.

> >> +             cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
> >> +                   be16_to_cpu(rs->rs_bound_port);
> >> +
> >> +             if (needle < cmp)
> >
> > Should it use wrapping logic if some field overflows?
> 
> Sorry, please explain?

I meant that if there is an unsigned overflow this will suddenly become
a small number, so network timestamping comparison logic can be used,
but apparently neither address nor port are changed during the lifetime,
so nothing special is needed.

-- 
	Evgeniy Polyakov
