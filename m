From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: New module infrastructure for net_proto_family
Date: Mon, 28 Apr 2003 14:10:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com>
References: <20030424230202.GB2931@conectiva.com.br>
 <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
 <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <5.1.0.14.2.20030424170208.102ee6c8@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

Hmm, no comments on my last email (http://marc.theaimsgroup.com/?l=linux-netdev&m=105123134301565&w=2) 
Are you trying to ignore me too ? ;-)

Anyway, here is another idea. How about this (untested, uncompiled, just rfc).

--- 1.14/include/linux/net.h    Tue Apr 22 22:48:58 2003
+++ edited/include/linux/net.h  Mon Apr 28 13:59:16 2003
@@ -81,6 +81,7 @@
        struct sock             *sk;
        wait_queue_head_t       wait;
        short                   type;
+       short                   protocol;
        unsigned char           passcred;
 };
 
@@ -132,6 +133,10 @@
 struct net_proto_family {
        int             family;
        int             (*create)(struct socket *sock, int protocol);
+
+       int             (*get)(int protocol);
+       void            (*put)(int protocol);
+
        /* These are counters for the number of different methods of
           each we support */
        short           authentication;
@@ -140,8 +145,8 @@
        struct module   *owner;
 };
 
-extern int          net_family_get(int family);
-extern void         net_family_put(int family);
+extern int          net_family_get(int family, int protocol);
+extern void         net_family_put(int family, int protocol);
 
 struct iovec;

--- 1.53/net/socket.c   Tue Apr 22 23:13:31 2003
+++ edited/net/socket.c Mon Apr 28 13:55:30 2003
@@ -147,27 +147,31 @@
        BUG();
 }
 
-int net_family_get(int family)
+int net_family_get(int family, int protocol)
 {
        struct net_proto_family *prot = net_families[family];
        int rc = 1;
 
        barrier();
-       if (likely(prot != NULL))
+       if (likely(prot != NULL)) {
                rc = try_module_get(prot->owner);
-       else
+               if (!rc && prot->get && (rc = prot->get(protocol)) != 0)
+                       module_put(prot->owner);
+       } else
                net_family_bug(family);
        return rc;
 }
 
-void net_family_put(int family)
+void net_family_put(int family, int protocol)
 {
        struct net_proto_family *prot = net_families[family];
 
        barrier();
-       if (likely(prot != NULL))
+       if (likely(prot != NULL)) {
                module_put(prot->owner);
-       else
+               if (prot->put)
+                       prot->put(protocol);
+       } else
                net_family_bug(family);
 }
 
@@ -539,7 +543,7 @@
 
                sock->ops->release(sock);
                sock->ops = NULL;
-               net_family_put(family);
+               net_family_put(family, sock->protocol);
        }
 
        if (sock->fasync_list)
@@ -1089,10 +1093,11 @@
                goto out;
        }
 
-       sock->type  = type;
+       sock->type     = type;
+       sock->protocol = protocol;
 
        i = -EBUSY;
-       if (!net_family_get(family))
+       if (!net_family_get(family, protocol))
                goto out_release;
 
        if ((i = net_families[family]->create(sock, protocol)) < 0) 
@@ -1910,6 +1915,7 @@
                net_families[ops->family]=ops;
                err = 0;
        }
+
        net_family_write_unlock();
        return err;
 }

-----

So families that handle protos in separate modules would have their own 
family->put/get() methods that net core calls.

I still think that sock->owner is a better (more flexible) solution though.

Max
