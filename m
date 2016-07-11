From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v15 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Mon, 11 Jul 2016 14:19:42 +0000
Message-ID: <CO2PR03MB21822875F7A13F6573C6DFA2BF3F0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB218262D499C54791C1634FC2BF3C0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <87a8hstcx1.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>, Dave
 Scott <dave.scott@docker.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87a8hstcx1.fsf@vitty.brq.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
>  ...
> Some comments below. The vast majority of them are really minor, the
> only thing which bothers me a little bit is WARN() in hvsock_sendmsg()
> which I think shouldn't be there. But I may have missed something.
 
Thank you for the very detailed comments, Vitaly!

Now I see I shouldn't put pr_err() in hvsock_sendmsg() and hvsock_recvmsg(),
because IMO a malicious app can use this to generate lots of messages to slow
down the system.  I'll remove them.

I'll reply your other comments bellow.

> > +#define guid_t uuid_le
> > +struct sockaddr_hv {
> > +	__kernel_sa_family_t	shv_family;  /* Address family		*/
> > +	u16		reserved;	     /* Must be Zero		*/
> > +	guid_t		shv_vm_id;	     /* VM ID			*/
> > +	guid_t		shv_service_id;	     /* Service ID		*/
> > +};
> 
> I'm not sure it is worth it to introduce a new 'guid_t' type here, we
> may want to rename
> 
> shv_vm_id -> shv_vm_guid
> shv_service_id -> shv_service_guid
> 
> and use uuid_le type.

Ok. I'll make the change.

> > +config HYPERV_SOCK
> > +	tristate "Hyper-V Sockets"
> > +	depends on HYPERV
> > +	default m if HYPERV
> > +	help
> > +	  Hyper-V Sockets is somewhat like TCP over VMBus, allowing
> > +	  communication between Linux guest and Hyper-V host without TCP/IP.
> > +
> 
> I know it's hard to come up with a simple description but I'd rather
> describe is as "Socket interface for high speed communication between
> Linux guest and Hyper-V host over VMBus."

OK.

> > +static bool uuid_equals(uuid_le u1, uuid_le u2)
> > +{
> > +	return !uuid_le_cmp(u1, u2);
> > +}
> 
> why not use uuid_le_cmp directly?
OK. I will change to it.

> > +static unsigned int hvsock_poll(struct file *file, struct socket *sock,
> > +				poll_table *wait)
>> ...
> > +	if (channel) {
> > +		/* If there is something in the queue then we can read */
> > +		get_ringbuffer_rw_status(channel, &can_read, &can_write);
> > +
> > +		if (!can_read && hvsk->recv)
> > +			can_read = true;
> > +
> > +		if (!(sk->sk_shutdown & RCV_SHUTDOWN) && can_read)
> > +			mask |= POLLIN | POLLRDNORM;
> > +	} else {
> > +		can_read = false;
> 
> we don't use can_read below

I'll remove the can_read assignment.

> > +	channel = hvsk->channel;
> > +	if (!channel) {
> > +		WARN_ONCE(1, "NULL channel! There is a programming
> bug.\n");
> 
> BUG() then

OK.

> > +static int hvsock_open_connection(struct vmbus_channel *channel)
> > +{
> > + ......
> > +	if (conn_from_host) {
> > +		if (sk->sk_ack_backlog >= sk->sk_max_ack_backlog) {
> > +			ret = -EMFILE;
> 
> I'm not sure -EMFILE is appropriate, we don't really have "too many open
> files".
Here the ret value doesn't really matter, because the return value of the
function is not really used at present.

However, I agree with you that EMFILE is unsuitable.
Let me change to ECONNREFUSED, which seems better to me.

> > +static int hvsock_connect_wait(struct socket *sock,
> > +			       int flags, int current_ret)
> > +{
> > +	struct sock *sk = sock->sk;
> > +	struct hvsock_sock *hvsk;
> > +	int ret = current_ret;
> > +	DEFINE_WAIT(wait);
> > +	long timeout;
> > +
> > +	hvsk = sk_to_hvsock(sk);
> > +	timeout = 30 * HZ;
> 
> We may want to introduce a define for this timeout. Does it actually
> match host's timeout?

I'll add HVSOCK_CONNECT_TIMEOUT for this.
Yes, the value is from Hyper-V team.
 
> > +static int hvsock_accept_wait(struct sock *listener,
> > + ......
> > +
> > +		if (ret) {
> > +			release_sock(connected);
> > +			sock_put(connected);
> > +		} else {
> > +			newsock->state = SS_CONNECTED;
> > +			sock_graft(connected, newsock);
> > +			release_sock(connected);
> > +			sock_put(connected);
> 
> so we do release_sock()/sock_put() unconditionally and this piece could
> be rewritten as
> 
>     if (!ret) {
>         newsock->state = SS_CONNECTED;
>         sock_graft(connected, newsock);
>     }
>     release_sock(connected);
>     sock_put(connected);

Will do.


> > +static int hvsock_listen(struct socket *sock, int backlog)
> > +{
> > + ......
> > +	/* This is an artificial limit */
> > +	if (backlog > 128)
> > +		backlog = 128;
> 
> Let's do a define for it.
Ok.
 
> > +static int hvsock_sendmsg(struct socket *sock, struct msghdr *msg,
> > +			  size_t len)
> > +{
> > +	struct hvsock_sock *hvsk;
> > +	struct sock *sk;
> > +	int ret;
> > +
> > +	if (len == 0)
> > +		return -EINVAL;
> > +
> > +	if (msg->msg_flags & ~MSG_DONTWAIT) {
> > +		pr_err("%s: unsupported flags=0x%x\n", __func__,
> > +		       msg->msg_flags);
> 
> I don't think we need pr_err() here.
 
OK.

> > +	/* ret is a bigger-than-0 total_written or a negative err code. */
> > +	if (ret == 0) {
> > +		WARN(1, "unexpected return value of 0\n");
> > +		ret = -EIO;
> > +	}
> 
> It seems hvsock_sendmsg_wait() can return 0. I see the following code there:
> 
>          max_writable = get_ringbuffer_writable_bytes(channel);
>          if (max_writable == 0)
>              goto out_wait;

hvsock_sendmsg_wait() can not return 0: in the function, when we exit from
the level-2 "while (1)" loop by "break",  normally can_write is true, meaning
get_ringbuffer_writable_bytes() returns at least 4096. Please see
get_ringbuffer_rw_status().
 
> so if there is no space on the ringbuffer we won't write
> anything. WARN() is inapropriate then.

I'll remove the default value of 0 for the 'ret ' in hvsock_sendmsg_wait() and
repalace the WARN() to BUG_ON(ret == 0) in hvsock_sendmsg().

> > +static int hvsock_recvmsg(struct socket *sock, struct msghdr *msg,
> > +			  size_t len, int flags)
> > ...
> > +	/* We ignore msg->addr_name/len. */
> > +	if (flags & ~MSG_DONTWAIT) {
> > +		pr_err("%s: unsupported flags=0x%x\n", __func__, flags);
> 
> Here he may also want to drop pr_err()

OK.

> > +static int hvsock_create_sock(struct net *net, struct socket *sock,
> > +			      int protocol, int kern)
> > +{
> > +	struct sock *sk;
> > +
> > +	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
> > +		return -EPERM;
> 
> I'd say we're OK with CAP_SYS_ADMIN only for now and we'll be able to
> drop the check when host starts supporting single pair of ringbuffers
> for all Hyper-V sockets on the system.
I agree.
 
> > +static int __init hvsock_init(void)
> > +{
> > +	int ret;
> > +
> > +	/* Hyper-V Sockets requires at least VMBus 4.0 */
> > +	if ((vmbus_proto_version >> 16) < 4)
> > +		return -ENODEV;
> 
> So it's actually
> 
>   if (vmbus_proto_version < VERSION_WIN10)
> 
> I suggest we use such comparisson to be in line with other places where
> vmbus_proto_version is checked.
Sure. Thanks!

I'll post v16 shortly.

Thanks,
-- Dexuan
