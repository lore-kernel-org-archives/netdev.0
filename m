From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] fix dst_entry leak in icmp_push_reply()
Date: Thu, 18 Aug 2005 20:59:37 +0200
Message-ID: <4304DA99.2080205__10361.3746505745$1124391753$gmane$org@trash.net>
References: <43039C3F.2000207@rincewind.tv> <4303CEC5.3010502@trash.net> <43042D94.4030303@rincewind.tv> <4304D763.4090001@rincewind.tv>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020505050000070804030301"
Cc: linux-kernel@vger.kernel.org, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ollie Wild <aaw@rincewind.tv>
In-Reply-To: <4304D763.4090001@rincewind.tv>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020505050000070804030301
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Ollie Wild wrote:
> That said, I appreciate that the if-else condition doesn't seem quite
> right.  The problem is, the icmp_push_reply() routine is implicitly
> using the queue as a success indicator.  I put the
> ip_flush_pending_frames() call inside the else block because I wanted to
> guarantee that one of ip_push_pending_frames() and
> ip_flush_pending_frames() is always called.  Both will do proper cleanup.
> 
> I'm open to suggestions if you think there's a cleaner way to implement
> this.

Checking the return value of ip_append_data seems cleaner to me.
Patch attached.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------020505050000070804030301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -349,12 +349,12 @@ static void icmp_push_reply(struct icmp_
 {
 	struct sk_buff *skb;
 
-	ip_append_data(icmp_socket->sk, icmp_glue_bits, icmp_param,
-		       icmp_param->data_len+icmp_param->head_len,
-		       icmp_param->head_len,
-		       ipc, rt, MSG_DONTWAIT);
-
-	if ((skb = skb_peek(&icmp_socket->sk->sk_write_queue)) != NULL) {
+	if (ip_append_data(icmp_socket->sk, icmp_glue_bits, icmp_param,
+		           icmp_param->data_len+icmp_param->head_len,
+		           icmp_param->head_len,
+		           ipc, rt, MSG_DONTWAIT) < 0)
+		ip_flush_pending_frames(icmp_socket->sk);
+	else if ((skb = skb_peek(&icmp_socket->sk->sk_write_queue)) != NULL) {
 		struct icmphdr *icmph = skb->h.icmph;
 		unsigned int csum = 0;
 		struct sk_buff *skb1;

--------------020505050000070804030301--
