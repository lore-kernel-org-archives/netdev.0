From: Frank Pavlic <pavlic@de.ibm.com>
Subject: [PATCH] introducing new net device feature NETIF_F_MC_ALL
Date: Fri, 17 Sep 2004 01:10:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF09580470.88860050-ONC1256F01.006D92A3-C1256F11.007F285D@de.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 0078A6C4C1256F11_="
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 0078A6C4C1256F11_=
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,
I introduced a new net device feature flag NETIF=5FF=5FMC=5FALL.
Setting this flag network devices drivers will be triggered on every=20
multicast join and drop
regardless of already existing dev=5Fmc=5Flist entry .=20
The reason is that s390 device drivers lcs and qeth need to be informed=20
for every new Multicast IP
address being joined or dropped to register them at the hardware to get=20
multicast traffic running for
the specific Multicast group.
As LCS and OSA Express hardware  are able to virtualize network devices=20
and so to get a lot of systems=20
running concurrently with the same physical hardware it is not enough for=20
both device drivers to just get triggered=20
when a new dev=5Fmc=5Flist entry is allocated.
For example in case of Token Ring this would happen only once as the=20
hardware multicast address is hardcoded in=20
ip=5Ftr=5Fmc=5Fmap. Thus every further join of a new Multicast group p on a=
=20
Token Ring device would never trigger=20
the drivers again. As this multicast IP address has not been registered=20
yet on the card multicast packets for this group
will be dropped  by the hardware. Similar applies to Ethernet .


diff -urN linux-2.6/drivers/s390/net/lcs.c=20
linux-2.6-s390/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c    Thu Aug 26 11:23:33 2004
+++ linux-2.6-s390/drivers/s390/net/lcs.c       Thu Aug 26 11:23:45 2004
@@ -11,7 +11,7 @@
  *                       Frank Pavlic (pavlic@de.ibm.com) and
  *                       Martin Schwidefsky <schwidefsky@de.ibm.com>
  *
- *    $Revision: 1.89 $         $Date: 2004/08/24 10:49:27 $
+ *    $Revision: 1.90 $         $Date: 2004/08/26 03:29:44 $
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -59,7 +59,7 @@
 /**
  * initialization string for output
  */
-#define VERSION=5FLCS=5FC  "$Revision: 1.89 $"
+#define VERSION=5FLCS=5FC  "$Revision: 1.90 $"

 static char version[] =5F=5Finitdata =3D "LCS driver ("VERSION=5FLCS=5FC "=
/"=20
VERSION=5FLCS=5FH ")";
 static char debug=5Fbuffer[255];
@@ -101,9 +101,9 @@
                return -ENOMEM;
        }
        debug=5Fregister=5Fview(lcs=5Fdbf=5Fsetup, &debug=5Fhex=5Fascii=5Fv=
iew);
-       debug=5Fset=5Flevel(lcs=5Fdbf=5Fsetup, 4);
+       debug=5Fset=5Flevel(lcs=5Fdbf=5Fsetup, 2);
        debug=5Fregister=5Fview(lcs=5Fdbf=5Ftrace, &debug=5Fhex=5Fascii=5Fv=
iew);
-       debug=5Fset=5Flevel(lcs=5Fdbf=5Ftrace, 4);
+       debug=5Fset=5Flevel(lcs=5Fdbf=5Ftrace, 2);
        return 0;
 }

@@ -1276,9 +1276,8 @@
         LCS=5FDBF=5FTEXT(4, trace, "setmulti");
         card =3D (struct lcs=5Fcard *) dev->priv;

-        if (!lcs=5Fset=5Fthread=5Fstart=5Fbit(card, LCS=5FSET=5FMC=5FTHREA=
D)) {
+        if (!lcs=5Fset=5Fthread=5Fstart=5Fbit(card, LCS=5FSET=5FMC=5FTHREA=
D))
                schedule=5Fwork(&card->kernel=5Fthread=5Fstarter);
-       }
 }

 #endif /* CONFIG=5FIP=5FMULTICAST */
@@ -2181,8 +2180,10 @@
                goto out;
        memcpy(card->dev->dev=5Faddr, card->mac, LCS=5FMAC=5FLENGTH);
 #ifdef CONFIG=5FIP=5FMULTICAST
-       if (!lcs=5Fcheck=5Fmulticast=5Fsupport(card))
+       if (!lcs=5Fcheck=5Fmulticast=5Fsupport(card)) {
                card->dev->set=5Fmulticast=5Flist =3D lcs=5Fset=5Fmulticast=
=5Flist;
+               card->dev->features |=3D NETIF=5FF=5FMC=5FALL;
+       }
 #endif
        netif=5Fstop=5Fqueue(card->dev);
        lcs=5Fset=5Fallowed=5Fthreads(card,0xffffffff);
@@ -2294,7 +2295,6 @@
                PRINT=5FERR("Initialization failed\n");
                return rc;
        }
-
        return 0;
 }

diff -urN linux-2.6/drivers/s390/net/qeth=5Fmain.c=20
linux-2.6-s390/drivers/s390/net/qeth=5Fmain.c
--- linux-2.6/drivers/s390/net/qeth=5Fmain.c      Thu Aug 26 11:23:42 2004
+++ linux-2.6-s390/drivers/s390/net/qeth=5Fmain.c Thu Aug 26 11:23:45 2004
@@ -1,6 +1,6 @@
 /*
  *
- * linux/drivers/s390/net/qeth=5Fmain.c ($Revision: 1.132 $)
+ * linux/drivers/s390/net/qeth=5Fmain.c ($Revision: 1.133 $)
@@ -1,6 +1,6 @@
 /*
  *
- * linux/drivers/s390/net/qeth=5Fmain.c ($Revision: 1.132 $)
+ * linux/drivers/s390/net/qeth=5Fmain.c ($Revision: 1.133 $)
  *
  * Linux on zSeries OSA Express and HiperSockets support
  *
@@ -12,7 +12,7 @@
  *                       Frank Pavlic (pavlic@de.ibm.com) and
  *                       Thomas Spatzier <tspat@de.ibm.com>
  *
- *    $Revision: 1.132 $        $Date: 2004/08/19 12:39:43 $
+ *    $Revision: 1.133 $        $Date: 2004/08/26 03:29:44 $
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -78,7 +78,7 @@
 #include "qeth=5Fmpc.h"
 #include "qeth=5Ffs.h"

-#define VERSION=5FQETH=5FC "$Revision: 1.132 $"
+#define VERSION=5FQETH=5FC "$Revision: 1.133 $"
 static const char *version =3D "qeth S/390 OSA-Express driver";

 /**
@@ -6263,6 +6263,7 @@
        } else {
                PRINT=5FINFO("Multicast enabled\n");
                card->dev->flags |=3D IFF=5FMULTICAST;
+               card->dev->features |=3D NETIF=5FF=5FMC=5FALL;
        }
        return rc;
 }
diff -urN linux-2.6/include/linux/netdevice.h=20
linux-2.6-s390/include/linux/netdevice.h
--- linux-2.6/include/linux/netdevice.h Thu Aug 26 11:23:43 2004
+++ linux-2.6-s390/include/linux/netdevice.h    Thu Aug 26 11:23:45 2004
@@ -408,7 +408,10 @@
 #define NETIF=5FF=5FVLAN=5FCHALLENGED        1024    /* Device cannot hand=
le=20
VLAN packets */
 #define NETIF=5FF=5FTSO            2048    /* Can offload TCP/IP segmentat=
ion=20
*/
 #define NETIF=5FF=5FLLTX           4096    /* LockLess TX */
-
+#define NETIF=5FF=5FMC=5FALL         8192    /* trigger driver on every=20
multicast
+                                        * address been added/deleted
+                                        */
+
        /* Called after device is detached from network. */
        void                    (*uninit)(struct net=5Fdevice *dev);
        /* Called after last user reference disappears. */
diff -urN linux-2.6/net/core/dev=5Fmcast.c=20
linux-2.6-s390/net/core/dev=5Fmcast.c
--- linux-2.6/net/core/dev=5Fmcast.c      Sat Aug 14 12:55:10 2004
+++ linux-2.6-s390/net/core/dev=5Fmcast.c Thu Aug 26 11:23:45 2004
@@ -145,6 +145,8 @@
        }
        err =3D -ENOENT;
 done:
+       if (dev->features & NETIF=5FF=5FMC=5FALL)
+               =5F=5Fdev=5Fmc=5Fupload(dev);
        spin=5Funlock=5Fbh(&dev->xmit=5Flock);
        return err;
 }
@@ -193,6 +195,9 @@
        return 0;

 done:
+       if (dev->features & NETIF=5FF=5FMC=5FALL)
+               =5F=5Fdev=5Fmc=5Fupload(dev);
+
        spin=5Funlock=5Fbh(&dev->xmit=5Flock);
        if (dmi1)
                kfree(dmi1);
diff -urN linux-2.6/net/ipv4/igmp.c linux-2.6-s390/net/ipv4/igmp.c
--- linux-2.6/net/ipv4/igmp.c   Thu Aug 26 11:23:21 2004
+++ linux-2.6-s390/net/ipv4/igmp.c      Thu Aug 26 11:23:45 2004
@@ -1202,7 +1202,6 @@

                                if (!in=5Fdev->dead)
                                        ip=5Frt=5Fmulticast=5Fevent(in=5Fde=
v);
-
                                ip=5Fma=5Fput(i);
                                return;
                        }
diff -urN linux-2.6/net/ipv6/mcast.c linux-2.6-s390/net/ipv6/mcast.c
--- linux-2.6/net/ipv6/mcast.c  Sat Aug 14 12:56:01 2004
+++ linux-2.6-s390/net/ipv6/mcast.c     Thu Aug 26 11:23:45 2004
@@ -882,7 +882,6 @@
                                write=5Funlock=5Fbh(&idev->lock);

                                igmp6=5Fgroup=5Fdropped(ma);
-
                                ma=5Fput(ma);
                                return 0;
                        }


Mit  freundlichen Gr=FCssen / Best regards
Frank Pavlic
=20
Linux for eServer Development
Schoenaicher Str. 220, 71032 Boeblingen
Phone:  ext. +49-(0)7031/16-2463, int. *120-2463
mailto:   pavlic@de.ibm.com



--=_alternative 0078A6C4C1256F11_=
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable


<br><font size=3D2 face=3D"sans-serif">Hi,</font>
<br><font size=3D2 face=3D"sans-serif">I introduced a new net device feature
flag NETIF=5FF=5FMC=5FALL.</font>
<br><font size=3D2 face=3D"sans-serif">Setting this flag network devices dr=
ivers
will be triggered on every multicast join and drop</font>
<br><font size=3D2 face=3D"sans-serif">regardless of already existing dev=
=5Fmc=5Flist
entry . </font>
<br><font size=3D2 face=3D"sans-serif">The reason is that s390 device drive=
rs
lcs and qeth need to be informed for every new Multicast IP</font>
<br><font size=3D2 face=3D"sans-serif">address being joined or dropped to r=
egister
them at the hardware to get multicast traffic running for</font>
<br><font size=3D2 face=3D"sans-serif">the specific Multicast group.</font>
<br><font size=3D2 face=3D"sans-serif">As LCS and OSA Express hardware &nbs=
p;are
able to virtualize network devices and so to get a lot of systems </font>
<br><font size=3D2 face=3D"sans-serif">running concurrently with the same p=
hysical
hardware it is not enough for both device drivers to just get triggered
</font>
<br><font size=3D2 face=3D"sans-serif">when a new dev=5Fmc=5Flist entry is =
allocated.</font>
<br><font size=3D2 face=3D"sans-serif">For example in case of Token Ring th=
is
would happen only once as the hardware multicast address is hardcoded in
</font>
<br><font size=3D2 face=3D"sans-serif">ip=5Ftr=5Fmc=5Fmap. Thus every furth=
er join
of a new Multicast group p on a Token Ring device would never trigger </fon=
t>
<br><font size=3D2 face=3D"sans-serif">the drivers again. As this multicast
IP address has not been registered yet on the card multicast packets for
this group</font>
<br><font size=3D2 face=3D"sans-serif">will be dropped &nbsp;by the hardwar=
e.
Similar applies to Ethernet .</font>
<br>
<br>
<br><font size=3D2 face=3D"sans-serif">diff -urN linux-2.6/drivers/s390/net=
/lcs.c
linux-2.6-s390/drivers/s390/net/lcs.c</font>
<br><font size=3D2 face=3D"sans-serif">--- linux-2.6/drivers/s390/net/lcs.c
&nbsp; &nbsp;Thu Aug 26 11:23:33 2004</font>
<br><font size=3D2 face=3D"sans-serif">+++ linux-2.6-s390/drivers/s390/net/=
lcs.c
&nbsp; &nbsp; &nbsp; Thu Aug 26 11:23:45 2004</font>
<br><font size=3D2 face=3D"sans-serif">@@ -11,7 +11,7 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Frank Pavlic (pavlic@de.ib=
m.com)
and</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Martin Schwidefsky &lt;sch=
widefsky@de.ibm.com&gt;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">- * &nbsp; &nbsp;$Revision: 1.89 $ &=
nbsp;
&nbsp; &nbsp; &nbsp; $Date: 2004/08/24 10:49:27 $</font>
<br><font size=3D2 face=3D"sans-serif">+ * &nbsp; &nbsp;$Revision: 1.90 $ &=
nbsp;
&nbsp; &nbsp; &nbsp; $Date: 2004/08/26 03:29:44 $</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * This program is free softwa=
re;
you can redistribute it and/or modify</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * it under the terms of the G=
NU
General Public License as published by</font>
<br><font size=3D2 face=3D"sans-serif">@@ -59,7 +59,7 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;/**</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * initialization string for o=
utput</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; */</font>
<br><font size=3D2 face=3D"sans-serif">-#define VERSION=5FLCS=5FC &nbsp;&qu=
ot;$Revision:
1.89 $&quot;</font>
<br><font size=3D2 face=3D"sans-serif">+#define VERSION=5FLCS=5FC &nbsp;&qu=
ot;$Revision:
1.90 $&quot;</font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp;static char version[] =5F=5Fin=
itdata
=3D &quot;LCS driver (&quot;VERSION=5FLCS=5FC &quot;/&quot; VERSION=5FLCS=
=5FH &quot;)&quot;;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;static char debug=5Fbuffer[255=
];</font>
<br><font size=3D2 face=3D"sans-serif">@@ -101,9 +101,9 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; return -ENOMEM;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; debug=5F=
register=5Fview(lcs=5Fdbf=5Fsetup,
&amp;debug=5Fhex=5Fascii=5Fview);</font>
<br><font size=3D2 face=3D"sans-serif">- &nbsp; &nbsp; &nbsp; debug=5Fset=
=5Flevel(lcs=5Fdbf=5Fsetup,
4);</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; debug=5Fset=
=5Flevel(lcs=5Fdbf=5Fsetup,
2);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; debug=5F=
register=5Fview(lcs=5Fdbf=5Ftrace,
&amp;debug=5Fhex=5Fascii=5Fview);</font>
<br><font size=3D2 face=3D"sans-serif">- &nbsp; &nbsp; &nbsp; debug=5Fset=
=5Flevel(lcs=5Fdbf=5Ftrace,
4);</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; debug=5Fset=
=5Flevel(lcs=5Fdbf=5Ftrace,
2);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; return 0=
;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;}</font>
<br>
<br><font size=3D2 face=3D"sans-serif">@@ -1276,9 +1276,8 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;LC=
S=5FDBF=5FTEXT(4,
trace, &quot;setmulti&quot;);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ca=
rd
=3D (struct lcs=5Fcard *) dev-&gt;priv;</font>
<br>
<br><font size=3D2 face=3D"sans-serif">- &nbsp; &nbsp; &nbsp; &nbsp;if (!lc=
s=5Fset=5Fthread=5Fstart=5Fbit(card,
LCS=5FSET=5FMC=5FTHREAD)) {</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp;if (!lc=
s=5Fset=5Fthread=5Fstart=5Fbit(card,
LCS=5FSET=5FMC=5FTHREAD))</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; schedule=5Fwork(&amp;card-&gt;kernel=5Fthread=5Fstarter);</fo=
nt>
<br><font size=3D2 face=3D"sans-serif">- &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;}</font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#endif /* CONFIG=5FIP=5FMULTIC=
AST
*/</font>
<br><font size=3D2 face=3D"sans-serif">@@ -2181,8 +2180,10 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; goto out;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; memcpy(c=
ard-&gt;dev-&gt;dev=5Faddr,
card-&gt;mac, LCS=5FMAC=5FLENGTH);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#ifdef CONFIG=5FIP=5FMULTICAST=
</font>
<br><font size=3D2 face=3D"sans-serif">- &nbsp; &nbsp; &nbsp; if (!lcs=5Fch=
eck=5Fmulticast=5Fsupport(card))</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; if (!lcs=5Fch=
eck=5Fmulticast=5Fsupport(card))
{</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; card-&gt;dev-&gt;set=5Fmulticast=5Flist =3D lcs=5Fset=5Fmulti=
cast=5Flist;</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; card-&gt;dev-&gt;features |=3D NETIF=5FF=5FMC=5FALL;</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#endif</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; netif=5F=
stop=5Fqueue(card-&gt;dev);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; lcs=5Fse=
t=5Fallowed=5Fthreads(card,0xffffffff);</font>
<br><font size=3D2 face=3D"sans-serif">@@ -2294,7 +2295,6 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; PRINT=5FERR(&quot;Initialization failed\n&quot;);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; return rc;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">-</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; return 0=
;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;}</font>
<br>
<br><font size=3D2 face=3D"sans-serif">diff -urN linux-2.6/drivers/s390/net=
/qeth=5Fmain.c
linux-2.6-s390/drivers/s390/net/qeth=5Fmain.c</font>
<br><font size=3D2 face=3D"sans-serif">--- linux-2.6/drivers/s390/net/qeth=
=5Fmain.c
&nbsp; &nbsp; &nbsp;Thu Aug 26 11:23:42 2004</font>
<br><font size=3D2 face=3D"sans-serif">+++ linux-2.6-s390/drivers/s390/net/=
qeth=5Fmain.c
Thu Aug 26 11:23:45 2004</font>
<br><font size=3D2 face=3D"sans-serif">@@ -1,6 +1,6 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;/*</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">- * linux/drivers/s390/net/qeth=5Fma=
in.c
($Revision: 1.132 $)</font>
<br><font size=3D2 face=3D"sans-serif">+ * linux/drivers/s390/net/qeth=5Fma=
in.c
($Revision: 1.133 $)</font>
<br><font size=3D2 face=3D"sans-serif">@@ -1,6 +1,6 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;/*</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">- * linux/drivers/s390/net/qeth=5Fma=
in.c
($Revision: 1.132 $)</font>
<br><font size=3D2 face=3D"sans-serif">+ * linux/drivers/s390/net/qeth=5Fma=
in.c
($Revision: 1.133 $)</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * Linux on zSeries OSA Express
and HiperSockets support</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">@@ -12,7 +12,7 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Frank Pavlic (pavlic@de.ib=
m.com)
and</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Thomas Spatzier &lt;tspat@=
de.ibm.com&gt;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">- * &nbsp; &nbsp;$Revision: 1.132 $
&nbsp; &nbsp; &nbsp; &nbsp;$Date: 2004/08/19 12:39:43 $</font>
<br><font size=3D2 face=3D"sans-serif">+ * &nbsp; &nbsp;$Revision: 1.133 $
&nbsp; &nbsp; &nbsp; &nbsp;$Date: 2004/08/26 03:29:44 $</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; *</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * This program is free softwa=
re;
you can redistribute it and/or modify</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; * it under the terms of the G=
NU
General Public License as published by</font>
<br><font size=3D2 face=3D"sans-serif">@@ -78,7 +78,7 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#include &quot;qeth=5Fmpc.h&qu=
ot;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#include &quot;qeth=5Ffs.h&quo=
t;</font>
<br>
<br><font size=3D2 face=3D"sans-serif">-#define VERSION=5FQETH=5FC &quot;$R=
evision:
1.132 $&quot;</font>
<br><font size=3D2 face=3D"sans-serif">+#define VERSION=5FQETH=5FC &quot;$R=
evision:
1.133 $&quot;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;static const char *version =3D=
 &quot;qeth
S/390 OSA-Express driver&quot;;</font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp;/**</font>
<br><font size=3D2 face=3D"sans-serif">@@ -6263,6 +6263,7 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; } else {=
</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; PRINT=5FINFO(&quot;Multicast enabled\n&quot;);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; card-&gt;dev-&gt;flags |=3D IFF=5FMULTICAST;</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; card-&gt;dev-&gt;features |=3D NETIF=5FF=5FMC=5FALL;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; return r=
c;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;}</font>
<br><font size=3D2 face=3D"sans-serif">diff -urN linux-2.6/include/linux/ne=
tdevice.h
linux-2.6-s390/include/linux/netdevice.h</font>
<br><font size=3D2 face=3D"sans-serif">--- linux-2.6/include/linux/netdevic=
e.h
Thu Aug 26 11:23:43 2004</font>
<br><font size=3D2 face=3D"sans-serif">+++ linux-2.6-s390/include/linux/net=
device.h
&nbsp; &nbsp;Thu Aug 26 11:23:45 2004</font>
<br><font size=3D2 face=3D"sans-serif">@@ -408,7 +408,10 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#define NETIF=5FF=5FVLAN=5FCHA=
LLENGED
&nbsp; &nbsp; &nbsp; &nbsp;1024 &nbsp; &nbsp;/* Device cannot handle VLAN
packets */</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#define NETIF=5FF=5FTSO &nbsp;=
 &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp;2048 &nbsp; &nbsp;/* Can offload TCP/IP segmenta=
tion
*/</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;#define NETIF=5FF=5FLLTX &nbsp=
; &nbsp;
&nbsp; &nbsp; &nbsp; 4096 &nbsp; &nbsp;/* LockLess TX */</font>
<br><font size=3D2 face=3D"sans-serif">-</font>
<br><font size=3D2 face=3D"sans-serif">+#define NETIF=5FF=5FMC=5FALL &nbsp;=
 &nbsp;
&nbsp; &nbsp; 8192 &nbsp; &nbsp;/* trigger driver on every multicast</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp;* address been added/deleted</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp;*/</font>
<br><font size=3D2 face=3D"sans-serif">+</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; /* Called
after device is detached from network. */</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; void &nb=
sp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;(*uninit)(str=
uct
net=5Fdevice *dev);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; /* Called
after last user reference disappears. */</font>
<br><font size=3D2 face=3D"sans-serif">diff -urN linux-2.6/net/core/dev=5Fm=
cast.c
linux-2.6-s390/net/core/dev=5Fmcast.c</font>
<br><font size=3D2 face=3D"sans-serif">--- linux-2.6/net/core/dev=5Fmcast.c=
 &nbsp;
&nbsp; &nbsp;Sat Aug 14 12:55:10 2004</font>
<br><font size=3D2 face=3D"sans-serif">+++ linux-2.6-s390/net/core/dev=5Fmc=
ast.c
Thu Aug 26 11:23:45 2004</font>
<br><font size=3D2 face=3D"sans-serif">@@ -145,6 +145,8 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; err =3D =
-ENOENT;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;done:</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; if (dev-&gt;f=
eatures
&amp; NETIF=5FF=5FMC=5FALL)</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; =5F=5Fdev=5Fmc=5Fupload(dev);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; spin=5Fu=
nlock=5Fbh(&amp;dev-&gt;xmit=5Flock);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; return e=
rr;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp;}</font>
<br><font size=3D2 face=3D"sans-serif">@@ -193,6 +195,9 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; return 0=
;</font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp;done:</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; if (dev-&gt;f=
eatures
&amp; NETIF=5FF=5FMC=5FALL)</font>
<br><font size=3D2 face=3D"sans-serif">+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; =5F=5Fdev=5Fmc=5Fupload(dev);</font>
<br><font size=3D2 face=3D"sans-serif">+</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; spin=5Fu=
nlock=5Fbh(&amp;dev-&gt;xmit=5Flock);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; if (dmi1=
)</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; kfree(dmi1);</font>
<br><font size=3D2 face=3D"sans-serif">diff -urN linux-2.6/net/ipv4/igmp.c
linux-2.6-s390/net/ipv4/igmp.c</font>
<br><font size=3D2 face=3D"sans-serif">--- linux-2.6/net/ipv4/igmp.c &nbsp;
Thu Aug 26 11:23:21 2004</font>
<br><font size=3D2 face=3D"sans-serif">+++ linux-2.6-s390/net/ipv4/igmp.c &=
nbsp;
&nbsp; &nbsp;Thu Aug 26 11:23:45 2004</font>
<br><font size=3D2 face=3D"sans-serif">@@ -1202,7 +1202,6 @@</font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if
(!in=5Fdev-&gt;dead)</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; ip=5Frt=5Fmulticast=5Fevent(in=5Fdev);</font>
<br><font size=3D2 face=3D"sans-serif">-</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip=5F=
ma=5Fput(i);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; retur=
n;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }</font>
<br><font size=3D2 face=3D"sans-serif">diff -urN linux-2.6/net/ipv6/mcast.c
linux-2.6-s390/net/ipv6/mcast.c</font>
<br><font size=3D2 face=3D"sans-serif">--- linux-2.6/net/ipv6/mcast.c &nbsp=
;Sat
Aug 14 12:56:01 2004</font>
<br><font size=3D2 face=3D"sans-serif">+++ linux-2.6-s390/net/ipv6/mcast.c
&nbsp; &nbsp; Thu Aug 26 11:23:45 2004</font>
<br><font size=3D2 face=3D"sans-serif">@@ -882,7 +882,6 @@</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; write=
=5Funlock=5Fbh(&amp;idev-&gt;lock);</font>
<br>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; igmp6=
=5Fgroup=5Fdropped(ma);</font>
<br><font size=3D2 face=3D"sans-serif">-</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ma=5F=
put(ma);</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return
0;</font>
<br><font size=3D2 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }</font>
<br>
<br><font size=3D2 face=3D"sans-serif"><br>
Mit &nbsp;freundlichen Gr=FCssen / Best regards<br>
Frank Pavlic<br>
 &nbsp;<br>
Linux for eServer Development<br>
Schoenaicher Str. 220, 71032 Boeblingen<br>
Phone: &nbsp;ext. +49-(0)7031/16-2463, int. *120-2463<br>
mailto: &nbsp; pavlic@de.ibm.com<br>
<br>
<br>
</font>
--=_alternative 0078A6C4C1256F11_=--
