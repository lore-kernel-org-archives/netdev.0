From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Mon, 5 Sep 2011 15:45:12 -0700
Message-ID: <20110905154512.4cce78d6@nehalam.ftrdhcpuser.net>
References: <20110902172220.830228928@vyatta.com>
	<20110902172247.396753508@vyatta.com>
	<4E614CF7.7030700@gmail.com>
	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
	<4E6272BC.4020707@gmail.com>
	<20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
	<4E632A2E.5040805@gmail.com>
	<20110904093634.685d7c56@nehalam.ftrdhcpuser.net>
	<4E65046E.1020005@gmail.com>
	<20110905105735.1b912715@nehalam.ftrdhcpuser.net>
	<4E651CB4.3070707@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36827 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200Ab1IEWpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 18:45:02 -0400
In-Reply-To: <4E651CB4.3070707@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Sep 2011 04:02:12 +0900
Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:

> On 06/09/11 02:57, Stephen Hemminger wrote:
> > The root cause of the problem is applications that don't deal with unresolved
> > IPv6 addresses. I already had to solve this in our distribution for NTP in a
> > not bridge related problem. It is better to fix the applications to understand
> > IPv6 address semantics than to try and force bridge to behave in a way that
> > is friendly to these applications.
> Care to share the patch that you did for NTP? Perhaps, I may apply the same trick and tried it out on dnsmasq and radvd if I have time.

It has been submitted upstream, but probably an eternity until
it ever gets merged through the NTP project...

The problem happens on our system because NTP runs before interfaces
brought up.



commit 0997ebe40b2835a58ba2ea1e504e38d6d29c95ed
Author: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date:   Tue Oct 26 17:55:04 2010 -0700

    Ignore IPV6 Dynamic addresses
    
    During boot link-local addresses are generated dynamically.
    These addresses are in a tentative state until after resolution occurs.
    While in the tentative state, the address can not be bound to.
    NTP daemon will see the address become available later when it rescans.
    
    (revised patch for 4.2.4p6)

diff --git a/lib/isc/unix/interfaceiter.c b/lib/isc/unix/interfaceiter.c
index 87af69e..64a9f4f 100644
--- a/lib/isc/unix/interfaceiter.c
+++ b/lib/isc/unix/interfaceiter.c
@@ -151,6 +151,7 @@ get_addr(unsigned int family, isc_netaddr_t *dst, struct sockaddr *src,
 static isc_result_t linux_if_inet6_next(isc_interfaceiter_t *);
 static isc_result_t linux_if_inet6_current(isc_interfaceiter_t *);
 static void linux_if_inet6_first(isc_interfaceiter_t *iter);
+#include <linux/if_addr.h>
 #endif
 
 #if HAVE_GETIFADDRS
@@ -216,6 +217,11 @@ linux_if_inet6_current(isc_interfaceiter_t *iter) {
 			      "/proc/net/if_inet6:strlen(%s) != 32", address);
 		return (ISC_R_FAILURE);
 	}
+#ifdef __linux
+	/* Ignore DAD addresses -- can't bind to them till resolved */
+	if (flags & IFA_F_TENTATIVE)
+		return (ISC_R_IGNORE);
+#endif
 	for (i = 0; i < 16; i++) {
 		unsigned char byte;
 		static const char hex[] = "0123456789abcdef";
