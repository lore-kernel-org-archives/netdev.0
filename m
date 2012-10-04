From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: add a fib_type to fib_info
Date: Thu, 04 Oct 2012 13:25:26 +0200
Message-ID: <1349349926.16011.48.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, netdev@vger.kernel.org, gpiez@web.de,
	Dave Jones <davej@redhat.com>, Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35045 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103Ab2JDLZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 07:25:32 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so225783bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 04:25:30 -0700 (PDT)
In-Reply-To: <1349192919.12401.778.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 17:48 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Tue, 2012-10-02 at 17:35 +0200, Eric Dumazet wrote:
> > On Mon, 2012-10-01 at 22:04 +0200, Eric Dumazet wrote:
> > > On Mon, 2012-10-01 at 16:01 -0400, David Miller wrote:
> > 
> > > > If you can find a way to more reliably trigger the case, that would
> > > > help us immensely.
> > > 
> > > I am building a KMEMCHECK kernel, as a last try before my night ;)
> > 
> > This was a total disaster. KMEMCHECK dies horribly on my machine
> > 
> > David, shouldnt we use a nh_rth_forward instead of a nh_rth_input in
> > __mkroute_input() ?
> > 
> > (And change rt_cache_route() as well ?)
> > 
> > I am testing a patch right now.
> 

OK so I implemented David idea and it seems to work.

Testers are needed, thanks ! ;)

[PATCH] ipv4: add a fib_type to fib_info

commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
introduced a regression for forwarding.

This was hard to reproduce but the symptom was that packets were
delivered to local host instead of being forwarded.

David suggested to add fib_type to fib_info so that we dont
inadvertently share same fib_info for different purposes.

With help from Julian Anastasov who provided very helpful
hints, reproduced here :

<quote>
        Can it be a problem related to fib_info reuse
from different routes. For example, when local IP address
is created for subnet we have:

broadcast 192.168.0.255 dev DEV  proto kernel  scope link  src
192.168.0.1
192.168.0.0/24 dev DEV  proto kernel  scope link  src 192.168.0.1
local 192.168.0.1 dev DEV  proto kernel  scope host  src 192.168.0.1

        The "dev DEV  proto kernel  scope link  src 192.168.0.1" is
a reused fib_info structure where we put cached routes.
The result can be same fib_info for 192.168.0.255 and
192.168.0.0/24. RTN_BROADCAST is cached only for input
routes. Incoming broadcast to 192.168.0.255 can be cached
and can cause problems for traffic forwarded to 192.168.0.0/24.
So, this patch should solve the problem because it
separates the broadcast from unicast traffic.

        And the ip_route_input_slow caching will work for
local and broadcast input routes (above routes 1 and 3) just
because they differ in scope and use different fib_info.

</quote>

Many thanks to Chris Clayton for his patience and help.

Reported-by: Chris Clayton <chris2553@googlemail.com>
Bisected-by: Chris Clayton <chris2553@googlemail.com>
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_fib.h     |    1 +
 net/ipv4/fib_semantics.c |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 926142e..9497be1 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -102,6 +102,7 @@ struct fib_info {
 	unsigned char		fib_dead;
 	unsigned char		fib_protocol;
 	unsigned char		fib_scope;
+	unsigned char		fib_type;
 	__be32			fib_prefsrc;
 	u32			fib_priority;
 	u32			*fib_metrics;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3509065..2677530 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -314,6 +314,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 		    nfi->fib_scope == fi->fib_scope &&
 		    nfi->fib_prefsrc == fi->fib_prefsrc &&
 		    nfi->fib_priority == fi->fib_priority &&
+		    nfi->fib_type == fi->fib_type &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
 			   sizeof(u32) * RTAX_MAX) == 0 &&
 		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) == 0 &&
@@ -833,6 +834,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi->fib_flags = cfg->fc_flags;
 	fi->fib_priority = cfg->fc_priority;
 	fi->fib_prefsrc = cfg->fc_prefsrc;
+	fi->fib_type = cfg->fc_type;
 
 	fi->fib_nhs = nhs;
 	change_nexthops(fi) {
