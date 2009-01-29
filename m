From: Andrew Grover <andy.grover@gmail.com>
Subject: [ofa-general] Re: [PATCH 01/21] RDS: Socket interface
Date: Wed, 28 Jan 2009 20:02:49 -0800
Message-ID: <c0a09e5c0901282002k3e1083ebifb7fb31d15d93b8e@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-2-git-send-email-andy.grover@oracle.com>
	<20090127120840.GC2646@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090127120840.GC2646@ioremap.net>
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

On Tue, Jan 27, 2009 at 4:08 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> Hi Andy.

Hi Evgeniy thanks for your time in reviewing.

>> +/* this is just used for stats gathering :/ */
>
> Shouldn't this be some kind of per-cpu data?
> Global list of all sockets? This does not scale, maybe it should be
> groupped into hash table or be per-device?

sch mentioned this too... is socket creation often a bottleneck? If so
we can certainly improve scalability here.

In any case, this is in the code to support a listing of RDS sockets
via the rds-info utility. Instead of having our own custom program to
list rds sockets we probably want to export an interface so netstat
will list them. Unfortunately netstat seems to be hardcoded to look
for particular entries in /proc/net, so both rds and netstat would
need to be updated before this would work, and RDS's custom
socket-listing interface dropped.

>> +static int rds_release(struct socket *sock)
>> +{
>> +     struct sock *sk = sock->sk;
>> +     struct rds_sock *rs;
>> +     unsigned long flags;
>> +
>> +     if (sk == NULL)
>> +             goto out;
>> +
>> +     rs = rds_sk_to_rs(sk);
>> +
>> +     sock_orphan(sk);
>
> Why is it needed getting socket is about to be freed?

from the comments above that code:

 * We have to be careful about racing with the incoming path.  sock_orphan()
 * sets SOCK_DEAD and we use that as an indicator to the rx path that new
 * messages shouldn't be queued.

Is that an appropriate usage of sock_orphan()?

> Does RDS sockets work with high number of creation/destruction
> workloads?

I'd guess from your comments that performance probably wouldn't be great :)

>> +static unsigned int rds_poll(struct file *file, struct socket *sock,
>> +                          poll_table *wait)
>> +{
>> +     struct sock *sk = sock->sk;
>> +     struct rds_sock *rs = rds_sk_to_rs(sk);
>> +     unsigned int mask = 0;
>> +     unsigned long flags;
>> +
>> +     poll_wait(file, sk->sk_sleep, wait);
>> +
>> +     poll_wait(file, &rds_poll_waitq, wait);
>> +
>
> Are you absolutely sure that provided poll_table callback
> will not do the bad things here? It is quite unusual to add several
> different queues into the same head in the poll callback.
> And shouldn't rds_poll_waitq be lock protected here?

I don't know. I looked into the poll_wait code a little and it
appeared to be designed to allow multiple.

I'm not very strong in this area and would love some more expert input here.

>> +     read_lock_irqsave(&rs->rs_recv_lock, flags);
>> +     if (!rs->rs_cong_monitor) {
>> +             /* When a congestion map was updated, we signal POLLIN for
>> +              * "historical" reasons. Applications can also poll for
>> +              * WRBAND instead. */
>> +             if (rds_cong_updated_since(&rs->rs_cong_track))
>> +                     mask |= (POLLIN | POLLRDNORM | POLLWRBAND);
>> +     } else {
>> +             spin_lock(&rs->rs_lock);
>
> Is there a possibility to have lock iteraction problem with above
> rs_recv_lock read lock?

I didn't see anywhere where they were being acquired in reverse order,
or simultaneously. This is the kind of thing that lockdep would find
immediately, right? I think I've got that turned on but I'll double
check.

>> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24)
>
> This should be dropped in the mainline tree.

yup.

> Hash table with the appropriate size will have faster lookup/access
> times btw.

No doubt. Definitely want to make this improvement at some point.

>> +static struct rds_sock *rds_bind_tree_walk(__be32 addr, __be16 port,
>> +                                        struct rds_sock *insert)
>> +{
>> +     struct rb_node **p = &rds_bind_tree.rb_node;
>> +     struct rb_node *parent = NULL;
>> +     struct rds_sock *rs;
>> +     u64 cmp;
>> +     u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
>> +
>> +     while (*p) {
>> +             parent = *p;
>> +             rs = rb_entry(parent, struct rds_sock, rs_bound_node);
>> +
>> +             cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
>> +                   be16_to_cpu(rs->rs_bound_port);
>> +
>> +             if (needle < cmp)
>
> Should it use wrapping logic if some field overflows?

Sorry, please explain?

>> +     rdsdebug("returning rs %p for %u.%u.%u.%u:%u\n", rs, NIPQUAD(addr),
>> +             ntohs(port));
>
> Iirc there is a new %pi4 or similar format id.

Yup, will do.

Thanks again.

Regards -- Andy
