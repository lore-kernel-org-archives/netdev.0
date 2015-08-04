From: Rick Jones <rick.jones2@hp.com>
Subject: Diagnosing arp/neighbour table overflows and RFC for a related patch
 idea
Date: Tue, 04 Aug 2015 13:58:11 -0700
Message-ID: <55C12763.5080506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:40524 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbbHDU6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 16:58:12 -0400
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t3425.houston.hp.com (Postfix) with ESMTP id EF86580
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2015 20:58:11 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id CAE5463
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2015 20:58:11 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of my colleagues have been doing a bit of scale testing in the 
likes of OpenStack.  They get to a certain number of instances launched 
and then they start seeing messages of the form:

Sep 25 08:17:37 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[176969.125887] net_ratelimit: 62 callbacks suppressed
Sep 25 08:17:42 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[176974.193613] net_ratelimit: 56 callbacks suppressed
Sep 25 08:17:48 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[176980.231333] net_ratelimit: 105 callbacks suppressed
Sep 25 08:17:54 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[176986.270903] net_ratelimit: 51 callbacks suppressed
Sep 25 08:18:00 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[176991.804470] net_ratelimit: 81 callbacks suppressed
Sep 25 08:18:05 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[176997.352440] net_ratelimit: 93 callbacks suppressed
Sep 25 08:18:10 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[177002.408610] net_ratelimit: 80 callbacks suppressed
Sep 25 08:18:16 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[177008.083106] net_ratelimit: 38 callbacks suppressed
Sep 25 08:18:21 overcloud-novacompute7-hqauwkkp6cnb kernel: 
[177013.125626] net_ratelimit: 99 callbacks suppressed

at which point things start to go downhill...

(Don't mind the date)

And they tracked it down by virtue of a number of things to blowing past 
the default limits for the arp cache.  Make them larger, poof the 
messages go away.

I've been playing with reproducing that outside of OpenStack and when I 
knock the table size down to say 16, and then try to ping 254 distinct 
IPs at the same time, I see similar messages.  The thing is, there are 
only the suppressed messages, there is never any "base" message.

Poking around and whatnot suggests it is coming from a 
net_dbg_ratelimited call in ip_finish_output2.  I'm guessing that since 
the log level is "debug" it isn't allowing the first message to be 
printed, but that decision is made past the rate limiting thus all we 
see are the callbacks suppressed messages.

That leaves things rather confusing - very difficult to know what 
callbacks/messages were being suppressed.  I suppose their presence in 
the likes of dmesg output says that *something* overflowed and so one 
might start looking, but depending on circumstances couldn't there be a 
preceding message which might reasonably look like it was the one being 
suppressed?

Or put another way, should the rate limiting be looking "down" (somehow) 
to see if the message level would even generate output before worrying 
about doing all the rate limiting stuff?  Only downside is, those 
callbacks suppressed messages then wouldn't be there at all.

But I suppose that is slight digression.  To make this specific 
situation more explicit I was thinking of adding the following (my mail 
client may fubar the formatting):

~/net-next$ git diff
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 84195da..917f760 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -274,8 +274,11 @@ static struct neighbour *neigh_alloc(struct 
neigh_table *tbl, struct net_device
             (entries >= tbl->gc_thresh2 &&
              time_after(now, tbl->last_flush + 5 * HZ))) {
                 if (!neigh_forced_gc(tbl) &&
-                   entries >= tbl->gc_thresh3)
+                   entries >= tbl->gc_thresh3) {
+                       net_info_ratelimited("%s: neighbor table 
overflow!\n",
+                                            tbl->id);
                         goto out_entries;
+               }
         }

         n = kzalloc(tbl->entry_size + dev->neigh_priv_len, GFP_ATOMIC);


When I run my little ping-based test with that in place I see the likes of:

root@qu-stbaz1-perf0000:~# dmesg | tail
[ 1533.892669] neighbour: arp_cache: neighbor table overflow!
[ 1533.932944] neighbour: arp_cache: neighbor table overflow!
[ 1533.932950] neighbour: arp_cache: neighbor table overflow!
[ 1534.023093] neighbour: arp_cache: neighbor table overflow!
[ 1538.973979] net_ratelimit: 142 callbacks suppressed
[ 1538.973981] neighbour: arp_cache: neighbor table overflow!
[ 1538.973985] neighbour: arp_cache: neighbor table overflow!
[ 1539.063320] neighbour: arp_cache: neighbor table overflow!
[ 1539.063326] neighbour: arp_cache: neighbor table overflow!
[ 1539.099621] neighbour: arp_cache: neighbor table overflow!

which seems rather more to the point.  I'm still trying to decide if 
adding a table_overflow stat would be indicated as well.  The 
forced_gc_runs stat doesn't indicate success or failure of the garbage 
collection, so in and of itself it doesn't mean we had a failure to add 
an entry to the table.

Thoughts/comments?

happy benchmarking,

rick jones
