From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 21:36:07 +0100
Message-ID: <20050125203607.GG31837@postel.suug.ch>
References: <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch> <20050125014838.GA16637@gondor.apana.org.au> <20050125020118.GC31837@postel.suug.ch> <20050124180354.63ae600d.davem@davemloft.net> <20050125022431.GD31837@postel.suug.ch> <20050124194328.20a106de.davem@davemloft.net> <20050125143319.GF31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050125143319.GF31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050125143319.GF31837@postel.suug.ch> 2005-01-25 15:33
> * David S. Miller <20050124194328.20a106de.davem@davemloft.net> 2005-01-24 19:43
> > On Tue, 25 Jan 2005 03:24:31 +0100
> > Thomas Graf <tgraf@suug.ch> wrote:
> > 
> > > This of course explains it, didn't think of that. I thought it would
> > > inherit the checksumming features.
> > 
> > It should, but only in very limited cases.
> > 
> > Because it is very chip dependant whether this works or not in
> > any case, we should probably create a special features flag for
> > this.  Something like NETIF_F_VLAN_INHERIT_FEATURES.
> 
> Can't we just use NETIF_F_HW_VLAN_TX for this and inherit
> NETIF_F_HW_CSUM | NETIF_F_IP_CSUM if it is set? I don't have any
> specs at hand though.

Vlan devices don't inherit any features at the moment but it would make
sense to do so.

NETIF_F_SG|NETIF_F_TSO:
  The normal vlan code seems to handle pskbs correctly, we don't gain
  that much though. The big gain would be in the driver specific accel
  code. I assume that the driver specific accel code is aware of
  pskbs if the card can handle it but I haven't checked this yet.

NETIF_F_NO_CSUM:
  Avoid checksumming for vlan devices on loopback interfaces.

NETIF_F_HIGHDMA|NETIF_F_FRAGLIST:
  Didn't find a reason why this would cause problems.

NETIF_F_LLTX:
  vlan code accesses statistic counters so I think we can't
  inherit. It might be worth to make it clean though.

NETIF_F_IP_CSUM|NETIF_F_HW_CSUM:
  Assuming that the vlan accel code can always do the checksumming
  if the card can do it.

Otherwise we need a mask describing which features can be
inherited.

Thoughts?

diff -Nru linux-2.6.11-rc2-bk2.orig/include/linux/if_vlan.h linux-2.6.11-rc2-bk2/include/linux/if_vlan.h
--- linux-2.6.11-rc2-bk2.orig/include/linux/if_vlan.h	2005-01-25 00:49:27.000000000 +0100
+++ linux-2.6.11-rc2-bk2/include/linux/if_vlan.h	2005-01-25 18:51:11.000000000 +0100
@@ -61,6 +61,9 @@
 
 #define VLAN_VID_MASK	0xfff
 
+#define VLAN_COMP_FEATURES(f)	((f) & (NETIF_F_SG|NETIF_F_NO_CSUM| \
+				 NETIF_F_HIGHDMA|NETIF_F_FRAGLIST|NETIF_F_TSO))
+
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(void __user *));
 
diff -Nru linux-2.6.11-rc2-bk2.orig/net/8021q/vlan.c linux-2.6.11-rc2-bk2/net/8021q/vlan.c
--- linux-2.6.11-rc2-bk2.orig/net/8021q/vlan.c	2005-01-25 00:50:01.000000000 +0100
+++ linux-2.6.11-rc2-bk2/net/8021q/vlan.c	2005-01-25 18:54:45.000000000 +0100
@@ -459,6 +459,8 @@
 	/* TODO: maybe just assign it to be ETHERNET? */
 	new_dev->type = real_dev->type;
 
+	new_dev->features = VLAN_COMP_FEATURES(real_dev->features);
+
 	new_dev->hard_header_len = real_dev->hard_header_len;
 	if (!(real_dev->features & NETIF_F_HW_VLAN_TX)) {
 		/* Regular ethernet + 4 bytes (18 total). */
@@ -477,6 +479,7 @@
 		new_dev->hard_header = real_dev->hard_header;
 		new_dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
 		new_dev->rebuild_header = real_dev->rebuild_header;
+		new_dev->features = real_dev->features & (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM);
 	} else {
 		new_dev->hard_header = vlan_dev_hard_header;
 		new_dev->hard_start_xmit = vlan_dev_hard_start_xmit;
