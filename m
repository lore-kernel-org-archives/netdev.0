From: Krishna Kumar <kkumar@us.ibm.com>
Subject: [PATCH AND RFC_PATCH] 1. Leak corking option in ipv4 2. ipv6 opt
 panic
Date: Tue, 9 Mar 2004 18:05:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403091754440.6308-100000@linux-009047018241>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Patch1 :
--------
I think every socket can leak memory when it allocates a cork.opt and
calls ip_append_data()/ip_push_pending_frames(). This get released in
ip_flush_pending_frames() which may not get called.


Patch2 :
---------
I am not sure about this possible bug which is the RFC part of the
subject. In IPv6 ip6_append_data(), if it is possible to add extra ipv6
options during multiple calls to append_data(), then the check for
cork.opt could end up panicing the system because it is allocated
for a smaller size of options. If this is a problem, then ipv4 might have
a similar issue too. Note: Patch2 has a question embedded in it, I can
send a better patch if you think the idea is right.

Both patches are over my previous patch.

PS : Both these patches are not as a result of any problem I got while
testing.

Thanks,

- KK

Patch1 :
--------
diff -ruN linux-2.6.4-rc2-bk5.org/net/ipv4/ip_output.c linux-2.6.4-rc2-bk5/net/ipv4/ip_output.c
--- linux-2.6.4-rc2-bk5.org/net/ipv4/ip_output.c	2004-03-09 13:36:43.000000000 -0800
+++ linux-2.6.4-rc2-bk5/net/ipv4/ip_output.c	2004-03-09 16:43:41.000000000 -0800
@@ -1187,6 +1187,10 @@

 out:
 	inet->cork.flags &= ~IPCORK_OPT;
+	if (inet->cork.opt) {
+		kfree(inet->cork.opt);
+		inet->cork.opt = NULL;
+	}
 	if (inet->cork.rt) {
 		ip_rt_put(inet->cork.rt);
 		inet->cork.rt = NULL;


Patch2 :
--------
diff -ruN linux-2.6.4-rc2-bk5.org/net/ipv6/ip6_output.c linux-2.6.4-rc2-bk5/net/ipv6/ip6_output.c
--- linux-2.6.4-rc2-bk5.org/net/ipv6/ip6_output.c	2004-03-09 13:36:43.000000000 -0800
+++ linux-2.6.4-rc2-bk5/net/ipv6/ip6_output.c	2004-03-09 16:53:52.000000000 -0800
@@ -816,7 +816,16 @@
 		 * setup for corking
 		 */
 		if (opt) {
-			if (np->cork.opt == NULL) {
+			if (np->cork.opt == NULL || np->cork.opt->tot_len <
+						opt->tot_len) {
+				/* No options or option size increased */
+				if (np->cork.opt) {
+					/* Should existing data be sent with
+					 * old options first ?
+					 */
+					ip6_push_pending_frames(sk);
+					kfree(np->cork.opt);
+				}
 				np->cork.opt = kmalloc(opt->tot_len,
 						       sk->sk_allocation);
 				if (unlikely(np->cork.opt == NULL))
