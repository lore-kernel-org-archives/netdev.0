From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: Multicast on b44
Date: Sun, 16 Jan 2005 02:08:09 +0200
Message-ID: <20050116000809.GB5334@ee.oulu.fi>
References: <f3ddc6d305011320416635914@mail.gmail.com> <20050115233836.GA5334@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Hubbard <jameshubbard@gmail.com>
Content-Disposition: inline
In-Reply-To: <20050115233836.GA5334@ee.oulu.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 01:38:36AM +0200, Pekka Pietikainen wrote:
> It looks like the b44 driver is limited to 32 entries (B44_MCAST_TABLE_SIZE)
> whereas bcm4400 goes up to 63. It's just a #define so you should be able to
> up it to that and be safe, might be worth upping it to that in b44 by
> default. 
> 
> If you need more than that you're stuck with allmulti, which if I remember
> correctly didn't work. Yup, from a previous mail of mine I did test it at
> one point:
> 
> "Ok, after some digging around ALLMULTI breaking is not a bug, the
> vendor-provided driver seems to break in similar ways, at least on 2.6,
> so that's a feature unless they fix it in theirs so I can copy the fix :-)"
> 
But do try with RXCONFIG_ALLMULTI instead of _PROMISC. Anyway, here's
something totally untested:

X-It-Compiles-Lets-Ship-It-By: pp@ee.oulu.fi
--- ./b44.h.2	2005-01-16 02:00:27.000000000 +0200
+++ ./b44.h	2005-01-16 02:00:52.000000000 +0200
@@ -358,7 +358,7 @@
 	DECLARE_PCI_UNMAP_ADDR(mapping);
 };
 
-#define B44_MCAST_TABLE_SIZE	32
+#define B44_MCAST_TABLE_SIZE	63
 #define B44_BOUNCEBUF_SHIFT	3
 #define B44_NUM_BOUNCEBUFS	(1 << B44_BOUNCEBUF_SHIFT)
 
--- ./b44.c.2	2005-01-16 02:00:25.000000000 +0200
+++ ./b44.c	2005-01-16 02:04:06.000000000 +0200
@@ -1425,12 +1425,14 @@
 	} else {
 		__b44_set_mac_addr(bp);
 
-		if (dev->flags & IFF_ALLMULTI)
-			val |= RXCONFIG_ALLMULTI;
+		if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > B44_MCAST_TABLE_SIZE))
+			/* RXCONFIG_ALLMULTI seems to disable unicast packets :-( */
+			val |= RXCONFIG_PROMISC;
 		else
 			i=__b44_load_mcast(bp, dev);
 		
-		for(;i<64;i++) {
+		/* Fill in remaining entries with zero */
+		for(;i<B44_MCAST_TABLE_SIZE+1;i++) {
 			__b44_cam_write(bp, zero, i);			
 		}
 		bw32(bp, B44_RXCONFIG, val);
