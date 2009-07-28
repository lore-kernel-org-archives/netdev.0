From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 28 Jul 2009 17:18:17 -0400
Message-ID: <4A6F6B19.9010508@librato.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>	<1248295301-30930-6-git-send-email-danms@us.ibm.com>	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:57350 "EHLO
	smtp131.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbZG1VSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:18:18 -0400
In-Reply-To: <87ljm8czsf.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> obj_sock_users() is only required for objects that are to be
> OL> tested for leaks in full container checkpoint. I don't think it's
> OL> needed, because the relation sock <-> file is 1-to-1.  (If it
> OL> were, then you would also need to collect sockets).
> 
> Okay, that also answers the question posed by John in the other
> thread.
> 
> OL> (Actually, I will remove checkpoint_bad and restore_bad and modify
> OL> checkpoint_obj() and restore_obj() to fail if the respective
> OL> method is NULL).
> 
> Okay, should I expect that to show up in v17-dev soon?

Yes.

> 
> OL> Nit: I already got confused a few times because of the similar
> OL> names.  Perhaps change CKPT_HDR_SOCKET_BUFFERS to
> OL> CKPT_HDR_SOCKET_QUEUE (and adjust the header name accordingly).
> 
> Agreed.  I remember writing that and remarking to myself how
> ridiculous of a name it was, but never went back to change it.
> 
> OL> Unless/until we decide otherwise, let's keep all ckpt_hdr_xxx
> OL> definitions in a single place -- checkpoint_hdr.h
> 
> That's how I initially had it, but Serge asked for it to be moved into
> the network headers.  Serge?
> 
> OL> Unless you intend to use the struct name 'ckpt_socket' elsewhere,
> OL> can we get rid of it (leaving only 'struct {') ?
> 
> Yep.
> 
> OL> Can you use fill_name() from checkpoint/file.c ?
> 
> Yeah, looks like it.
> 
> OL> This direct call to ->getname skips security checks through
> OL> getsockname(). You may want to refactor sys_getsockname() similar
> OL> to sys_bind().
> 
> Okay.
> 
>>> +	if ((h->sock.userlocks & SOCK_SNDBUF_LOCK) &&
>>> +	    ((h->sock.sndbuf < SOCK_MIN_SNDBUF) ||
>>> +	     (h->sock.sndbuf > sysctl_wmem_max)))
>>> +		return -EINVAL;
> 
> OL> At least for afunix, if the user did not explicitly set the
> OL> sndbuf, then userlocks won't have SOCK_SNDBUF_LOCK set.
> 
> OL> Also, if userlocks in the image doesn't have SOCK_SNDBUF_LOCK,
> OL> then the sndbuf value isn't checked ?
> 
> I think I was thinking that I only needed to verify the buffer value
> if the user claimed to have set it (as if it would be ignored
> otherwise), but that doesn't seem right.  So, I think the proper
> thing to do here is always check it (i.e., remove the first check of
> the lock).
> 
> OL> What about verifying sock.flags itself ?
> OL> In doing that, some options may assume/require some state --
> OL> - SOCK_USE_WRITE_QUEUE only used in ipv4/ipv6/sctp
> OL> - SOCK_DESTROY only used in some protocols
> 
> OL> Perhaps sanitize sock.flags per protocol ?
> 
> Hmm, okay.
> 
> OL> Many of these direct copy into the socket and sock effectively
> OL> bypass security checks that take place in {get,set}sockopt(),
> OL> either explicitly (e.g. sk_sndtimeo) or implicitly (e.g.
> OL> SOCK_LINGER in sock.flags, reflecting SO_LINGER option).
> 
> OL> This applies both to checkpoint (potentially bypassing permission
> OL> of the checkpointer to view this data) and restart (bypassing
> OL> permissions of user to set these values).
> 
> OL> The alternative is to use socksetopt/sockgetopt for those values
> OL> that should be subject to security checks.
> 
> Yeah, I suppose so.  I've resisted that thus far because it will make
> the sync operation so much harder to read, but I suppose it's
> unavoidable.
> 
> OL> There should also be per-protocol consistency checks. E.g. afunix
> OL> cannot be in socket.state == SS_{DIS,}CONNECTING
> 
> I suppose so, but I don't see anything in af_unix.c that seems to care :)
> 
> OL> Better yet: -ENOSYS ?
> 
> Okay.
> 
>>> +	ret = kernel_sendmsg(sock->sk_socket, &msg, &kvec, 1, len);
> 
> OL> Is it possible to avoid the extra copy using splice() instead ?
> 
> It's possible, but it will require some refactoring to get access to
> all the right pointers.  I'd propose we push that optimization out
> until after we've got these patches integrated into the c/r tree.

Hmmm.. what about splice_direct_to_actor() ?

> 
> OL> SOCK_DEAD in sk->flags may also pose a problem.  (Do we at all
> OL> need to checkpoint and/or restore SOCK_DEAD ?!)
> 
> Is there any reasonable way we could arrive at a SOCK_DEAD socket via
> a valid descriptor?

That's a good point. I think you are right, and there isn't.

Still need to keep it in mind for inet when including those lingering
sockets that don't belong to anyone.

This also means that a peer (of a dgram socket) that was closed will
not be checkpointed, so restoring the rcvbuf of the remaining dgram
socket wouldn't work.

> 
> OL> Hmm... this test is quite hidden here - maybe a fat comment with a
> OL> reference to why it's here and what it is doing ?
> 
> Sure.
> 
>>> +		else {
>>> +			ckpt_debug("Buffer total %u exceeds limit %u\n",
>>> +			   h->total_bytes, *bufsize);
>>> +			ret = -EINVAL;
>>> +			goto out;
>>> +		}
>>> +	}
>>> +
>>> +	for (i = 0; i < h->skb_count; i++) {
>>> +		ret = sock_read_buffer(ctx, sock);
>>> +		ckpt_debug("read buffer %i: %i\n", i, ret);
>>> +		if (ret < 0)
>>> +			break;
>>> +
>>> +		total += ret;
>>> +		if (total > h->total_bytes) {
> 
> OL> What if 'total' overflows (for CAP_NET_ADMIN) ?   perhaps:
> OL> 		if (total > h->total_bytes || total < ret) {
> 
> Actually, I've changed this locally to require fewer variables and
> special cases.  Let me know when I re-post if you don't think it's a
> better way to handle this.
> 
> OL> Does the following bypass security checks for sys_connect() ?
> 
> I don't think so.  We're basically replicating sys_socketpair() here,
> which does not do a security check, presumably because all you're
> doing is hooking two sockets together that both belong to you.  That's
> not to say that we're as safe as that limited operation, but I don't
> think it's totally clear.  Perhaps someone more confident will
> comment.

Yes, please ... Serge ?

To me it sounds plausible. If we adopt it, then a comment in the
code is worthwhile.

> 
>>> +	/* Prime the socket's buffer limit with the maximum */
>>> +	peer->sk_userlocks |= SOCK_SNDBUF_LOCK;
>>> +	peer->sk_sndbuf = sysctl_wmem_max;
> 
> OL> I suppose this meant to be temporary ?
> 
> Right, it will be overridden when we synchronize the socket
> properties.  I'll strengthen the comment.

Hmm.. then what happens when you have a circular dependency ?
For example, three dgram sockets, A, B and C where: A->B, B->C
and C->A  ('->' means connected).

I suspect that sock_unix_restore_connect() will fail, because
neither:

+	if (!IS_ERR(this) && !IS_ERR(peer)) {

nor

+	} else if ((PTR_ERR(this) == -EINVAL) && (PTR_ERR(peer) == -EINVAL)) {

will hold true, therefore:

+	} else {
+		ckpt_debug("Order Error\n");
+		ret = PTR_ERR(this);
+		goto out;
+	}

Either that, or the temporary change cited above will become
permanent, because A won't be restored again.

> 
> OL> It is indeed a good idea to make it generic for all sockets, but I
> OL> suspect the way sock_read_buffers() works will only be suitable
> OL> for afunix, and perhaps for in-container inet4/6 (by
> OL> "in-container" I mean that both sides of the connection are in the
> OL> checkpoint image).
> 
> Yeah, I meant to put a comment in the commit log about this.  As I
> mentioned before, I was hoping to put most of the effort into the UNIX
> patch and move forward with that as we iterate on the INET patch.
> Thus, this was part of the buffer restore re-swizzle that clearly
> won't work for INET.  In the meantime I've been working on the INET
> patch and splitting it up while retaining the necessary behavioral
> changes made here.  In my next posting these should look better.
> 
> OL> Hmm... does the code below work well with dgram sockets who
> OL> received data from the peer, and then the peer died (before
> OL> checkpoint) ?
> 
> I'm not sure that I've replicated that exact scenario in my tests.
> However, when we're restoring socket A with outstanding incoming
> buffers, we restore them via B.  If B is not in a reasonable state, I
> put it back into connected state to appease the sendmsg function and
> restore it when complete.  See the "unshutdown" comment.

The problem isn't that B is not in a reasonable state, but
rather that B is not checkpointed in the first place (because it
is not reachable via any fd), so it isn't restored either.

Oren.

> 
>>> +static struct file *sock_alloc_attach_fd(struct socket *socket)
> 
> OL> Nit: I think this name is misleading - sock_attach_fd() itself is
> OL> already and should have been sock_attach_file() IMHO - so perhaps
> OL> s/fd/file here ?
> 
> The name was chosen to reflect the fact that we're allocating a socket
> and then calling sock_attach_fd() on it.  If you think it's less
> misleading to be inconsistent with the other call, I'll change it, but
> I wouldn't really agree... :)
> Thanks!
> 
