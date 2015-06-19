From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 19 Jun 2015 16:30:18 -0400
Message-ID: <1434745818.8838.1.camel@primarydata.com>
References: <20150611234929.7b48d314@gandalf.local.home>
	 <CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	 <1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150612113420.5c114183@gandalf.local.home>
	 <20150612115038.44e20ccd@gandalf.local.home>
	 <20150617230819.0a11e47a@grimm.local.home>
	 <CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	 <20150618154914.57424225@gandalf.local.home>
	 <20150618185051.2b2828c3@tlielax.poochiereds.net>
	 <20150618210843.4b09c31c@grimm.local.home>
	 <20150618213702.33f64b20@synchrony.poochiereds.net>
	 <20150619122553.43d2d86c@gandalf.local.home>
	 <20150619131759.7b38d9de@gandalf.local.home>
	 <CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
	 <20150619155226.7c5d6637@synchrony.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bruce James Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150619155226.7c5d6637-08S845evdOaAjSkqwZiSMmfYqLom42DlXqFh9Ls21Oc@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-06-19 at 15:52 -0400, Jeff Layton wrote:
> On Fri, 19 Jun 2015 13:39:08 -0400
> Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:
> 
> > On Fri, Jun 19, 2015 at 1:17 PM, Steven Rostedt <
> > rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > > On Fri, 19 Jun 2015 12:25:53 -0400
> > > Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > > 
> > > 
> > > > I don't see that 55201 anywhere. But then again, I didn't look 
> > > > for it
> > > > before the port disappeared. I could reboot and look for it 
> > > > again. I
> > > > should have saved the full netstat -tapn as well :-/
> > > 
> > > Of course I didn't find it anywhere, that's the port on my wife's 
> > > box
> > > that port 947 was connected to.
> > > 
> > > Now I even went over to my wife's box and ran
> > > 
> > >  # rpcinfo -p localhost
> > >    program vers proto   port  service
> > >     100000    4   tcp    111  portmapper
> > >     100000    3   tcp    111  portmapper
> > >     100000    2   tcp    111  portmapper
> > >     100000    4   udp    111  portmapper
> > >     100000    3   udp    111  portmapper
> > >     100000    2   udp    111  portmapper
> > >     100024    1   udp  34243  status
> > >     100024    1   tcp  34498  status
> > > 
> > > which doesn't show anything.
> > > 
> > > but something is listening to that port...
> > > 
> > >  # netstat -ntap |grep 55201
> > > tcp        0      0 0.0.0.0:55201           0.0.0.0:*            
> > >    LISTEN
> > 
> > 
> > Hang on. This is on the client box while there is an active NFSv4
> > mount? Then that's probably the NFSv4 callback channel listening 
> > for
> > delegation callbacks.
> > 
> > Can you please try:
> > 
> > echo "options nfs callback_tcpport=4048" > /etc/modprobe.d/nfs
> > -local.conf
> > 
> > and then either reboot the client or unload and then reload the nfs
> > modules before reattempting the mount. If this is indeed the 
> > callback
> > channel, then that will move your phantom listener to port 4048...
> > 
> 
> Right, it was a little unclear to me before, but it now seems clear
> that the callback socket that the server is opening to the client is
> the one squatting on the port.
> 
> ...and that sort of makes sense, doesn't it? That rpc_clnt will stick
> around for the life of the client's lease, and the rpc_clnt binds to 
> a
> particular port so that it can reconnect using the same one.
> 
> Given that Stephen has done the legwork and figured out that 
> reverting
> those commits fixes the issue, then I suspect that the real culprit 
> is
> caf4ccd4e88cf2.
> 
> The client is likely closing down the other end of the callback
> socket when it goes idle. Before that commit, we probably did an
> xs_close on it, but now we're doing a xs_tcp_shutdown and that leaves
> the port bound.
> 

Agreed. I've been looking into whether or not there is a simple fix.
Reverting those patches is not an option, because the whole point was
to ensure that the socket is in the TCP_CLOSED state before we release
the socket.

Steven, how about something like the following patch?

8<-----------------------------------------------------------------
>From 9a0bcfdbdbc793eae1ed6d901a6396b6c66f9513 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Date: Fri, 19 Jun 2015 16:17:57 -0400
Subject: [PATCH] SUNRPC: Ensure we release the TCP socket once it has been
 closed

This fixes a regression introduced by commit caf4ccd4e88cf2 ("SUNRPC:
Make xs_tcp_close() do a socket shutdown rather than a sock_release").
Prior to that commit, the autoclose feature would ensure that an
idle connection would result in the socket being both disconnected and
released, whereas now only gets disconnected.

While the current behaviour is harmless, it does leave the port bound
until either RPC traffic resumes or the RPC client is shut down.

Reported-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Signed-off-by: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
---
 net/sunrpc/xprt.c     | 2 +-
 net/sunrpc/xprtsock.c | 8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3ca31f20b97c..ab5dd621ae0c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -611,8 +611,8 @@ static void xprt_autoclose(struct work_struct *work)
 	struct rpc_xprt *xprt =
 		container_of(work, struct rpc_xprt, task_cleanup);
 
-	xprt->ops->close(xprt);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	xprt->ops->close(xprt);
 	xprt_release_write(xprt, NULL);
 }
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fda8ec8c74c0..75dcdadf0269 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -634,10 +634,13 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct socket *sock = transport->sock;
 
-	if (sock != NULL) {
+	if (sock == NULL)
+		return;
+	if (xprt_connected(xprt)) {
 		kernel_sock_shutdown(sock, SHUT_RDWR);
 		trace_rpc_socket_shutdown(xprt, sock);
-	}
+	} else
+		xs_reset_transport(transport);
 }
 
 /**
@@ -786,6 +789,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
 	xs_sock_reset_connection_flags(xprt);
 	/* Mark transport as closed and wake up all pending tasks */
 	xprt_disconnect_done(xprt);
+	xprt_force_disconnect(xprt);
 }
 
 /**
-- 
2.4.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
