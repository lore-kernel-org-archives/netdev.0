From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: BUG at net/sctp/socket.c:7425
Date: Sun, 29 Jan 2017 08:40:02 -0200
Message-ID: <20170129104002.GJ3781@localhost.localdomain>
References: <48766e1c-99c9-3a88-0fec-998bf4db9a3a@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Alexander Popov <alex.popov@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48766e1c-99c9-3a88-0fec-998bf4db9a3a@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 29, 2017 at 03:35:31AM +0300, Alexander Popov wrote:
> Hello,
> 
> I'm running the syzkaller fuzzer for v4.10-rc4 (0aa0313f9d576affd7747cc3f179feb097d28990)
> and have such a crash in sctp code:
> 
...
> 
> Unfortunately, I didn't manage to get a C program reproducing the crash (looks like race).
> However, I stably hit it on my setup - so I can help fixing the issue.
> 
> The crash happens here:
> 	/* Let another process have a go.  Since we are going
> 	 * to sleep anyway.
> 	 */
> 	release_sock(sk);
> 	current_timeo = schedule_timeout(current_timeo);
> >	BUG_ON(sk != asoc->base.sk);
> 	lock_sock(sk);
> 
> I've added some debugging output and see, that the original value of asoc->base.sk is
> changed to the address of another struct sock, which appeared in sctp_endpoint_init()
> shortly before the crash.

You need some threading for this to happen.  asoc->base.sk will change
if you peeloff the association.
It seems you had one thread waiting for some sndbuf to be available on a
sendmsg() call and another thread did a peeloff on the association that
the first thread was using.
Yeah I think this will reproduce it.
And in this case, it's probably better if we just return -EPIPE as the
association doesn't exist in that socket anymore instead of the BUG_ON.

  Marcelo

---8<---

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 26a514269b92..e9870aead88b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6838,7 +6838,8 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
 		 */
 		sctp_release_sock(sk);
 		current_timeo = schedule_timeout(current_timeo);
-		BUG_ON(sk != asoc->base.sk);
+		if (sk != asoc->base.sk)
+			goto do_error;
 		sctp_lock_sock(sk);
 
 		*timeo_p = current_timeo;
