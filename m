From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Mon, 09 Feb 2015 20:52:09 -0800 (PST)
Message-ID: <20150209.205209.1524645061817000265.davem@davemloft.net>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 9 Feb 2015 20:37:13 -0800

> It's a NULL pointer derefernce (at offset 0x18) where the callchain
> looks like this:
> 
>   RIP: skcipher_recvmsg+0x360/0x410
>   Call Trace:
>      sock_read_iter+0xd0/0x120
>      new_sync_read+0x79/0xb0
>      __vfs_read+0x13/0x50
>      SyS_read+0x41/0x0b0
>      system_call_fastpath
> 
> which I assume is related to the iov_iter conversion.
> 
> That oops then is followed immediately by another that is a NULL
> pointer dereference in skcipher_sock_destruct, but the callchain for
> that is just the exit as part of killing of the original oops, so that
> second oops seems to be just a result of the first one.
> 
> I'm assuming the culrpit is 1d10eb2f156f ("crypto: switch
> af_alg_make_sg() to iov_iter") but haven't tested.

I think the handling of the 'used' local variable for function
skcipher_recvmsg() in that commit is suspect.

The problem is that if we go to the skcipher_wait_for_data() code
path, ctx->used is updated.

But the way skcipher_recvmsg() is was changed, that update won't
propagate into the caller because the old ctx->used value is cached in
the local 'used' variable.

The fix could be as simple as:

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 37110fd..4d1c315 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -444,6 +444,7 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
 			err = skcipher_wait_for_data(sk, flags);
 			if (err)
 				goto unlock;
+			used = ctx->used;
 		}
 
 		used = min_t(unsigned long, used, iov_iter_count(&msg->msg_iter));
