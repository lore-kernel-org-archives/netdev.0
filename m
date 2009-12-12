From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] rose_loopback_timer VC number <= ROSE_DEFAULT_MAXVC
Date: Sat, 12 Dec 2009 09:56:02 +0100
Message-ID: <4B235AA2.1040608@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:48079 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757788AbZLLI4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2009 03:56:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] rose_loopback_timer VC number <= ROSE_DEFAULT_MAXVC

On my 2.6.32 kernel compiled for generic x86_64 CPU
cat /proc/net/rose displayed a rose sockets abnormal lci value, i.e. greater than maximum
number of VCs per neighbour allowed.
This out of limits number prevents further comparisons of lci value during rose VC attributions.

Example :
[bernard]# cat /proc/net/rose
dest_addr  dest_call src_addr   src_call  dev   lci neigh st vs vr va   t  t1  t2  t3  hb    idle Snd-Q Rcv-Q inode
*          *         2080175520 F6BVP-1   rose0 000 00000  0  0  0  0   0 200 180 180   5   0/000     0     0 254746
2080175520 FPAD-0    2080175520 WP-0      rose0 FFE 00001  3  0  0  0   0 200 180 180   5   0/000     0     0 12916

Here are the default parameters definitions :
linux/include/net/rose.h:#define ROSE_DEFAULT_MAXVC 50 /* Maximum number of VCs per neighbour */
linux/net/rose/af_rose.c:int sysctl_rose_maximum_vcs = ROSE_DEFAULT_MAXVC;

With the following patch, rose_loopback_timer() attributes a VC number within limits.

--- a/net/rose/rose_loopback.c	2009-12-03 04:51:21.000000000 +0100
+++ b/net/rose/rose_loopback.c	2009-12-06 23:17:02.267741413 +0100
@@ -75,7 +75,7 @@
		lci_i     = ((skb->data[0] << 8) & 0xF00) + ((skb->data[1] << 0) & 0x0FF);
		frametype = skb->data[2];
		dest      = (rose_address *)(skb->data + 4);
-		lci_o     = 0xFFF - lci_i;
+		lci_o     = ROSE_DEFAULT_MAXVC + 1 - lci_i;

		skb_reset_transport_header(skb);


Bernard Pidoux


