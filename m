From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Some pktgen fixes for 2.6.11-rc2
Date: Fri, 28 Jan 2005 21:31:17 +0100
Message-ID: <16890.41237.608094.933695@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, Jens.Laas@data.slu.se, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hello!

Some fixes pointed out by Grant Grundler and Jens L=E5=E5s but
Grant still see problems.
					 --ro



--- net/core/pktgen.c.foo	2005-01-28 13:16:50.965630000 +0100
+++ net/core/pktgen.c	2005-01-28 16:51:32.932273576 +0100
@@ -148,7 +148,7 @@
 #include <asm/timex.h>
=20
=20
-#define VERSION  "pktgen v2.54: Packet Generator for packet performance =
testing.\n"
+#define VERSION  "pktgen v2.56: Packet Generator for packet performance =
testing.\n"
=20
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a)=20
@@ -167,9 +167,6 @@
 #define F_TXSIZE_RND  (1<<6)  /* Transmit size is random */
 #define F_IPV6        (1<<7)  /* Interface in IPV6 Mode */
=20
-#define L_PUSH(t, i)              {i->next =3D t; t=3Di;}
-#define L_POP(t, i)               {i=3Dt; if(i) t =3D i->next;}
-
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0) =20
 #define T_STOP        (1<<1)  /* Stop run */
@@ -1366,19 +1363,15 @@
         p +=3D sprintf(p, "Running: ");
        =20
         if_lock(t);
-        pkt_dev =3D t->if_list;
-        while (pkt_dev && pkt_dev->running) {
-                p +=3D sprintf(p, "%s ", pkt_dev->ifname);
-                pkt_dev =3D pkt_dev->next;
-        }
+        for(pkt_dev =3D t->if_list;pkt_dev; pkt_dev =3D pkt_dev->next)=20
+		if(pkt_dev->running)
+			p +=3D sprintf(p, "%s ", pkt_dev->ifname);
+       =20
         p +=3D sprintf(p, "\nStopped: ");
=20
-        pkt_dev =3D t->if_list;
-        while (pkt_dev && !pkt_dev->running) {
-                p +=3D sprintf(p, "%s ", pkt_dev->ifname);
-                pkt_dev =3D pkt_dev->next;
-        }
-
+        for(pkt_dev =3D t->if_list;pkt_dev; pkt_dev =3D pkt_dev->next)=20
+		if(!pkt_dev->running)
+			p +=3D sprintf(p, "%s ", pkt_dev->ifname);
=20
 	if (t->result[0])
 		p +=3D sprintf(p, "\nResult: %s\n", t->result);
@@ -2393,7 +2386,7 @@
        thread_unlock();
 }
=20
-static int running(struct pktgen_thread *t )
+static int thread_is_running(struct pktgen_thread *t )
 {
         struct pktgen_dev *next;
         int res =3D 0;
@@ -2415,7 +2408,7 @@
        =20
         if_lock(t);
=20
-        while(running(t)) {
+        while(thread_is_running(t)) {
                 if_unlock(t);
        =20
                 interruptible_sleep_on_timeout(&queue, HZ/10);
@@ -2520,13 +2513,15 @@
                 return -EINVAL;
         }
=20
-	if (pkt_dev->skb)=20
-		kfree_skb(pkt_dev->skb);
-
         pkt_dev->stopped_at =3D getCurUs();
         pkt_dev->running =3D 0;
=20
 	show_results(pkt_dev, skb_shinfo(pkt_dev->skb)->nr_frags);
+
+	if (pkt_dev->skb)=20
+		kfree_skb(pkt_dev->skb);
+
+	pkt_dev->skb =3D NULL;
 =09
         return 0;
 }
@@ -2855,10 +2850,10 @@
=20
         for(pkt_dev=3Dt->if_list; pkt_dev; pkt_dev =3D pkt_dev->next ) {
                 if (strcmp(pkt_dev->ifname, ifname) =3D=3D 0) {
-                        goto out;
+                        break;
                 }
         }
- out:
+
         if_unlock(t);
 	PG_DEBUG(printk("pktgen: find_dev(%s) returning %p\n", ifname,pkt_dev))=
;
         return pkt_dev;
@@ -2879,8 +2874,7 @@
                 rv =3D -EBUSY;
                 goto out;
         }
-
-	L_PUSH(t->if_list, pkt_dev);
+	pkt_dev->next =3Dt->if_list; t->if_list=3Dpkt_dev;
         pkt_dev->pg_thread =3D t;
 	pkt_dev->running =3D 0;
=20
