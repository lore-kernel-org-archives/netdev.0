From: David Miller <davem@davemloft.net>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
 2.6.29-rc6
Date: Tue, 03 Mar 2009 14:21:02 -0800 (PST)
Message-ID: <20090303.142102.134459736.davem@davemloft.net>
References: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com>
	<20090224.152704.210992553.davem@davemloft.net>
	<20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762715AbZCCWVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:21:20 -0500
In-Reply-To: <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chuck Ebbert <cebbert@redhat.com>
Date: Tue, 24 Feb 2009 18:35:54 -0500

> On Tue, 24 Feb 2009 15:27:04 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Chuck Ebbert <cebbert@redhat.com>
> > Date: Tue, 24 Feb 2009 18:21:47 -0500
> > 
> > > (This doesn't happen on 2.6.27/28)
> > > 
> > > tw is NULL at net/ipv6/inet6_hashtables.c:261:
> > > 
> > > 	if (twp != NULL) {
> > > 		*twp = tw;
> > > ===>		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
> > > 	} else if (tw != NULL) {
> > > 
> > > I can reproduce this on real hardware on x86_64 too...
> > 
> > How? :-)
> 
> Oops, forgot to add the bug URL:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=486889
> 
> Steps to Reproduce:
> 1. Get minirpc 0.3.2 [http://minirpc.cs.cmu.edu/download/minirpc-0.3.2.tar.gz]
> 2. Run ./configure ; make ; make check

Should be fixed by:

commit 3f53a38131a4e7a053c0aa060aba0411242fb6b9
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Thu Feb 26 03:35:13 2009 -0800

    ipv6: don't use tw net when accounting for recycled tw
    
    We already have a valid net in that place, but this is not just a
    cleanup - the tw pointer can be NULL there sometimes, thus causing
    an oops in NET_NS=y case.
    
    The same place in ipv4 code already works correctly using existing
    net, rather than tw's one.
    
    The bug exists since 2.6.27.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

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
