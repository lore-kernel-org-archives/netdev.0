From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Reproducible panics with tulip
Date: Fri, 18 Mar 2005 23:39:39 +0100
Message-ID: <20050318223939.GB24509@electric-eye.fr.zoreil.com>
References: <1111178167.1147.9.camel@localhost.localdomain> <20050318215229.GA24509@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Alexander Nyberg <alexn@dsv.su.se>
Content-Disposition: inline
In-Reply-To: <20050318215229.GA24509@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
> Alexander Nyberg <alexn@dsv.su.se> :
> [...]
> > Warning: kfree_skb on hard IRQ c46c3950
> 
> ... however this one may stick.

/me slaps his head

Nope, it should go away with netconsole: tulip_rx fails an allocation,
netconsole tries to printk in IRQ context and issues:
-> netpoll_send_udp
   -> find_skb
     -> zap_completion_queue
        -> __kfree_skb <- whence the warning.

So, please increase /proc/sys/vm/min_free_kbytes as a start and, at your
option:
- disable netconsole
- apply patch below:


zap_completion_queue can be called in any context through netpoll_send_udp.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN net/core/netpoll.c~netconsole-000 net/core/netpoll.c
--- a/net/core/netpoll.c~netconsole-000	2005-03-18 23:29:28.499641348 +0100
+++ b/net/core/netpoll.c	2005-03-18 23:33:13.856959994 +0100
@@ -142,7 +142,7 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			__kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 		}
 	}
 

_
