From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]  tcp_ack_update_window window scaling bug
Date: Tue, 28 Oct 2003 08:35:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028083523.383f4b85.davem@redhat.com>
References: <20031028161759.14346.qmail@patheticgeek.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Kevin Lahey" <kml@patheticgeek.net>
In-Reply-To: <20031028161759.14346.qmail@patheticgeek.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Oct 2003 08:17:59 -0800
"Kevin Lahey" <kml@patheticgeek.net> wrote:

> It appears that tcp_ack_update_window is window scaling the offered
> TCP receiver window even on the SYN packet.  As noted in no less
> than two other places in the networking code, RFC 1323 insists that
> initial window advertisements are unscaled.

Good spotting Kevin, thanks a lot.

I changed your patch slightly so that there is only one
expansion of ntohs().  Longer term we should make all
the include/linux/byteorder/swab.h routines inline functions
instead of macros and then mark them with __attribute__((pure)).

Thanks again Kevin.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1377  -> 1.1378 
#	net/ipv4/tcp_input.c	1.46    -> 1.47   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/28	kml@patheticgeek.net	1.1378
# [TCP]: When SYN is set, the window is not scaled.
# --------------------------------------------
#
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Tue Oct 28 08:38:22 2003
+++ b/net/ipv4/tcp_input.c	Tue Oct 28 08:38:22 2003
@@ -1967,7 +1967,10 @@
 				 struct sk_buff *skb, u32 ack, u32 ack_seq)
 {
 	int flag = 0;
-	u32 nwin = ntohs(skb->h.th->window) << tp->snd_wscale;
+	u32 nwin = ntohs(skb->h.th->window);
+
+	if (likely(!skb->h.th->syn))
+		nwin <<= tp->snd_wscale;
 
 	if (tcp_may_update_window(tp, ack, ack_seq, nwin)) {
 		flag |= FLAG_WIN_UPDATE;
