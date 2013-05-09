From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Thu, 09 May 2013 20:53:48 +0800
Message-ID: <1368104028.12413.12.camel@cr0>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
	 <1367305819-14013-2-git-send-email-amwang@redhat.com>
	 <20130502015938.GA2237@gondor.apana.org.au> <1367553022.2415.55.camel@cr0>
	 <20130503040102.GA10898@gondor.apana.org.au> <1367564926.2415.56.camel@cr0>
	 <20130503093017.GA12471@gondor.apana.org.au> <1367810653.6246.5.camel@cr0>
	 <20130509051522.GA7998@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715Ab3EIMyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 08:54:07 -0400
In-Reply-To: <20130509051522.GA7998@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-09 at 13:15 +0800, Herbert Xu wrote:
> 
> Yes this looks about right.  BTW, for the groups-epcific queries
> you should use the leave timeout values and not the startup timeout
> values.
> 

Right, something like below:

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 11946a4..1e414ce 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1252,20 +1252,13 @@ static void br_multicast_leave_group(struct
net_bridge *br,
 
        if (br->multicast_querier &&
            !timer_pending(&br->multicast_querier_timer)) {
-               u32 sent;
-
                __br_multicast_send_query(br, port, &mp->addr);
-               sent = port ? port->multicast_startup_queries_sent :
-                             br->multicast_startup_queries_sent;
-               time = jiffies;
-               time += sent < br->multicast_startup_query_count ?
-                       br->multicast_startup_query_interval :
-                       br->multicast_query_interval;
-               mod_timer(port ? &port->multicast_query_timer :
-                                &br->multicast_query_timer, time);
 
                time = jiffies + br->multicast_last_member_count *
                                 br->multicast_last_member_interval;
+               mod_timer(port ? &port->multicast_query_timer :
+                                &br->multicast_query_timer, time);
+
                for (p = mlock_dereference(mp->ports, br);
                     p != NULL;
                     p = mlock_dereference(p->next, br)) {
