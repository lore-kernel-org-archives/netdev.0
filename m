From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Sun, 24 Jul 2016 20:02:37 +0100
Message-ID: <20160724190237.GP2356@ZenIV.linux.org.uk>
References: <201607240335.u6O3ZE81014171@sdf.org>
 <1659922.nTqITfJpFk@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Curry <rlwinm-WF+c3Tt1nJM@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexmcwhirter-O8/uFoRGvHWcqzYg7KEe8g@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1659922.nTqITfJpFk@debian64>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 24, 2016 at 07:45:13PM +0200, Christian Lamparter wrote:

> > The symptom is that downloaded files (http, ftp, and probably other
> > protocols) have small corrupted segments (about 1-2 kilobytes long) in
> > random locations. Only downloads that sustain a high speed for at least a
> > few seconds are corrupted. Anything small enough to be received in less
> > than about 5 seconds is not affected.

Can that sucker be reproduced with netcat?  That would eliminate all issues
with multi-iovec recvmsg(2), narrowing the things down quite bit.

Another thing (and if that works, it's *NOT* a proper fix - it would be
papering over the problem, but at least it would show where to look for
it) - try (on top of mainline) the following delta:

diff --git a/net/core/datagram.c b/net/core/datagram.c
index b7de71f..0ee5995 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -734,7 +734,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 	if (!chunk)
 		return 0;
 
-	if (msg_data_left(msg) < chunk) {
+	if (iov_iter_single_seg_count(&msg->msg_iter) < chunk) {
 		if (__skb_checksum_complete(skb))
 			goto csum_error;
 		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
