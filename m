From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 05 Jun 2007 09:42:41 +0200
Message-ID: <E1HvTgf-0000sb-00@dorka.pomaz.szeredi.hu>
References: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu>
	<E1Hv980-0006gQ-00@dorka.pomaz.szeredi.hu> <20070605.000247.18308209.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761237AbXFEHnN@vger.kernel.org>
In-reply-to: <20070605.000247.18308209.davem@davemloft.net> (message from
	David Miller on Tue, 05 Jun 2007 00:02:47 -0700 (PDT))
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
> > > send()+close() on the peer, causing recv() to return zero, even though
> > > the sent data should be received.
> > > 
> > > This happens if the send() and the close() is performed between
> > > skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():
> > > 
> > > process A  skb_dequeue() returns NULL, there's no data in the socket queue
> > > process B  new data is inserted onto the queue by unix_stream_sendmsg()
> > > process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
> > > process A  sk->sk_shutdown is checked, unix_release_sock() returns zero
> > 
> > This is only part of the story.  It turns out, there are other races
> > involving the garbage collector, that can throw away perfectly good
> > packets with AF_UNIX sockets in them.
> > 
> > The problems arise when a socket goes from installed to in-flight or
> > vica versa during garbage collection.  Since gc is done with a
> > spinlock held, this only shows up on SMP.
> > 
> > The following patch fixes it for me, but it's possibly the wrong
> > approach.
> > 
> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> 
> I haven't seen a repost of the first patch, which is necessary because
> that first patch doesn't apply to the current tree.  Please don't
> ignore Arnaldo's feedback like that, or else I'll ignore you just the
> same. :-)

I just want to win the "who's laziest?" league.  It would take me
about 5 minutes to get the netdev tree and test compile the change.
Of which 5 seconds would be actually updating the patch.  I was
thought it was OK to pass that 5 seconds worth of hard work to you in
order to save the rest ;)

Anyway here's the updated (but not compile tested) patch.

Thanks,
Miklos

From: Miklos Szeredi <mszeredi@suse.cz>

A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
send()+close() on the peer, causing recv() to return zero, even though
the sent data should be received.

This happens if the send() and the close() is performed between
skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():

process A  skb_dequeue() returns NULL, there's no data in the socket queue
process B  new data is inserted onto the queue by unix_stream_sendmsg()
process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
process A  sk->sk_shutdown is checked, unix_release_sock() returns zero

I'm surprised nobody noticed this, it's not hard to trigger.  Maybe
it's just (un)luck with the timing.

It's possible to work around this bug in userspace, by retrying the
recv() once in case of a zero return value.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.22-rc2/net/unix/af_unix.c
===================================================================
--- linux-2.6.22-rc2.orig/net/unix/af_unix.c	2007-06-02 23:45:47.000000000 +0200
+++ linux-2.6.22-rc2/net/unix/af_unix.c	2007-06-02 23:45:49.000000000 +0200
@@ -1711,20 +1711,23 @@ static int unix_stream_recvmsg(struct ki
 		int chunk;
 		struct sk_buff *skb;
 
+		unix_state_lock(sk);
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (skb==NULL)
 		{
 			if (copied >= target)
-				break;
+				goto unlock;
 
 			/*
 			 *	POSIX 1003.1g mandates this order.
 			 */
 
 			if ((err = sock_error(sk)) != 0)
-				break;
+				goto unlock;
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
-				break;
+				goto unlock;
+
+			unix_state_unlock(sk);
 			err = -EAGAIN;
 			if (!timeo)
 				break;
@@ -1738,7 +1741,11 @@ static int unix_stream_recvmsg(struct ki
 			}
 			mutex_lock(&u->readlock);
 			continue;
+ unlock:
+			unix_state_unlock(sk);
+			break;
 		}
+		unix_state_unlock(sk);
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
