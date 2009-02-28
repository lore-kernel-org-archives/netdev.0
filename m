From: Kyle McMartin <kyle@infradead.org>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
	2.6.29-rc6
Date: Fri, 27 Feb 2009 22:16:18 -0500
Message-ID: <20090228031618.GB28503@bombadil.infradead.org>
References: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com> <20090224.152704.210992553.davem@davemloft.net> <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:32791 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbZB1DQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 22:16:24 -0500
Content-Disposition: inline
In-Reply-To: <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@redhat.com>

This only seems to show up when CONFIG_NET_NS is enabled. (Reproduced on
git HEAD with that option on, doesn't occur with the option off.)

I will confess complete ignorance to the network stack, but this patch
fixes things... ipv4 seems to have the same namespace support, but
increments the sock_net, not the twsk_net.

I'll probably put this patch into Fedora, if only to prevent this from
being used as a local DoS by an unprivileged user.

Signed-off-by: Kyle McMartin <kyle@redhat.com>

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 8fe267f..1bcc343 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -258,11 +258,11 @@ unique:
 
 	if (twp != NULL) {
 		*twp = tw;
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 	} else if (tw != NULL) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 
 		inet_twsk_put(tw);
 	}
