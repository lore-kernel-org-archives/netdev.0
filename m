From: jamal <hadi@cyberus.ca>
Subject: PATCH Re: udp weirdness
Date: Mon, 30 Sep 2002 20:22:24 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209302017330.16713-100000@shell.cyberus.ca>
References: <Pine.GSO.4.30.0209300822150.11444-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@sun.com>
In-Reply-To: <Pine.GSO.4.30.0209300822150.11444-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Eric,

you are right about sk->protinfo.af_inet.recverr ..
I checked what other OSes do and i am convinced that the patch below
at least makes us behave like the BSDs.
Alexey/Dave, sk->protinfo.af_inet.recverr is not needed for enobufs to
be propagated back to the socket level; please review and probably
apply:

cheers,
jamal

--- ip_output.c	2002/09/29 08:50:36	1.1
+++ ip_output.c	2002/09/30 06:24:32
@@ -603,8 +603,11 @@
 		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, output_maybe_reroute);
 		if (err) {
-			if (err > 0)
-				err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+			if (err > 0) {
+				err = net_xmit_errno(err);
+				if (!err && sk->protinfo.af_inet.recverr)
+				       err = sk->protinfo.af_inet.recverr;
+			}
 			if (err)
 				goto error;
 		}
@@ -713,8 +716,11 @@

 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      output_maybe_reroute);
-	if (err > 0)
-		err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+	if (err > 0) {
+		err = net_xmit_errno(err);
+		if (!err && sk->protinfo.af_inet.recverr)
+		       	 err = sk->protinfo.af_inet.recverr;
+	}
 	if (err)
 		goto error;
 out:
