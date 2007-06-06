From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Wed, 06 Jun 2007 10:08:29 +0200
Message-ID: <E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
References: <20070605.000247.18308209.davem@davemloft.net>
	<20070605.173120.59467114.davem@davemloft.net>
	<E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu> <20070605.224128.104032917.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2.sa.eol.hu ([212.108.200.109]:57936 "EHLO
	mail-gw2.sa.eol.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbXFFIIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 04:08:49 -0400
In-reply-to: <20070605.224128.104032917.davem@davemloft.net> (message from
	David Miller on Tue, 05 Jun 2007 22:41:28 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > Holding a global mutex over recvmsg() calls under AF_UNIX is pretty
> > > much a non-starter, this will kill performance for multi-threaded
> > > apps.
> > 
> > That's an rwsem held for read.  It's held for write in unix_gc() only
> > for a short duration, and unix_gc() should only rarely be called.  So
> > I don't think there's any performance problem here.
> 
> It pulls a non-local cacheline into the local thread, that's extremely
> expensive on SMP.

OK, here's an updated patch, that uses ->readlock, and passes my
testing.

----
From: Miklos Szeredi <mszeredi@suse.cz>

There are races involving the garbage collector, that can throw away
perfectly good packets with AF_UNIX sockets in them.

The problems arise when a socket goes from installed to in-flight or
vice versa during garbage collection.  Since gc is done with a
spinlock held, this only shows up on SMP.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.22-rc2/net/unix/garbage.c
===================================================================
--- linux-2.6.22-rc2.orig/net/unix/garbage.c	2007-06-03 23:58:11.000000000 +0200
+++ linux-2.6.22-rc2/net/unix/garbage.c	2007-06-06 09:48:36.000000000 +0200
@@ -186,7 +186,21 @@ void unix_gc(void)
 
 	forall_unix_sockets(i, s)
 	{
-		unix_sk(s)->gc_tree = GC_ORPHAN;
+		struct unix_sock *u = unix_sk(s);
+
+		u->gc_tree = GC_ORPHAN;
+
+		/*
+		 * Hold ->readlock to protect against sockets going from
+		 * in-flight to installed
+		 *
+		 * Can't sleep on this, because
+		 *   a) we are under spinlock
+		 *   b) skb_recv_datagram() could be waiting for a packet that
+		 *      is to be sent by this thread
+		 */
+		if (!mutex_trylock(&u->readlock))
+			goto lock_failed;
 	}
 	/*
 	 *	Everything is now marked
@@ -207,8 +221,6 @@ void unix_gc(void)
 
 	forall_unix_sockets(i, s)
 	{
-		int open_count = 0;
-
 		/*
 		 *	If all instances of the descriptor are not
 		 *	in flight we are in use.
@@ -218,10 +230,20 @@ void unix_gc(void)
 		 *	In this case (see unix_create1()) we set artificial
 		 *	negative inflight counter to close race window.
 		 *	It is trick of course and dirty one.
+		 *
+		 *	Get the inflight counter first, then the open
+		 *	counter.  This avoids problems if racing with
+		 *	sendmsg
+		 *
+		 *	If just created socket is not yet attached to
+		 *	a file descriptor, assume open_count of 1
 		 */
+		int inflight_count = atomic_read(&unix_sk(s)->inflight);
+		int open_count = 1;
+
 		if (s->sk_socket && s->sk_socket->file)
 			open_count = file_count(s->sk_socket->file);
-		if (open_count > atomic_read(&unix_sk(s)->inflight))
+		if (open_count > inflight_count)
 			maybe_unmark_and_push(s);
 	}
 
@@ -300,6 +322,7 @@ void unix_gc(void)
 			spin_unlock(&s->sk_receive_queue.lock);
 		}
 		u->gc_tree = GC_ORPHAN;
+		mutex_unlock(&u->readlock);
 	}
 	spin_unlock(&unix_table_lock);
 
@@ -309,4 +332,19 @@ void unix_gc(void)
 
 	__skb_queue_purge(&hitlist);
 	mutex_unlock(&unix_gc_sem);
+	return;
+
+ lock_failed:
+	{
+		struct sock *s1;
+		forall_unix_sockets(i, s1) {
+			if (s1 == s) {
+				spin_unlock(&unix_table_lock);
+				mutex_unlock(&unix_gc_sem);
+				return;
+			}
+			mutex_unlock(&unix_sk(s1)->readlock);
+		}
+		BUG();
+	}
 }

