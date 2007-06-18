From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 09:49:32 +0200
Message-ID: <E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu> <20070607.184731.10907840.davem@davemloft.net> <E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu>
Cc: viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759143AbXFRHug@vger.kernel.org>
In-reply-to: <E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Mon, 11 Jun 2007 11:57:27 +0200)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping Dave,

Since there doesn't seem to be any new ideas forthcoming, can we
please decide on either one of my two sumbitted patches?

Thanks,
Miklos

> [CC'd Al Viro and Alan Cox, restored patch]
> 
> > > There are races involving the garbage collector, that can throw away
> > > perfectly good packets with AF_UNIX sockets in them.
> > > 
> > > The problems arise when a socket goes from installed to in-flight or
> > > vice versa during garbage collection.  Since gc is done with a
> > > spinlock held, this only shows up on SMP.
> > > 
> > > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > I'm going to hold off on this one for now.
> > 
> > Holding all of the read locks kind of defeats the purpose of using
> > the per-socket lock.
> > 
> > Can't you just lock purely around the receive queue operation?
> 
> That's already protected by the receive queue spinlock.  The race
> however happens _between_ pushing the root set and marking of the
> in-flight but reachable sockets.
> 
> If in that space any of the AF_UNIX sockets goes from in-flight to
> installed into a file descriptor, the garbage collector can miss it.
> If we want to protect against this using unix_sk(s)->readlock, then we
> have to hold all of them for the duration of the marking.
> 
> Al, Alan, you have more experience with this piece of code.  Do you
> have better ideas about how to fix this?
> 
> Thanks,
> Miklos
> 
> > Index: linux-2.6.22-rc2/net/unix/garbage.c
> > ===================================================================
> > --- linux-2.6.22-rc2.orig/net/unix/garbage.c	2007-06-03 23:58:11.000000000 +0200
> > +++ linux-2.6.22-rc2/net/unix/garbage.c	2007-06-06 09:48:36.000000000 +0200
> > @@ -186,7 +186,21 @@ void unix_gc(void)
> >  
> >  	forall_unix_sockets(i, s)
> >  	{
> > -		unix_sk(s)->gc_tree = GC_ORPHAN;
> > +		struct unix_sock *u = unix_sk(s);
> > +
> > +		u->gc_tree = GC_ORPHAN;
> > +
> > +		/*
> > +		 * Hold ->readlock to protect against sockets going from
> > +		 * in-flight to installed
> > +		 *
> > +		 * Can't sleep on this, because
> > +		 *   a) we are under spinlock
> > +		 *   b) skb_recv_datagram() could be waiting for a packet that
> > +		 *      is to be sent by this thread
> > +		 */
> > +		if (!mutex_trylock(&u->readlock))
> > +			goto lock_failed;
> >  	}
> >  	/*
> >  	 *	Everything is now marked
> > @@ -207,8 +221,6 @@ void unix_gc(void)
> >  
> >  	forall_unix_sockets(i, s)
> >  	{
> > -		int open_count = 0;
> > -
> >  		/*
> >  		 *	If all instances of the descriptor are not
> >  		 *	in flight we are in use.
> > @@ -218,10 +230,20 @@ void unix_gc(void)
> >  		 *	In this case (see unix_create1()) we set artificial
> >  		 *	negative inflight counter to close race window.
> >  		 *	It is trick of course and dirty one.
> > +		 *
> > +		 *	Get the inflight counter first, then the open
> > +		 *	counter.  This avoids problems if racing with
> > +		 *	sendmsg
> > +		 *
> > +		 *	If just created socket is not yet attached to
> > +		 *	a file descriptor, assume open_count of 1
> >  		 */
> > +		int inflight_count = atomic_read(&unix_sk(s)->inflight);
> > +		int open_count = 1;
> > +
> >  		if (s->sk_socket && s->sk_socket->file)
> >  			open_count = file_count(s->sk_socket->file);
> > -		if (open_count > atomic_read(&unix_sk(s)->inflight))
> > +		if (open_count > inflight_count)
> >  			maybe_unmark_and_push(s);
> >  	}
> >  
> > @@ -300,6 +322,7 @@ void unix_gc(void)
> >  			spin_unlock(&s->sk_receive_queue.lock);
> >  		}
> >  		u->gc_tree = GC_ORPHAN;
> > +		mutex_unlock(&u->readlock);
> >  	}
> >  	spin_unlock(&unix_table_lock);
> >  
> > @@ -309,4 +332,19 @@ void unix_gc(void)
> >  
> >  	__skb_queue_purge(&hitlist);
> >  	mutex_unlock(&unix_gc_sem);
> > +	return;
> > +
> > + lock_failed:
> > +	{
> > +		struct sock *s1;
> > +		forall_unix_sockets(i, s1) {
> > +			if (s1 == s) {
> > +				spin_unlock(&unix_table_lock);
> > +				mutex_unlock(&unix_gc_sem);
> > +				return;
> > +			}
> > +			mutex_unlock(&unix_sk(s1)->readlock);
> > +		}
> > +		BUG();
> > +	}
> >  }
> > 
