From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 08 Jul 2009 12:44:11 -0400
Message-ID: <4A54CCDB.1090602@cs.columbia.edu>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>	<1246994776-1882-2-git-send-email-danms@us.ibm.com>	<4A543D82.5080408@cs.columbia.edu> <87ljmzqjvl.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serrano.cc.columbia.edu ([128.59.29.6]:56875 "EHLO
	serrano.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640AbZGHQo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 12:44:27 -0400
In-Reply-To: <87ljmzqjvl.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> UNIX_PATH_MAX = 108 ...  and then add sizeof(short) ?
> 
> Gah, yeah.  I was just getting lucky before anyway.  I'll move it to
> the per-type header.
> 
> OL> Perhaps a generic char *ckpt_read_string() ?
> 
> Didn't we have one before that was removed?

That was before I changed the ckpt_hdr_... to always include the
ckpt_hdr prefix.

> 
> OL> Is this flag really needed ?  You can reuse sock_unix_need_cwd()
> OL> at restart.
> 
> The idea was to avoid the need to replicate that logic in a non-kernel
> reader so that they know what's coming next without having to know to
> look at the socket path.  However, I can change it.

Oh, I see. That makes sense.

It will do no harm if someone sets the flag but provides an address
of an abstract socket, so no need to ensure that they agree, but
maybe put a comment saying that's it's ok.

> 
> OL> Since this is called after the fields of the socket are restored,
> OL> need to be careful with certain settings. For instance, it will
> OL> fail if the socket is shutdown already; Perhaps on other conditions
> OL> too.
> 
> OL> Also, it has some side-effects:
> 
> OL> First, it modifies sk->sk_wmem_alloc, which is not what you want
> OL> when restoring the receive buffer.
> 
> OL> Second, on the other hand, sk->sk_rmem_alloc isn't restored.
> 
> OL> Third, it sets the sk->sk_destructor to sock_wfree(), of own socket,
> OL> which is not what happens, e.g., usually with af_unix sockets.
> 
> OL> (if I understand the af_unix code correctly, when socket A sends to
> OL> socket B, then A->sk->sk_wmem_alloc is incremented, as well as
> OL> B->sk->sk_rmem_alloc, and when the app reads the data, the kernel
> OL> decreases B->sk->sk_rmem_alloc and finally the callback sock_wfree()
> OL> decreases A->sk->sk_wmem_alloc).
> 
> OL> Forth, you restore the buffer after having restored sk_{snd,rcv}buf.
> OL> So if, for example, the app originally had sk_sndbuf=16K, then sent
> OL> 16K (not read by peer), then set sk_sndbuf=4K -- restore will fail.
> 
> Isn't this rather easily fixed by reading and restoring the buffers
> before doing calling the sync function to restore all the counters and
> limits into the socket?

It will fix the socket shutdown issue. I haven't looked further
to see if there are other pitfalls.

It will mostly fix the buffer limits, but not entirely: if the
original socket first raised the limits above defualt, then sent
data (not read by peer), then you'll still need to adjust the
limit before restoring the buffers.

> 
> OL> Fifth, unix domains sockets never hold actualy data in the sndbuf,
> OL> they only keep track of bytes allocated (sk_wmem_alloc), and the
> OL> data is always placed on the receiver's rcvbuf. If the checkpoint
> OL> image tells another story, report an error.
> 
> Yep, I suppose so, I was just trying to make that bit universal for
> all socket types.

Which is good. Just needs an extra sanity test in the af-unix
specific code.

> 
>>> +	if (len > UNIX_PATH_MAX)
>>> +		return ERR_PTR(ENOSPC);
> 
> OL> -EINVAL ?  The input from checkpoint image is invalid - someone
> OL> must have messed with it.
> 
> Is UNIX_PATH_MAX a declared never-to-change limit?  Could newer
> kernels not have a larger or smaller value?

I can't predict the future, but it's been there forever...

But the point is that I would interpret ENOSPC as "storage/space
is exhausted", while here the error is that this value is simply
invalid for the particular kernel on which the restart occurs.
And it's the error you'll get if you use this value in bind().

>>> +
>>> +	if (h->laddr_len == UNIX_LEN_EMPTY)
>>> +		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->raddr,
>>> +					  h->raddr_len);
>>> +	else if (h->raddr_len == UNIX_LEN_EMPTY)
>>> +		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->laddr,
>>> +					  h->laddr_len);
> 
> OL> If neither conditions holds, @addr will remain uninitialized.
> 
> Oops.  A last-minute change making the "else" an "else if".

I wonder, if you change "else if" to "if", would it require a sanity
check that indeed h->raddr_len == UNIX_LEN_EMPTY ?

> 
>>> +static int sock_unix_restart_connected(struct ckpt_ctx *ctx,
> OL> 			^^^^^^^
> OL> Tiny nit:               restore
> 
> Yep, agreed.
> 
>>> +		write_lock(&current->fs->lock);
>>> +		cur = current->fs->pwd;
>>> +		current->fs->pwd = dir;
>>> +		write_unlock(&current->fs->lock);
>>> +	}
>>> +
> 
> OL> Bizarre, but still: is it possible that at restart time (and also
> OL> at checkpoint time) the pathname will not be accessible ?
> 
> OL> Like: create socket, bind it to some mounted subtree, and then
> OL> force-un-mount the subtree. Of course, the socket will no longer
> OL> be reachable (to connect to) from then on. Now checkpoint. The
> OL> restart will fail - because the bind fails, but unnecessarily so
> OL> :(
> 
> So if the socket path is not accessible you'd rather a fake bind and
> have the application think it's reachable when it's not?

Why would the application think it's reachable ?

In the original system, once the file becomes unreachable it
cannot be made reachable again by simple (re)mounting, IOW it can
no longer be connected-to.

Using a fake-bind in the restarted system achieves the same outcome.

And in both systems, getsockname() will give the right result.

Oren.

> 
> OL> Hmmm... abstract unix sockets have sk->dentry = NULL, so at
> OL> checkpoint time, sock_unix_checkpoint() will not set
> OL> CKPT_UNIX_LINKED for them.  It will end up always doing fake-bind
> OL> :(
> 
> Erm, yeah.
> 
>>> +		ckpt_write_err(ctx, "unsupported UNIX socket state %i",
>>> +			       h->sock.state);
> OL> 		^^^^^^^^^^^^^^
> OL> This can destroy your checkpoint image, if passed as a file (and
> OL> isn't redirected). Good only for checkpoint.
> 
> Eesh, yeah.  Perhaps we can/should make ckpt_write_err() refuse to do
> that if we're coming from a sys_restart()?
> 
> OL> Hopefully some of this will eventually evolve into a set of
> OL> unit tests :p
> 
> I've got a set going already, but clearly not enough.  It's a rather
> complex set of potential scenarios to test, unfortunately.
> 
> Thanks!
> 
