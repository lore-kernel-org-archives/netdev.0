From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] SUNRPC: Remove resource leak in svc_rdma_send_error()
Date: Sat, 22 Jan 2011 22:40:20 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101222233260.7746@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Tejun Heo <tj@kernel.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	"David S. Miller" <davem@davemloft.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We leak the memory allocated to 'ctxt' when we return after 
'ib_dma_mapping_error()' returns !=0.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 svc_rdma_transport.c |    1 +
 1 file changed, 1 insertion(+)

  compile tested only

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 9df1ead..1a10dcd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1335,6 +1335,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 					    p, 0, length, DMA_FROM_DEVICE);
 	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
 		put_page(p);
+		svc_rdma_put_context(ctxt, 1);
 		return;
 	}
 	atomic_inc(&xprt->sc_dma_used);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
