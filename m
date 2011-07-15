From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 09/10] nfs: use sk fragment destructors to delay I/O
 completion until page is released by network stack.
Date: Fri, 15 Jul 2011 10:01:29 -0400
Message-ID: <1310738489.4381.20.camel@lade.trondhjem.org>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
	 <1310728031-19569-9-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310728031-19569-9-git-send-email-ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-15 at 12:07 +0100, Ian Campbell wrote: 
> Thos prevents an issue where an ACK is delayed, a retransmit is queued (either
> at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> wire. If this happens then the write() system call and the userspace process
> can continue potentially modifying the data before the retransmission occurs.
> 
> NB: this only covers the O_DIRECT write() case. I expect other cases to need
> handling as well.

That is why this belongs entirely in the RPC layer, and really should
not touch the NFS layer.
If you move your callback to the RPC layer and have it notify the
rpc_task when the pages have been sent, then it should be possible to
achieve the same thing.

IOW: Add an extra state machine step after call_decode() which checks if
all the page data has been transmitted and if not, puts the rpc_task on
a wait queue, and has it wait for the fragment destructor callback
before calling rpc_exit_task().

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
