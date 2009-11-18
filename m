From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH] X25: Enable setting of cause and diagnostic fields
Date: Thu, 19 Nov 2009 10:24:01 +1100
Message-ID: <d45a3acc0911181524t58a87d07s42930bda765a97d7@mail.gmail.com>
References: <d45a3acc0911111613v38fa9df4jed21876ce6309097@mail.gmail.com>
	 <20091113.203248.84989794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-x25@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-x25-owner@vger.kernel.org>
In-Reply-To: <20091113.203248.84989794.davem@davemloft.net>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, will make sure to check 32/64 in the future.

Adds SIOCX25SCAUSEDIAG, allowing X.25 programs to set the cause and
diagnostic fields.
Normally used to indicate status upon closing connections.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

diff -uprN -X a/Documentation/dontdiff a/include/linux/x25.h
b/include/linux/x25.h
--- a/include/linux/x25.h	2009-11-16 13:44:41.138892908 +1100
+++ b/include/linux/x25.h	2009-11-11 16:05:06.625958557 +1100
@@ -25,6 +25,7 @@
 #define SIOCX25SENDCALLACCPT    (SIOCPROTOPRIVATE + 9)
 #define SIOCX25GDTEFACILITIES (SIOCPROTOPRIVATE + 10)
 #define SIOCX25SDTEFACILITIES (SIOCPROTOPRIVATE + 11)
+#define SIOCX25SCAUSEDIAG	(SIOCPROTOPRIVATE + 12)

 /*
  *	Values for {get,set}sockopt.
diff -uprN -X a/Documentation/dontdiff a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	2009-11-16 13:44:41.745816123 +1100
+++ b/net/x25/af_x25.c	2009-11-16 13:49:51.277655328 +1100
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
@@ -1587,6 +1598,7 @@ static int compat_x25_ioctl(struct socke
 	case SIOCX25GCALLUSERDATA:
 	case SIOCX25SCALLUSERDATA:
 	case SIOCX25GCAUSEDIAG:
+	case SIOCX25SCAUSEDIAG:
 	case SIOCX25SCUDMATCHLEN:
 	case SIOCX25CALLACCPTAPPRV:
 	case SIOCX25SENDCALLACCPT:
diff -uprN -X a/Documentation/dontdiff a/net/x25/x25_subr.c b/net/x25/x25_subr.c
--- a/net/x25/x25_subr.c	2009-11-16 13:44:42.337741236 +1100
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


On Sat, Nov 14, 2009 at 3:32 PM, David Miller <davem@davemloft.net> wrote:
> From: andrew hendry <andrew.hendry@gmail.com>
> Date: Thu, 12 Nov 2009 11:13:27 +1100
>
>> Adds SIOCX25SCAUSEDIAG, allowing X.25 programs to set the cause and
>> diagnostic fields.
>> Normally used to indicate status upon closing connections.
>>
>> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>
>
> This change is incomplete.
>
> You need to add handling to compat_x25_ioctl().
>
