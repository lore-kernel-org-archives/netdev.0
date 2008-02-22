From: Dirk Nehring <dnehring@marcant.net>
Subject: [Patch] Crash (BUG()) when handling fragmented ESP packets
Date: Sat, 23 Feb 2008 00:23:50 +0100
Message-ID: <20080222232350.GA17555@marcant.net>
Reply-To: netdev@vger.kernel.org, Dirk Nehring <dnehring@marcant.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rossini.marcant.net ([217.14.160.69]:53268 "EHLO
	admins.marcant.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752686AbYBVXm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 18:42:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Most likely all 2.6 series kernels crash with BUG() when receives a
fragmented ESP packet where ESP header and IV are not in the first
fragment. This patches fixes this behaviour by reassembling the
fragmented packet into the sk_buff.

Signed-off-by: Dirk Nehring <dnehring@marcant.net>
Signed-off-by: Andreas Ferber <aferber@marcant.net>



Please apply this patch to 2.6.25. We tested the patch successfully on
production systems which ran into this problem.

Long description:
=================

We have come across (and fixed) a bug in the linux kernel (specifically
in the IPsec code) that has some security concerns attached. On Dec.,
12., 2007, we have contacted security@kernel.org where Herbert was also
informed.

RedHat Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=404291

Future CVE: CVE-2007-6282


BUG DESCRIPTION:
----------------

As you may know, an ESP packet starts with an ESP header (8 Octets),
depending on the encryption algorithm followed by an Initialization
Vector (eg. 16 Octets for AES-CBC, 8 Octets for 3DES-CBC). If the ESP
packet is divided into IP fragments so that the first fragment does not
contain the whole of ESP-Header plus the IV (for example only the first
8 Octets), the kernel runs into a BUG() when decoding the packet and
thus crashes instantly.

HOW TO REPRODUCE:
-----------------

To reproduce the problem you can use the following setup with three
machines:

   +----+         +----+         +----+
   | E1 |---------| IR |---------| E2 |
   +----+         +----+         +----+

 E1, E2: IPsec tunnel endpoints
 IR:     intermediate router

Setup an IPsec tunnel using 3DES-CBC or AES-CBC between E1 and E2 (I
tested it with ISAKMP keying, but it should work with manual keying
also). Now setup "IR" so that it fragments packets going from E1 to E2
into very small fragments (8 Octets each), for example using fragrouter.

Now, when you try to send some traffic through the tunnel from E1 to E2
(thus generating ESP packets), as soon as the last fragment of it has
arrived on E2, it crashes with a BUG().

Note that E1 does not have to be a linux machine, any IPsec capable
device will do.

ANALYSIS:
---------

All line numbers refer to kernel version 2.6.24-rc4.

Have a look at net/ipv4/esp4.c, function esp_input(). Starting at line
195, it tries to get the IV from the ESP packet, however it does not
take into account that the sk_buff it is handling may be paged or
fragmented. This may result in an out of bounds memory read access if
the head of the sk_buff does not contain the full ESP header plus the
IV.

Then at the end of the function, at line 268, it tries to __skb_pull()
the ESP header and IV of the packet. This is where the BUG() is
triggered, since __skb_pull() checks that there is enough data in the
sk_buff head to fulfill the pull.

When reassembling fragmented IP packets, the kernel does so using a
fragmented sk_buff (using skb->frag_list). If the first fragment is
shorter than the ESP header plus the IV, the condition to trigger the
BUG() in esp_input() is satisfied by the resulting sk_buff, thus
crashing the kernel.

The relevant code for IPv6 ESP (in net/ipv6/esp6.c) is mostly the same
as the IPv4 code, so this is affected, too.

The bug most likely exists in all 2.6 kernel versions up till today. I
explicitly checked 2.6.18 (my vendors version of that I first
encountered the bug on a few days ago) and 2.6.0. Although the code of
esp_input() changed in between, the relevant code lines exist in almost
identical form since 2.6.0 up to the latest development versions, so it
is unlikely that some version in between is unaffected by the bug.

BUGFIX:
-------

Attached you can find a patch against stable 2.6.24.1 and 2.6.25-rc2
(there are some bigger changes between 2.6.24 and 2.6.25 is the
responsible code segment). This patch modify the code in question to
correctly deal with a fragmented or paged sk_buff.

We did not test the IPv6 part of the patch, but since it is almost the
same as the IPv4 part, we are pretty confident that it will work as
advertised.

SECURITY CONCERNS:
------------------

In order to reach the code path that crashes the machine, the fragmented
ESP packet has to contain a valid SPI and must be correctly
authenticated (if authentication is used on the Policy).

Thus, you can remotely crash a vulnerable machine, if you

  (a) have control of an IPsec peer connected to it (with a valid SA
      existing)

or

  (b) have the ability to manipulate (fragment) packets going from a
      peer to the machine (note that you do not have to crack the
      encryption to do this)

An example of (b) is that if you are connecting to your company network
using an IPsec VPN from an internet cafe or WiFi hotspot, the owner of
the cafe or access point can crash your central company VPN gateway if
it is running a vulnerable version of the linux kernel.


Dirk

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.6.24.1_esp_iv_bug.patch"

diff -ur linux-2.6.24.2.orig/net/ipv4/esp4.c linux-2.6.24.2/net/ipv4/esp4.c
--- linux-2.6.24.2.orig/net/ipv4/esp4.c	2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24.2/net/ipv4/esp4.c	2008-02-12 09:02:56.000000000 +0100
@@ -165,7 +165,7 @@
 	int padlen;
 	int err;
 
-	if (!pskb_may_pull(skb, sizeof(*esph)))
+	if (!pskb_may_pull(skb, sizeof(*esph) + esp->conf.ivlen))
 		goto out;
 
 	if (elen <= 0 || (elen & (blksize-1)))
diff -ur linux-2.6.24.2.orig/net/ipv6/esp6.c linux-2.6.24.2/net/ipv6/esp6.c
--- linux-2.6.24.2.orig/net/ipv6/esp6.c	2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24.2/net/ipv6/esp6.c	2008-02-12 09:03:15.000000000 +0100
@@ -155,7 +155,7 @@
 	int nfrags;
 	int ret = 0;
 
-	if (!pskb_may_pull(skb, sizeof(*esph))) {
+	if (!pskb_may_pull(skb, sizeof(*esph) + esp->conf.ivlen)) {
 		ret = -EINVAL;
 		goto out;
 	}

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.6.25-rc2_esp_iv_bug.patch"

diff -ur linux-2.6.25-rc2.orig/net/ipv4/esp4.c linux-2.6.25-rc2/net/ipv4/esp4.c
--- linux-2.6.25-rc2.orig/net/ipv4/esp4.c	2008-02-22 21:58:26.000000000 +0100
+++ linux-2.6.25-rc2/net/ipv4/esp4.c	2008-02-22 21:59:03.000000000 +0100
@@ -336,7 +336,7 @@
 	struct scatterlist *asg;
 	int err = -EINVAL;
 
-	if (!pskb_may_pull(skb, sizeof(*esph)))
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead)))
 		goto out;
 
 	if (elen <= 0)
diff -ur linux-2.6.25-rc2.orig/net/ipv6/esp6.c linux-2.6.25-rc2/net/ipv6/esp6.c
--- linux-2.6.25-rc2.orig/net/ipv6/esp6.c	2008-02-22 21:58:26.000000000 +0100
+++ linux-2.6.25-rc2/net/ipv6/esp6.c	2008-02-22 21:59:03.000000000 +0100
@@ -282,7 +282,7 @@
 	struct scatterlist *sg;
 	struct scatterlist *asg;
 
-	if (!pskb_may_pull(skb, sizeof(*esph))) {
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead))) {
 		ret = -EINVAL;
 		goto out;
 	}

--OXfL5xGRrasGEqWY--
