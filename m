From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Fri, 07 Nov 2014 16:52:15 -0500 (EST)
Message-ID: <20141107.165215.276097769670227324.davem@redhat.com>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
	<20141105.165719.835728206041332333.davem@davemloft.net>
	<20141106032533.GU7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106032533.GU7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 6 Nov 2014 03:25:34 +0000

> 	* a new helper: zerocopy_sg_from_iter().  I have it, actually,
> but I'd rather not step on Herbert's toes - it's too close to the areas
> his series will touch, so that's probably for when his series goes in.
> It will be needed for complete macvtap conversion...

Just a heads up, his series is applied to net-next.

> 	* why doesn't verify_iovec() use rw_copy_check_uvector()?  The only
> real differences I see is that (a) you do allocation in callers (same as
> rw_copy_check_uvector() would've done), (b) you return EMSGSIZE in case of
> too long vector, while rw_copy_check_uvector() returns EINVAL in that case
> and (c) you don't do access_ok().  The last one is described as optimization,
> but for iov_iter primitives it's a serious PITA - for iovec-backed instances
> they are using __copy_from_user()/__copy_to_user(), etc.

The answer is that nobody knew abuot it and looked, that's why.

> 	It certainly would be nice to have the same code doing all copying
> of iovecs from userland - readv/writev/aio/sendmsg/recvmsg/etc.  Am I
> missing something subtle semantical difference in there?  EMSGSIZE vs EINVAL
> is trivial (we can lift that check into the callers, if nothing else), but
> I could miss something more interesting...

We also need compat counterparts.

> 	* various getfrag will need to grow iov_iter-based counterparts,
> but ip_append_output() needs no changes, AFAICS.

Right.

> 	* there's some really weird stuff in there.  Just what is this
> static int raw_probe_proto_opt(struct flowi4 *fl4, struct msghdr *msg)
> {
>         struct iovec *iov;
>         u8 __user *type = NULL;
>         u8 __user *code = NULL;
>         int probed = 0;
>         unsigned int i;
> 
>         if (!msg->msg_iov)
>                 return 0;
> 
>         for (i = 0; i < msg->msg_iovlen; i++) {
>                 iov = &msg->msg_iov[i];
>                 if (!iov)
>                         continue;
> trying to do?  "If non-NULL pointer + i somehow happened to be NULL, skip it
> and try to use the same pointer + i + 1"?  Huh?  Had been that way since
> the function first went in back in 2004 ("[IPV4] XFRM: probe icmp type/code
> when sending packets via raw socket.", according to historical tree)...

This is probably just bogus, because this address-of will never evaluate to
NULL.

> 	* rds, bluetooth and vsock are doing something odd; need to RTFS some
> more.

It is not surprising.... :-/
