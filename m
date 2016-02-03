From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [RFC] Inverse of flowi{4,6}_oif: flowi{4,6}_not_oif
Date: Wed, 3 Feb 2016 18:40:53 +0100
Message-ID: <CAHmME9oTdm2NaFYKdx-=Ax2v=jDPLp3EGvyFMk0CPLt-ZdXMnA@mail.gmail.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
	<CAHmME9pGKeM9=qqcxrN12ELtTjhwgBkPV0K3ixfVz3a_CBugAw@mail.gmail.com>
	<56B22A95.4010408@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40194 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964804AbcBCRlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 12:41:00 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 4813e228
	for <netdev@vger.kernel.org>;
	Wed, 3 Feb 2016 17:39:50 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 7f7fe198
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Wed, 3 Feb 2016 17:39:46 +0000 (UTC)
Received: by mail-wm0-f46.google.com with SMTP id p63so81691461wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 09:40:54 -0800 (PST)
In-Reply-To: <56B22A95.4010408@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 3, 2016 at 5:28 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
> For IPv6 start with ip6_pol_route_lookup and modifying rt6_device_match
>

If that's all it takes, then that turns out to be ridiculously easy
too. I'll get a patch together for this.

--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -467,6 +467,7 @@ static inline struct rt6_info
*rt6_device_match(struct net *net,
                                                    struct rt6_info *rt,
                                                    const struct
in6_addr *saddr,
                                                    int oif,
+                                                   int not_oif,
                                                    int flags)
 {
        struct rt6_info *local = NULL;
@@ -478,6 +479,9 @@ static inline struct rt6_info
*rt6_device_match(struct net *net,
        for (sprt = rt; sprt; sprt = sprt->dst.rt6_next) {
                struct net_device *dev = sprt->dst.dev;

+               if (not_oif && dev->ifindex == not_oif)
+                       continue;
+
                if (oif) {
                        if (dev->ifindex == oif)
                                return sprt;
@@ -856,7 +860,7 @@ static struct rt6_info
*ip6_pol_route_lookup(struct net *net,
        fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 restart:
        rt = fn->leaf;
-       rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
+       rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif,
fl6->flowi6_not_oif, flags);
        if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
                rt = rt6_multipath_select(rt, fl6, fl6->flowi6_oif, flags);
        if (rt == net->ipv6.ip6_null_entry) {
