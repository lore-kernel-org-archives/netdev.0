From: "David S. Miller" <davem@redhat.com>
Subject: Possible IRDA SKB leaks
Date: Mon, 24 Nov 2003 19:30:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124193042.2c1013a2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello Jean, I think I've found some SKB handling bugs in
the IRDA stack.

I was verifying all the paths that use sock_queue_rcv_skb().
If any non-zero value is returned from this function the caller
must either free the SKB or queue the packet some place else.

Here is one example where IRDA appears to do the wrong thing.
In irttp_udata_indication(), we pass the packet down into the
next layer via self->notify.udata_indication().

One example implementation of this is af_irda.c:irda_data_indication().
This calls sock_queue_rcv_skb() and returns any error to the caller.

Our caller in this case, irttp_udata_indication(), for some reason
treats -ENOMEM specially.  This is wrong, there are many other errors
that sock_queue_rcv_skb() can return, for example -EPERM from socket
filtering.  All such error cases need to cause the SKB to be freed
or similar, it should not be done only for an error of -ENOMEM.

I have not done an exhaustive audit of this problem in the IRDA stack.
But I do suspect there are other places doing something similar.

If someone could finish the audit and submit a patch to fix this I'd
really appreciate it.  Thanks a lot.
