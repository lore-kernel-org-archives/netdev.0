From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Wed, 9 Feb 2005 10:59:09 -0800
Message-ID: <20050209105909.17da40a9@dxpl.pdx.osdl.net>
References: <050QTJA12@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Alexey Kuznetsov
 <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
To: Hubert Tonneau <hubert.tonneau@fullpliant.org>
In-Reply-To: <050QTJA12@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please try this patch, based on Alexey's suggestion:

> That's one quick and simple idea: set PSH on each tso segment.
> Seems, it is always good. Hardware will preserve it only on the last skb and
> everyone will be happy.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/09 11:00:57-08:00 shemminger@linux.site 
#   Always set PUSH on TSO multi-segment frames
#   to workaround bugs in MacOSX
# 
# net/ipv4/tcp_output.c
#   2005/02/09 11:00:44-08:00 shemminger@linux.site +8 -0
#   Always set PUSH on TSO multi-segment frames
#   to workaround bugs in MacOSX
# 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2005-02-09 11:01:12 -08:00
+++ b/net/ipv4/tcp_output.c	2005-02-09 11:01:12 -08:00
@@ -754,6 +754,14 @@
 					break;
 			}
 
+			/* Force push to be on for any large TSO frames
+			 * to workaround problems with busted implementations
+			 * like MacOSX that hold off delivery of data until
+			 * push.
+			 */
+			if (tcp_skb_pcount(skb) > 1)
+			    TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
+
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
 			if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
 				break;
