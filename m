From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] ipv6: set accept_ra_rt_info_max_plen to 128 by default
Date: Wed, 19 Mar 2014 18:22:10 +0100
Message-ID: <20140319172210.GA29745@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35686 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759444AbaCSRWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 13:22:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been looking for the reason behind the default of
accept_ra_rt_info_max_plen being 0. No luck.

The feature has been introduced by 09c884d4 ([IPV6]: ROUTE: Add
accept_ra_rt_info_max_plen sysctl).

The only relevant discussion I found was
http://markmail.org/message/5m34bfzhox6y5lcf
with no explanation.

I imagine that the motivation for setting
accept_ra_rt_info_max_plen to 0 would be security concerns.

However, RFC 4191, section "6. Security Consideration", concludes
that the new features don't increase the risks already present:

	A malicious node could send Router Advertisement messages, specifying
	a High Default Router Preference or carrying specific routes, with
	the effect of pulling traffic away from legitimate routers.  However,
	a malicious node could easily achieve this same effect in other ways.

	For example, it could fabricate Router Advertisement messages with a
	zero Router Lifetime from the other routers, causing hosts to stop
	using the other routes.  By advertising a specific prefix, this
	attack could be carried out in a less noticeable way.  However, this
	attack has no significant incremental impact on Internet
	infrastructure security.

Sounds reasonable to me.

Also, RFC 6434 has been published since, and under 5.3. it says:

	Small Office/Home Office (SOHO) deployments supported by routers
	adhering to [RFC6204] use RFC 4191 to advertise routes to certain
	local destinations.  Consequently, nodes that will be deployed in
	SOHO environments SHOULD implement RFC 4191.


I think this should be turned on by default by setting
accept_ra_rt_info_max_plen to 128.

Also, the documentation is wrong with the "or equal to", see
ndisc.c:
	if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)

Signed-off by: Jiri Bohac <jbohac@suse.cz>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ab42c95..5a5f7d3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1219,10 +1219,9 @@ accept_ra_pinfo - BOOLEAN
 accept_ra_rt_info_max_plen - INTEGER
 	Maximum prefix length of Route Information in RA.
 
-	Route Information w/ prefix larger than or equal to this
-	variable shall be ignored.
+	Route Information w/ prefix larger than this variable shall be ignored.
 
-	Functional default: 0 if accept_ra_rtr_pref is enabled.
+	Functional default: 128 if accept_ra_rtr_pref is enabled.
 			    -1 if accept_ra_rtr_pref is disabled.
 
 accept_ra_rtr_pref - BOOLEAN
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fdbfeca..6d8d028 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -225,7 +225,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_ra_rtr_pref	= 1,
 	.rtr_probe_interval	= 60 * HZ,
 #ifdef CONFIG_IPV6_ROUTE_INFO
-	.accept_ra_rt_info_max_plen = 0,
+	.accept_ra_rt_info_max_plen = 128,
 #endif
 #endif
 	.proxy_ndp		= 0,


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
