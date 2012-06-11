From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?Q?net=2Fnetfilter=2Fnf=5Fconnt?=
	=?utf-8?B?cmFja19wcm90b190Y3AuYzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZf?=
	=?utf-8?B?cHJvdG9fbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYdXNlcuKAmQ==?=
Date: Tue, 12 Jun 2012 00:15:21 +0200
Message-ID: <20120611221521.GA27239@1984>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
Content-Transfer-Encoding: 8bit
Cc: wfg@linux.intel.com, Gao feng <gaofeng@cn.fujitsu.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41315 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab2FKWP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 18:15:26 -0400
Content-Disposition: inline
In-Reply-To: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi David,

On Tue, Jun 12, 2012 at 05:36:30AM +0800, wfg@linux.intel.com wrote:
> FYI, kernel build failed on
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   9136461ab921fd5066ba6a0de08399e2172f4d71
> commit: d2ba1fde42af44fbce361202e9af13daff9e4381 [105/125] netfilter: nf_ct_tcp: add namespace support
> config: i386-randconfig-net5 (attached as .config)
> 
> All related error/warning messages are:
> 
> net/netfilter/nf_conntrack_proto_tcp.c: In function ‘tcpv4_init_net’:
> net/netfilter/nf_conntrack_proto_tcp.c:1606:9: error: ‘struct nf_proto_net’ has no member named ‘user’
> net/netfilter/nf_conntrack_proto_tcp.c: In function ‘tcpv6_init_net’:
> net/netfilter/nf_conntrack_proto_tcp.c:1643:9: error: ‘struct nf_proto_net’ has no member named ‘user’

Could you please apply the following patch to net-next to resolve
this? Thanks.

--5mCyUwZo2JvN/JJP
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="0001-netfilter-nf_ct_tcp-udp-fix-compilation-with-sysctl-.patch"
Content-Transfer-Encoding: 8bit

>From 66325515b2c4b3f112d81da03ac9f1018577c9cf Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 11 Jun 2012 23:58:01 +0200
Subject: [PATCH] netfilter: nf_ct_tcp, udp: fix compilation with sysctl
 disabled
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

This patch fixes the compilation of the TCP and UDP trackers with sysctl
compilation disabled:

net/netfilter/nf_conntrack_proto_udp.c: In function ‘udp_init_net_data’:
net/netfilter/nf_conntrack_proto_udp.c:279:13: error: ‘struct nf_proto_net’ has no member named
 ‘user’
net/netfilter/nf_conntrack_proto_tcp.c:1606:9: error: ‘struct nf_proto_net’ has no member named
 ‘user’
net/netfilter/nf_conntrack_proto_tcp.c:1643:9: error: ‘struct nf_proto_net’ has no member named
 ‘user’

Reported-by: Fengguang Wu <wfg@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 net/netfilter/nf_conntrack_proto_udp.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 1cff854..99caa13 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1603,7 +1603,7 @@ static int tcpv4_init_net(struct net *net)
 #ifdef CONFIG_SYSCTL
 	if (!pn->ctl_table) {
 #else
-	if (!pn->user++) {
+	if (!pn->users++) {
 #endif
 		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 			tn->timeouts[i] = tcp_timeouts[i];
@@ -1640,7 +1640,7 @@ static int tcpv6_init_net(struct net *net)
 #ifdef CONFIG_SYSCTL
 	if (!pn->ctl_table) {
 #else
-	if (!pn->user++) {
+	if (!pn->users++) {
 #endif
 		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 			tn->timeouts[i] = tcp_timeouts[i];
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 360565a..a83cf93 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -276,7 +276,7 @@ static void udp_init_net_data(struct nf_udp_net *un)
 #ifdef CONFIG_SYSCTL
 	if (!un->pn.ctl_table) {
 #else
-	if (!un->pn.user++) {
+	if (!un->pn.users++) {
 #endif
 		for (i = 0; i < UDP_CT_MAX; i++)
 			un->timeouts[i] = udp_timeouts[i];
-- 
1.7.10


--5mCyUwZo2JvN/JJP--
