From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Wed, 11 Apr 2007 20:19:55 +0200
Message-ID: <461D26CB.3010508@trash.net>
References: <200704110937.l3B9b1Kp001053@fire-2.osdl.org> <20070411094740.e7c04b49.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: milan.kocian@wq.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58808 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbXDKSUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 14:20:12 -0400
In-Reply-To: <20070411094740.e7c04b49.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 11 Apr 2007 02:37:01 -0700 bugme-daemon@bugzilla.kernel.org wrote:
> 
> 
>>http://bugzilla.kernel.org/show_bug.cgi?id=8320
>>
>>           Summary: replacing route in kernel doesn't send netlink message
>>    Kernel Version: 2.6.20.6
>>            Status: NEW
>>          Severity: low
>>             Owner: shemminger@osdl.org
>>         Submitter: milan.kocian@wq.cz
>>
>>When you replace route (via ip r r ), no netlink message is sent. Or is it feature?
>>
>>Steps to reproduce:
>>1. run 'ip monitor all' on one console
>>2. do 'ip r r EXISTING_ROUTE via DST' on second console
>>3. no message on console one
>>
>>Small patch for fib_hash (tested) but use carefully I am newbie :-) :
>>
>>--- fib_hash.c.old      2007-04-11 10:39:34.895667672 +0200
>>+++ fib_hash.c  2007-04-11 10:41:34.623466280 +0200
>>@@ -457,6 +457,8 @@
>>                        fib_release_info(fi_drop);
>>                        if (state & FA_S_ACCESSED)
>>                                rt_cache_flush(-1);
>>+                       rtmsg_fib(RTM_NEWROUTE, key, fa, cfg->fc_dst_len, tb->tb_id,
>>+                                 &cfg->fc_nlinfo);
>>                        return 0;
>>                }


I think having notifications for this case makes sense (IIRC I used
to use a similar patch some time ago, but can't find it right now).
But we need to indicate somehow that it is a replacement and not a
completely new route, either by sending a RTM_DELROUTE for the old
route first (which would match what devinet does for addresses)
or by echoing the NLM_F_REPLACE flag. The former would probably be
easier for userspace to understand since it wouldn't need to
replicate the replacement logic just to find out which rule got
replaced.

