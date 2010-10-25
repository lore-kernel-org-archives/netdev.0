From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
 (net-current tree related)
Date: Mon, 25 Oct 2010 14:19:56 +1100
Message-ID: <20101025141956.d8f0888f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	stephen hemminger <shemminger@vyatta.com>,
	James Chapman <jchapman@katalix.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/l2tp/l2tp_core.c:1228: error: __ksymtab_l2tp_tunnel_closeall causes a section type conflict
net/l2tp/l2tp_core.c:1228: error: __ksymtab_l2tp_tunnel_closeall causes a section type conflict
net/l2tp/l2tp_core.c:1006: error: __ksymtab_l2tp_xmit_core causes a section type conflict
net/l2tp/l2tp_core.c:1006: error: __ksymtab_l2tp_xmit_core causes a section type conflict
net/l2tp/l2tp_core.c:847: error: __ksymtab_l2tp_udp_recv_core causes a section type conflict
net/l2tp/l2tp_core.c:847: error: __ksymtab_l2tp_udp_recv_core causes a section type conflict

Caused by commit fc130840d75d42c5a360fd1d8b72489eec09cad3 ("l2tp: make
local function static") since these functions are now static (and should
not be exported).  I wish doing that caused a build failure on other
architectures ...

I applied the following patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 25 Oct 2010 14:16:53 +1100
Subject: [PATCH] l2tp: static functions should not be exported

Causes these build failures on PowerPC:

net/l2tp/l2tp_core.c:1228: error: __ksymtab_l2tp_tunnel_closeall causes a section type conflict
net/l2tp/l2tp_core.c:1228: error: __ksymtab_l2tp_tunnel_closeall causes a section type conflict
net/l2tp/l2tp_core.c:1006: error: __ksymtab_l2tp_xmit_core causes a section type conflict
net/l2tp/l2tp_core.c:1006: error: __ksymtab_l2tp_xmit_core causes a section type conflict
net/l2tp/l2tp_core.c:847: error: __ksymtab_l2tp_udp_recv_core causes a section type conflict
net/l2tp/l2tp_core.c:847: error: __ksymtab_l2tp_udp_recv_core causes a section type conflict

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/l2tp/l2tp_core.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 5fb4803..c64ce0a 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -844,7 +844,6 @@ error:
 
 	return 1;
 }
-EXPORT_SYMBOL_GPL(l2tp_udp_recv_core);
 
 /* UDP encapsulation receive handler. See net/ipv4/udp.c.
  * Return codes:
@@ -1003,7 +1002,6 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(l2tp_xmit_core);
 
 /* Automatically called when the skb is freed.
  */
@@ -1225,7 +1223,6 @@ again:
 	}
 	write_unlock_bh(&tunnel->hlist_lock);
 }
-EXPORT_SYMBOL_GPL(l2tp_tunnel_closeall);
 
 /* Really kill the tunnel.
  * Come here only when all sessions have been cleared from the tunnel.
-- 
1.7.2.3

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
