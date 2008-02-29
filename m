From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH (resend)][EBTABLES]: Fix alignment checks in ebt_among.ko
 module.
Date: Fri, 29 Feb 2008 11:28:44 +0300
Message-ID: <47C7C23C.2050100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43094 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431AbYB2I2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 03:28:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've sent this patch some days ago to Bart, but with no answer...

When trying to do

	# ebtables -A FORWARD --among-src 0:12:34:56:78:9a=192.168.0.10 -j ACCEPT

on x86_64 box the ebt_among->check() callback warns me that

	ebtables: among: wrong size: 1060 against expected 1056, rounded to 1056

Checking the ebtables sources, I found that the alignment is done
differently in the tool and the kernel. Tool makes it like this:

	EBT_ALIGN(sizeof(struct ebt_among_info)) + X

while the kernel module like this:

	EBT_ALIGN(sizeof(struct ebt_among_info) + X)

So the suggested fix is to move the alignment in the kernel. After
the fix the rule is added and appears in the ebtables -L output.

Originally developed by Evgeny Kravtsunov.

Signed-off-by: Evgeny Kravtsunov <emkravts@openvz.org>
Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 70b6dca..349a543 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -182,7 +182,7 @@ static int ebt_among_check(const char *tablename, unsigned int hookmask,
 			   unsigned int datalen)
 {
 	const struct ebt_among_info *info = data;
-	int expected_length = sizeof(struct ebt_among_info);
+	int expected_length = EBT_ALIGN(sizeof(struct ebt_among_info));
 	const struct ebt_mac_wormhash *wh_dst, *wh_src;
 	int err;
 
@@ -191,7 +191,7 @@ static int ebt_among_check(const char *tablename, unsigned int hookmask,
 	expected_length += ebt_mac_wormhash_size(wh_dst);
 	expected_length += ebt_mac_wormhash_size(wh_src);
 
-	if (datalen != EBT_ALIGN(expected_length)) {
+	if (datalen != expected_length) {
 		printk(KERN_WARNING
 		       "ebtables: among: wrong size: %d "
 		       "against expected %d, rounded to %Zd\n",
