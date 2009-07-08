From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 08 Jul 2009 08:23:10 -0700
Message-ID: <87ljmzqjvl.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-2-git-send-email-danms@us.ibm.com>
	<4A543D82.5080408@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A543D82.5080408-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed\, 08 Jul 2009 02\:32\:34 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

OL> UNIX_PATH_MAX = 108 ...  and then add sizeof(short) ?

Gah, yeah.  I was just getting lucky before anyway.  I'll move it to
the per-type header.

OL> Perhaps a generic char *ckpt_read_string() ?

Didn't we have one before that was removed?

OL> Is this flag really needed ?  You can reuse sock_unix_need_cwd()
OL> at restart.

The idea was to avoid the need to replicate that logic in a non-kernel
reader so that they know what's coming next without having to know to
look at the socket path.  However, I can change it.

OL> Since this is called after the fields of the socket are restored,
OL> need to be careful with certain settings. For instance, it will
OL> fail if the socket is shutdown already; Perhaps on other conditions
OL> too.

OL> Also, it has some side-effects:

OL> First, it modifies sk->sk_wmem_alloc, which is not what you want
OL> when restoring the receive buffer.

OL> Second, on the other hand, sk->sk_rmem_alloc isn't restored.

OL> Third, it sets the sk->sk_destructor to sock_wfree(), of own socket,
OL> which is not what happens, e.g., usually with af_unix sockets.

OL> (if I understand the af_unix code correctly, when socket A sends to
OL> socket B, then A->sk->sk_wmem_alloc is incremented, as well as
OL> B->sk->sk_rmem_alloc, and when the app reads the data, the kernel
OL> decreases B->sk->sk_rmem_alloc and finally the callback sock_wfree()
OL> decreases A->sk->sk_wmem_alloc).

OL> Forth, you restore the buffer after having restored sk_{snd,rcv}buf.
OL> So if, for example, the app originally had sk_sndbuf=16K, then sent
OL> 16K (not read by peer), then set sk_sndbuf=4K -- restore will fail.

Isn't this rather easily fixed by reading and restoring the buffers
before doing calling the sync function to restore all the counters and
limits into the socket?

OL> Fifth, unix domains sockets never hold actualy data in the sndbuf,
OL> they only keep track of bytes allocated (sk_wmem_alloc), and the
OL> data is always placed on the receiver's rcvbuf. If the checkpoint
OL> image tells another story, report an error.

Yep, I suppose so, I was just trying to make that bit universal for
all socket types.

>> +	if (len > UNIX_PATH_MAX)
>> +		return ERR_PTR(ENOSPC);

OL> -EINVAL ?  The input from checkpoint image is invalid - someone
OL> must have messed with it.

Is UNIX_PATH_MAX a declared never-to-change limit?  Could newer
kernels not have a larger or smaller value?

>> +
>> +	if (h->laddr_len == UNIX_LEN_EMPTY)
>> +		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->raddr,
>> +					  h->raddr_len);
>> +	else if (h->raddr_len == UNIX_LEN_EMPTY)
>> +		addr = sock_unix_makeaddr((struct sockaddr_un *)&h->laddr,
>> +					  h->laddr_len);

OL> If neither conditions holds, @addr will remain uninitialized.

Oops.  A last-minute change making the "else" an "else if".

>> +static int sock_unix_restart_connected(struct ckpt_ctx *ctx,
OL> 			^^^^^^^
OL> Tiny nit:               restore

Yep, agreed.

>> +		write_lock(&current->fs->lock);
>> +		cur = current->fs->pwd;
>> +		current->fs->pwd = dir;
>> +		write_unlock(&current->fs->lock);
>> +	}
>> +

OL> Bizarre, but still: is it possible that at restart time (and also
OL> at checkpoint time) the pathname will not be accessible ?

OL> Like: create socket, bind it to some mounted subtree, and then
OL> force-un-mount the subtree. Of course, the socket will no longer
OL> be reachable (to connect to) from then on. Now checkpoint. The
OL> restart will fail - because the bind fails, but unnecessarily so
OL> :(

So if the socket path is not accessible you'd rather a fake bind and
have the application think it's reachable when it's not?

OL> Hmmm... abstract unix sockets have sk->dentry = NULL, so at
OL> checkpoint time, sock_unix_checkpoint() will not set
OL> CKPT_UNIX_LINKED for them.  It will end up always doing fake-bind
OL> :(

Erm, yeah.

>> +		ckpt_write_err(ctx, "unsupported UNIX socket state %i",
>> +			       h->sock.state);
OL> 		^^^^^^^^^^^^^^
OL> This can destroy your checkpoint image, if passed as a file (and
OL> isn't redirected). Good only for checkpoint.

Eesh, yeah.  Perhaps we can/should make ckpt_write_err() refuse to do
that if we're coming from a sys_restart()?

OL> Hopefully some of this will eventually evolve into a set of
OL> unit tests :p

I've got a set going already, but clearly not enough.  It's a rather
complex set of potential scenarios to test, unfortunately.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
