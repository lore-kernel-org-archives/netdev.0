From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69] IPV4 should use dev_hold
Date: Tue, 6 May 2003 15:32:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506153234.4907001f.shemminger@osdl.org>
References: <20030505130050.4b9868bb.shemminger@osdl.org>
	<20030506075808.388332C07F@lists.samba.org>
	<20030506.072338.39479306.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030506.072338.39479306.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

While debugging possible changes to dev refcounting, discovered
a couple of places in IPV4 that were directly incrementing rather
than using the inline dev_hold.  Let's hide the implementation of
net device ref counting so  future module ref count fixes will be easier.

diff -urN -X dontdiff linux-2.5/net/ipv4/fib_frontend.c linux-2.5-dev/net/ipv4/fib_frontend.c
--- linux-2.5/net/ipv4/fib_frontend.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-dev/net/ipv4/fib_frontend.c	2003-05-06 15:16:03.000000000 -0700
@@ -115,9 +115,9 @@
 	if (res.type != RTN_LOCAL)
 		goto out;
 	dev = FIB_RES_DEV(res);
-	if (dev)
-		atomic_inc(&dev->refcnt);
 
+	if (dev)
+		dev_hold(dev);
 out:
 	fib_res_put(&res);
 	return dev;
diff -urN -X dontdiff linux-2.5/net/ipv4/fib_semantics.c linux-2.5-dev/net/ipv4/fib_semantics.c
--- linux-2.5/net/ipv4/fib_semantics.c	2003-04-29 09:57:41.000000000 -0700
+++ linux-2.5-dev/net/ipv4/fib_semantics.c	2003-05-06 15:10:40.000000000 -0700
@@ -406,7 +406,7 @@
 			if (!(dev->flags&IFF_UP))
 				return -ENETDOWN;
 			nh->nh_dev = dev;
-			atomic_inc(&dev->refcnt);
+			dev_hold(dev);
 			nh->nh_scope = RT_SCOPE_LINK;
 			return 0;
 		}
@@ -429,7 +429,7 @@
 		nh->nh_oif = FIB_RES_OIF(res);
 		if ((nh->nh_dev = FIB_RES_DEV(res)) == NULL)
 			goto out;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(nh->nh_dev);
 		err = -ENETDOWN;
 		if (!(nh->nh_dev->flags & IFF_UP))
 			goto out;
@@ -451,7 +451,7 @@
 			return -ENETDOWN;
 		}
 		nh->nh_dev = in_dev->dev;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
 		in_dev_put(in_dev);
 	}
