From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Fri, 4 Mar 2005 02:20:03 +0100
Message-ID: <20050304012003.GA31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The deletion of local addresses via netlink doesn't take the
prefix length into account resulting in the deletion of
the address that was added first given multiple addresses
exist only varying in the prefix length.

tgr:axs ~ ip -4 addr show dev lo
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    inet 127.0.0.1/8 scope host lo
    inet 1.1.1.1/1 scope global lo
    inet 1.1.1.1/2 scope global lo
tgr:axs ~ ip addr del 1.1.1.1/2 dev lo
tgr:axs ~ ip -4 addr show dev lo
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    inet 127.0.0.1/8 scope host lo
    inet 1.1.1.1/2 scope global lo

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11.orig/net/ipv4/devinet.c	2005-03-04 00:45:05.000000000 +0100
+++ linux-2.6.11/net/ipv4/devinet.c	2005-03-04 01:55:54.000000000 +0100
@@ -396,8 +396,9 @@
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
 		if ((rta[IFA_LOCAL - 1] &&
+		     (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
 		     memcmp(RTA_DATA(rta[IFA_LOCAL - 1]),
-			    &ifa->ifa_local, 4)) ||
+			    &ifa->ifa_local, 4))) ||
 		    (rta[IFA_LABEL - 1] &&
 		     rtattr_strcmp(rta[IFA_LABEL - 1], ifa->ifa_label)) ||
 		    (rta[IFA_ADDRESS - 1] &&
