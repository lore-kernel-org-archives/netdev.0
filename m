From: andrew hendry <andrew.hendry@gmail.com>
Subject: [PATCH] X25: Enable setting of cause and diagnostic fields
Date: Thu, 12 Nov 2009 11:13:27 +1100
Message-ID: <d45a3acc0911111613v38fa9df4jed21876ce6309097@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, linux-x25@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds SIOCX25SCAUSEDIAG, allowing X.25 programs to set the cause and
diagnostic fields.
Normally used to indicate status upon closing connections.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>


diff -uprN -X a/Documentation/dontdiff a/include/linux/x25.h
b/include/linux/x25.h
--- a/include/linux/x25.h	2009-11-11 14:03:26.659663301 +1100
+++ b/include/linux/x25.h	2009-11-11 16:05:06.625958557 +1100
@@ -25,6 +25,7 @@
 #define SIOCX25SENDCALLACCPT    (SIOCPROTOPRIVATE + 9)
 #define SIOCX25GDTEFACILITIES (SIOCPROTOPRIVATE + 10)
 #define SIOCX25SDTEFACILITIES (SIOCPROTOPRIVATE + 11)
+#define SIOCX25SCAUSEDIAG     (SIOCPROTOPRIVATE + 12)

 /*
  *	Values for {get,set}sockopt.
diff -uprN -X a/Documentation/dontdiff a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	2009-11-11 14:02:44.027061001 +1100
+++ b/net/x25/af_x25.c	2009-11-11 16:22:51.374077963 +1100
@@ -1430,6 +1430,17 @@ static int x25_ioctl(struct socket *sock
 			break;
 		}

+		case SIOCX25SCAUSEDIAG: {
+			struct x25_causediag causediag;
+			rc = -EFAULT;
+			if (copy_from_user(&causediag, argp, sizeof(causediag)))
+				break;
+			x25->causediag = causediag;
+			rc = 0;
+			break;
+
+		}
+
 		case SIOCX25SCUDMATCHLEN: {
 			struct x25_subaddr sub_addr;
 			rc = -EINVAL;
diff -uprN -X a/Documentation/dontdiff a/net/x25/x25_subr.c b/net/x25/x25_subr.c
--- a/net/x25/x25_subr.c	2009-11-11 14:02:44.026061128 +1100
+++ b/net/x25/x25_subr.c	2009-11-11 16:28:30.316150252 +1100
@@ -225,6 +225,12 @@ void x25_write_internal(struct sock *sk,
 			break;

 		case X25_CLEAR_REQUEST:
+			dptr    = skb_put(skb, 3);
+			*dptr++ = frametype;
+			*dptr++ = x25->causediag.cause;
+			*dptr++ = x25->causediag.diagnostic;
+			break;
+
 		case X25_RESET_REQUEST:
 			dptr    = skb_put(skb, 3);
 			*dptr++ = frametype;
