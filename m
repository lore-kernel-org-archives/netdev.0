From: Erik Hensema <erik@hensema.net>
Subject: [PATCH 2.4.21-pre4] Propagate netfilter MARK value when tunneling
Date: Tue, 11 Mar 2003 12:18:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030311111801.GA1853@hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Cc: LARTC <lartc@mailman.ds9a.nl>,
   Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch enables the user to propagate netfilter MARK values from
tunneled packets to the tunnel packets. The primary use for this is QoS: it
enables you to MARK a packet before it enters a tunnel and then later pick
up the packet when it's about to leave the physical interface.

jamal <hadi@cyberus.ca> suggested to also propagate other skb specifics
like the tcindex and priority. I haven't included these in the current
patch for the very simple reason that I don't understand what they mean ;-)

The patch is currently limited to GRE, IPIP and SIT.

Patch is attached to this mail, but also can be downloaded from
http://dexter.hensema.net/~erik/patches/netfilter-propagate-mark-2.4.21-pre4.diff

-- 
Erik Hensema (erik@hensema.net)

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="netfilter-propagate-mark-2.4.21-pre4.diff"

--- ../linux-2.4.21-pre4/net/Config.in	Sat Aug  3 02:39:46 2002
+++ net/Config.in	Tue Mar 11 12:08:29 2003
@@ -13,6 +13,7 @@
 bool 'Network packet filtering (replaces ipchains)' CONFIG_NETFILTER
 if [ "$CONFIG_NETFILTER" = "y" ]; then
    bool '  Network packet filtering debugging' CONFIG_NETFILTER_DEBUG
+   bool '  Propagate netfilter MARK value when tunneling' CONFIG_NETFILTER_PROPAGATE_MARK
 fi
 bool 'Socket Filtering'  CONFIG_FILTER
 tristate 'Unix domain sockets' CONFIG_UNIX
--- ../linux-2.4.21-pre4/net/ipv4/ipip.c	Fri Nov 29 00:53:15 2002
+++ net/ipv4/ipip.c	Tue Mar 11 11:58:50 2003
@@ -619,6 +619,9 @@
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
+#ifdef CONFIG_NETFILTER_PROPAGATE_MARK
+		new_skb->nfmark = skb->nfmark;
+#endif
 		dev_kfree_skb(skb);
 		skb = new_skb;
 	}
--- ../linux-2.4.21-pre4/net/ipv4/ip_gre.c	Fri Nov 29 00:53:15 2002
+++ net/ipv4/ip_gre.c	Tue Mar 11 11:59:07 2003
@@ -822,6 +822,9 @@
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
+#ifdef CONFIG_NETFILTER_PROPAGATE_MARK
+		new_skb->nfmark = skb->nfmark;
+#endif
 		dev_kfree_skb(skb);
 		skb = new_skb;
 	}
--- ../linux-2.4.21-pre4/net/ipv6/sit.c	Fri Nov 29 00:53:15 2002
+++ net/ipv6/sit.c	Tue Mar 11 11:59:20 2003
@@ -571,6 +571,9 @@
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
+#ifdef CONFIG_NETFILTER_PROPAGATE_MARK
+		new_skb->nfmark = skb->nfmark;
+#endif
 		dev_kfree_skb(skb);
 		skb = new_skb;
 	}
--- ../linux-2.4.21-pre4/Documentation/Configure.help	Wed Feb 26 10:51:16 2003
+++ Documentation/Configure.help	Tue Mar 11 12:05:37 2003
@@ -2507,6 +2507,22 @@
   You can say Y here if you want to get additional messages useful in
   debugging the netfilter code.
 
+Propagate netfilter MARK value when tunneling
+CONFIG_NETFILTER_PROPAGATE_MARK
+  With this option enabled, netfilter MARK values are propagated from
+  tunneled packets to the tunnel packets. It enables you to trace
+  packets from before they enter the tunnel to the point where they
+  leave the physical interface.
+  
+  One of the possible uses is marking packets for QoS before they
+  enter a tunnel. These mark values can then be picked up by filters
+  defined by the "tc" utility when they're about the leave the 
+  physical interface.
+
+  This option currently works for GRE, IPIP and SIT tunnels.
+
+  If unsure, say N.
+
 Connection tracking (required for masq/NAT)
 CONFIG_IP_NF_CONNTRACK
   Connection tracking keeps a record of what packets have passed

--k1lZvvs/B4yU6o8G--
