From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 3 Mar 2005 13:32:28 -0800
Message-ID: <20050303213228.GU3120@waste.org>
References: <7.454130102@selenic.com> <8.454130102@selenic.com> <20050303130031.066f0862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, jmoyer@redhat.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050303130031.066f0862.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2005 at 01:00:31PM -0800, David S. Miller wrote:
> On Thu, 03 Mar 2005 14:46:32 -0600
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > Packets that have destructors should not be zapped here as that might
> > produce additional printk warnings via netconsole.
> > 
> > Signed-off-by: Matt Mackall <mpm@selenic.com>
> 
> Then where will they be freed, eh? :-)
> 
> This patch adds an SKB leak.  Since you've NULL'd out the list, any
> SKB skipped will never be freed up at all.

Doh. Plain as day. How's this look?

Packets that have destructors should not be zapped here as that might
produce additional printk warnings via netconsole.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: np/net/core/netpoll.c
===================================================================
--- np.orig/net/core/netpoll.c	2005-03-03 14:16:29.579809668 -0600
+++ np/net/core/netpoll.c	2005-03-03 15:26:38.826754614 -0600
@@ -192,7 +192,10 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			__kfree_skb(skb);
+			if(skb->destructor)
+				dev_kfree_skb_any(skb); /* put this one back */
+			else
+				__kfree_skb(skb);
 		}
 	}
 


-- 
Mathematics is the supreme nostalgia of our time.
