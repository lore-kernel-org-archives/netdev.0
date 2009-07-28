From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Tue, 28 Jul 2009 09:00:06 -0700
Message-ID: <874oswer21.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-3-git-send-email-danms@us.ibm.com>
	<1248555754.16746.55.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:56143 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754601AbZG1QAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 12:00:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

JD> I don't know whether this would affect palatibility (sic) for the
JD> mainline, but it bothers me...  socket.h (and sock.h) are included
JD> all over the place in the kernel, and this definition is only
JD> needed in very limited locations.  Can it be placed in a .h used
JD> only by checkpoint code?

This was moved here based on previous comments on the patch.
Personally, I think socket.h is a little too wide.  While iterating on
this patch locally, I've discovered that socket.h won't really work
because in6.h includes it early and thus I'm unable to include some of
the address structures as a result.  I think going back to a
checkpoint-specific header would be helpful.

JD> There's an interesting design choice re TIME_WAIT and similar
JD> states.  In a migration scenario, do those sks migrate?  If the
JD> tree isn't going to be restored for a while., you want the
JD> original host to continue to respond to those four-tuples If the
JD> IP address of the original is immediately migrated to another
JD> machine, you want the TIME_WAIT sks to migrate too.

Well, as far as I'm concerned, the only sane migration scenario is one
where you migrate the IP address and virtual interface with the
task.  When you destroy the virtual interface after (or during) the
migration, the TIME_WAIT socket will disappear from the sending host.

I think that we need to increment timers like this on restore anyway,
which should make sure that the TIME_WAIT timers run for the same
amount of wall-clock time regardless of how much time was spent in the
process of migration, right?

Since checkpoint is not aware of a potential migration, a regular
(i.e. not intended for migration) checkpoint operation on a task
running in the init netns will leave the TIME_WAIT socket in place
until the timer expires.

>> +static int sock_inet_restart(struct ckpt_ctx *ctx,
>> +			     struct ckpt_hdr_socket *h,
>> +			     struct socket *socket)
>> +{
>> +	int ret;
>> +	struct ckpt_hdr_socket_inet *in;
>> +	struct sockaddr_in *l = (struct sockaddr_in *)&h->laddr;
>> +
>> +	in = ckpt_read_obj_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_INET);
>> +	if (IS_ERR(in))
>> +		return PTR_ERR(in);
>> +
>> +	/* Listening sockets and those that are closed but have a local
>> +	 * address need to call bind()
>> +	 */
>> +	if ((h->sock.state == TCP_LISTEN) ||
>> +	    ((h->sock.state == TCP_CLOSE) && (h->laddr_len > 0))) {
>> +		socket->sk->sk_reuse = 2;
>> +		inet_sk(socket->sk)->freebind = 1;
>> +		ret = socket->ops->bind(socket,
>> +					(struct sockaddr *)l,
>> +					h->laddr_len);
>> +		ckpt_debug("inet bind: %i", ret);
>> +		if (ret < 0)
>> +			goto out;
>> +
>> +		if (h->sock.state == TCP_LISTEN) {
>> +			ret = socket->ops->listen(socket, h->sock.backlog);
>> +			ckpt_debug("inet listen: %i", ret);
>> +			if (ret < 0)
>> +				goto out;
>> +
>> +			ret = sock_add_parent(ctx, socket->sk);
>> +			if (ret < 0)
>> +				goto out;

JD> So this is just dummied off as a proof-of-concept for LISTEN?

I'm not sure what you mean...

>> +		}
>> +	} else {
>> +		ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
>> +		if (ret)
>> +			goto out;
>> +
>> +		ret = sock_inet_cptrst(ctx, socket->sk, in, CKPT_RST);
>> +		if (ret)
>> +			goto out;

JD> At a minimum, you'll want to start the TCP retransmit timer if there is
JD> unacknowledged data outstanding.  And other timers for other states, as
JD> they're supported.

JD> And you probably do want to do slow-start again--disregard my babbling
JD> from yesterday. 

Heh, okay :)

JD> This is part of your AF_UNIX patch:

JD>         struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
JD>         				    struct ckpt_hdr_socket *h)
JD>         {
JD>         	struct socket *socket;
JD>         	int ret;
        
JD>         	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
JD>         	if (ret < 0)
JD>         		return ERR_PTR(ret);
        

JD> You _really_ want to pass the actual protocol number to sock_create().
JD> The size of the sk it creates depends on this.  You'll quickly be in
JD> memory corruption hell without it.

You mean I need to verify that the protocol is one of IPPROTO_TCP,
IPPROTO_UDP, or PF_UNIX, right?

JD> Also from the AF_UNIX patch:
        
JD>         static int obj_sock_users(void *ptr)
JD>         {
JD>         	return atomic_read(&((struct sock *) ptr)->sk_refcnt);
JD>         }
        
JD> Network sockets also use sk->sk_wmem_alloc to track references to
JD> the sock from egress skb's

IIUC, this function is part of the framework's leak detection.  That
code looks to make sure objects don't gain any additional users
between the start and end of the checkpoint operation.  I think the
sk_refcnt satisfies that requirement here, no?

JD> And:

JD>         static int sock_copy_buffers(struct sk_buff_head *from, struct
JD>         sk_buff_head *to)
JD>         {
JD>         	int count = 0;
JD>         	struct sk_buff *skb;
        
JD>         	skb_queue_walk(from, skb) {
JD>         		struct sk_buff *tmp;
        
JD>         		tmp = dev_alloc_skb(skb->len);
JD>         		if (!tmp)
JD>         			return -ENOMEM;
        
JD>         		spin_lock(&from->lock);
JD>         		skb_morph(tmp, skb);
JD>         		spin_unlock(&from->lock);

JD> Why not just clone the skb?

Okay, good call.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
