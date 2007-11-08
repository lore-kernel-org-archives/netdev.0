From: Rainer Jochem <rainer.jochem@mpi-sb.mpg.de>
Subject: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Thu, 8 Nov 2007 15:32:05 +0100
Message-ID: <20071108143205.GA22490@mpi-sb.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pcernko@mpi-sws.mpg.de
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mpi-sb.mpg.de ([139.19.1.2]:59840 "EHLO
	francois.mpi-sb.mpg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbXKHPDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 10:03:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch implements the DHCP Class identifier (see rfc1533) which is
used by DHCP clients to optionally identify the type and configuration of 
a DHCP client which is send as a string to the server. For example, the
identifier may encode the client's hardware configuration. If the newly 
introduced kernel-parameter 'dhcpclass' is set, then the kernel sends 
the given string in its DHCP-request to the server.
If the option is omitted, the behaviour is as before without this patch.


Patch applies to:
Version:	2.6.23.1
File:		net/ipv4/ipconfig.c


Signed-off-by: Rainer Jochem <rainer.jochem@mpi-sb.mpg.de>

---

--- net/ipv4/ipconfig.c.orig	2007-11-08 14:54:11.001662860 +0100
+++ net/ipv4/ipconfig.c	2007-11-08 14:54:15.961480524 +0100
@@ -139,6 +139,8 @@ __be32 ic_servaddr = NONE;	/* Boot serve
 __be32 root_server_addr = NONE;	/* Address of NFS server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
+char vendor_class_identifier[256] = { 0, }; /* vendor class identifier */
+
 /* Persistent data: */
 
 static int ic_proto_used;			/* Protocol used, if any */
@@ -620,6 +622,17 @@ ic_dhcp_init_options(u8 *options)
 		*e++ = sizeof(ic_req_params);
 		memcpy(e, ic_req_params, sizeof(ic_req_params));
 		e += sizeof(ic_req_params);
+
+		// Send it only if the according kernel parameter was set
+		if (*vendor_class_identifier) {
+			printk(KERN_INFO "Sending class identifier \"%s\"\n",
+			       vendor_class_identifier);
+			*e++ = 60;	/* Class-identifier */
+			*e++ = strlen(vendor_class_identifier);
+			memcpy(e, vendor_class_identifier,
+			       strlen(vendor_class_identifier));
+			e += strlen(vendor_class_identifier);
+		}
 	}
 
 	*e++ = 255;	/* End of the list */
@@ -1507,5 +1520,14 @@ static int __init nfsaddrs_config_setup(
 	return ip_auto_config_setup(addrs);
 }
 
+static int __init vendor_class_identifier_setup(char *addrs)
+{
+	if (strlcpy(vendor_class_identifier, addrs, 250) > 250)
+		printk(KERN_WARNING "vendorclass too long, truncated to \"%s\"",
+		       vendor_class_identifier);
+	return 1;
+}
+
 __setup("ip=", ip_auto_config_setup);
 __setup("nfsaddrs=", nfsaddrs_config_setup);
+__setup("dhcpclass=", vendor_class_identifier_setup);



--- ../linux-2.6.23.1/Documentation/kernel-parameters.txt	2007-10-12 18:43:44.000000000 +0200
+++ Documentation/kernel-parameters.txt	2007-10-24 17:02:22.441454955 +0200
@@ -533,6 +533,10 @@ and is between 256 and 4096 characters. 
 	dhash_entries=	[KNL]
 			Set number of hash buckets for dentry cache.
 
+	dhcpclass=	[KNL]
+			Set DHCP Vendor Class Identifier to be sent
+			by the client.
+
 	digi=		[HW,SERIAL]
 			IO parameters + enable/disable command.


