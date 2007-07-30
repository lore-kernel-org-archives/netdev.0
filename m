From: pravin <pravin.shelar@gmail.com>
Subject: Re: [PATCH] NET_DMA: remove unused dma_memcpy_to_kernel_iovec
Date: Mon, 30 Jul 2007 20:09:53 +0530
Message-ID: <bab433300707300739s283bf15fp9d00235cf39fa08b@mail.gmail.com>
References: <20070725003606.11018.15141.stgit@localhost.localdomain>
	 <20070726.000607.18303016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, netdev@vger.kernel.org,
	viro@ftp.linux.org.uk, christopher.leech@intel.com,
	andy.grover@gmail.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:11805 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbXG3Ojy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 10:39:54 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1374570wxd
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 07:39:53 -0700 (PDT)
In-Reply-To: <20070726.000607.18303016.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/26/07, David Miller <davem@davemloft.net> wrote:
> From: Shannon Nelson <shannon.nelson@intel.com>
> Date: Tue, 24 Jul 2007 17:36:06 -0700
>
> > (repost - original eaten by vger?)
> >
> > Al Viro pointed out that dma_memcpy_to_kernel_iovec() really was
> > unreachable and thus unused.  The code originally was there to support
> > in-kernel dma needs, but since it remains unused, we'll pull it out.
> >
> > Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
>
> Applied, thanks Shannon.

NET_DMA on kernel buffer is pretty useful in ndb, iSCSI target and
initiators which uses kernel buffer to receive data. Are there any
other issues with dma-memcpy on kernel buffers, if not then following
patch makes dma_memcpy_to_kernel_iovec() reachable from tcp_recvmsg.
I tested this patch and it work fine with unh iSCSI target.


comments?

--pravin.

Index: linux-2.6.23-rc1/net/ipv4/tcp.c
===================================================================
--- linux-2.6.23-rc1.orig/net/ipv4/tcp.c	2007-07-23 02:11:00.000000000 +0530
+++ linux-2.6.23-rc1/net/ipv4/tcp.c	2007-07-30 17:43:51.000000000 +0530
@@ -1115,7 +1115,7 @@
 	int target;		/* Read at least this many bytes */
  	long timeo;
  	struct task_struct *user_recv = NULL;
-	int copied_early = 0;
+	int copied_early = 0, kernel_dma = 0;
  	struct sk_buff *skb;

  	lock_sock(sk);
@@ -1154,6 +1154,9 @@
 		    !sysctl_tcp_low_latency &&
 		    __get_cpu_var(softnet_data).net_dma) {
 			preempt_enable_no_resched();
+			if (segment_eq(get_fs(), KERNEL_DS))
+				kernel_dma = 1;
+			else
  			tp->ucopy.pinned_list =
  					dma_pin_iovec_pages(msg->msg_iov, len);
 		} else {
@@ -1362,7 +1365,7 @@

 		if (!(flags & MSG_TRUNC)) {
  #ifdef CONFIG_NET_DMA
-			if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
+			if (!tp->ucopy.dma_chan  && (kernel_dma || tp->ucopy.pinned_list))
  				tp->ucopy.dma_chan = get_softnet_dma();

  			if (tp->ucopy.dma_chan) {



> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
