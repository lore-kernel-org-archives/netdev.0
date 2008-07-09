From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11058] New: DEADLOOP in kernel network module
Date: Wed, 09 Jul 2008 18:32:57 +0200
Message-ID: <4874E839.50100@trash.net>
References: <bug-11058-10286@http.bugzilla.kernel.org/> <20080708210014.a1d3baf8.akpm@linux-foundation.org> <4874B2DC.2070305@trash.net> <Pine.LNX.4.64.0807091519380.11391@blackhole.kfki.hu> <4874D291.1010707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010202080809000201080206"
Cc: Andrew Morton <akpm@linux-foundation.org>, hemao77@gmail.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32892 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbYGIQdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 12:33:03 -0400
In-Reply-To: <4874D291.1010707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010202080809000201080206
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Jozsef Kadlecsik wrote:
>> On Wed, 9 Jul 2008, Patrick McHardy wrote:
>>
>>> Good catch, thanks. Basically all del_timer()/timeout.function calls
>>> in conntrack can happen in process context, so we'd have to disable
>>> BHs every time we do this. I think this fix should also work. The
>>> only spot where we return NF_REPEAT is in TCP conntrack, so we can
>>> simply make sure we only do this if we actually managed to kill the
>>> connection.
>>>
>>> Jozsef, what do you think?
>>
>> I agree with you completely - and nice catch, indeed! Your proposed 
>> patch looks just fine.
> 
> Thanks, I'll send a backport for 2.6.26 to Dave tonight.

OK, this is the patch I'll send upstream.


--------------010202080809000201080206
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit baa04a1fb3dbef550ed1dc5acd15e21e7dde3b85
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 9 18:32:29 2008 +0200

    netfilter: nf_conntrack_tcp: fix endless loop
    
    When a conntrack entry is destroyed in process context and destruction
    is interrupted by packet processing and the packet is an attempt to
    reopen a closed connection, TCP conntrack tries to kill the old entry
    itself and returns NF_REPEAT to pass the packet through the hook
    again. This may lead to an endless loop: TCP conntrack repeatedly
    finds the old entry, but can not kill it itself since destruction
    is already in progress, but destruction in process context can not
    complete since TCP conntrack is keeping the CPU busy.
    
    Drop the packet in TCP conntrack if we can't kill the connection
    ourselves to avoid this.
    
    Reported by: hemao77@gmail.com [ Kernel bugzilla #11058 ]
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 271cd01..dd28fb2 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -844,9 +844,15 @@ static int tcp_packet(struct nf_conn *ct,
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
 			write_unlock_bh(&tcp_lock);
-			if (del_timer(&ct->timeout))
+			/* Only repeat if we can actually remove the timer.
+			 * Destruction may already be in progress in process
+			 * context and we must give it a chance to terminate.
+			 */
+			if (del_timer(&ct->timeout)) {
 				ct->timeout.function((unsigned long)ct);
-			return -NF_REPEAT;
+				return -NF_REPEAT;
+			}
+			return -NF_DROP;
 		}
 		/* Fall through */
 	case TCP_CONNTRACK_IGNORE:

--------------010202080809000201080206--
