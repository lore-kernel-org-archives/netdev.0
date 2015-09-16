From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm4_garbage_collect reaching limit
Date: Wed, 16 Sep 2015 10:45:41 +0200
Message-ID: <20150916084541.GB7701@secunet.com>
References: <CAOZ2QJPt=3YmLG=S2Zf70yNPwLf-dbWtiyWJNbfYMRrQ5C6EZg@mail.gmail.com>
 <20150911094808.GI25499@secunet.com>
 <CAOZ2QJPAb4PfoBybPuhMokh9jhRFY0XSNMajf75Mgx=3=KXfUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Dan Streetman <ddstreet@ieee.org>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	<netdev@vger.kernel.org>
To: Dan Streetman <dan.streetman@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42279 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbbIPIpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 04:45:44 -0400
Content-Disposition: inline
In-Reply-To: <CAOZ2QJPAb4PfoBybPuhMokh9jhRFY0XSNMajf75Mgx=3=KXfUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 11:14:59PM -0400, Dan Streetman wrote:
> On Fri, Sep 11, 2015 at 5:48 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> >
> >> Possibly the
> >> default value of xfrm4_gc_thresh could be set proportional to
> >> num_online_cpus(), but that doesn't help when cpus are onlined after
> >> boot.
> >
> > This could be an option, we could change the xfrm4_gc_thresh value with
> > a cpu notifier callback if more cpus come up after boot.
> 
> the issue there is, if the value is changed by the user, does a cpu
> hotplug reset it back to default...

What about the patch below? With this we are independent of the number
of cpus. It should cover most, if not all usecases.

While we are at it, we could think about increasing the flowcache
percpu limit. This value was choosen back in 2003, so maybe we could
have more than 4k cache entries per cpu these days.


Subject: [PATCH RFC] xfrm: Let the flowcache handle its size by default.

The xfrm flowcache size is limited by the flowcache limit
(4096 * number of online cpus) and the xfrm garbage collector
threshold (2 * 32768), whatever is reached first. This means
that we can hit the garbage collector limit only on systems
with more than 16 cpus. On such systems we simply refuse
new allocations if we reach the limit, so new flows are dropped.
On syslems with 16 or less cpus, we hit the flowcache limit.
In this case, we shrink the flow cache instead of refusing new
flows.

We increase the xfrm garbage collector threshold to INT_MAX
to get the same behaviour, independent of the number of cpus.

The xfrm garbage collector threshold can still be set below
the flowcache limit to reduce the memory usage of the flowcache.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 Documentation/networking/ip-sysctl.txt | 6 ++++--
 net/ipv4/xfrm4_policy.c                | 2 +-
 net/ipv6/xfrm6_policy.c                | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2..260f30b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1199,7 +1199,8 @@ tag - INTEGER
 xfrm4_gc_thresh - INTEGER
 	The threshold at which we will start garbage collecting for IPv4
 	destination cache entries.  At twice this value the system will
-	refuse new allocations.
+	refuse new allocations. The value must be set below the flowcache
+	limit (4096 * number of online cpus) to take effect.
 
 igmp_link_local_mcast_reports - BOOLEAN
 	Enable IGMP reports for link local multicast groups in the
@@ -1645,7 +1646,8 @@ ratelimit - INTEGER
 xfrm6_gc_thresh - INTEGER
 	The threshold at which we will start garbage collecting for IPv6
 	destination cache entries.  At twice this value the system will
-	refuse new allocations.
+	refuse new allocations. The value must be set below the flowcache
+	limit (4096 * number of online cpus) to take effect.
 
 
 IPv6 Update by:
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 1e06c4f..3dffc73 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -248,7 +248,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
-	.gc_thresh =		32768,
+	.gc_thresh =		INT_MAX,
 };
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f10b940..e9af39a 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -289,7 +289,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
-	.gc_thresh =		32768,
+	.gc_thresh =		INT_MAX,
 };
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
-- 
1.9.1
