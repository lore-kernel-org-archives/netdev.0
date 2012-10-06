From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/16] ipvs: fix ip_vs_set_timeout debug messages
Date: Sat, 6 Oct 2012 06:45:04 +0000
Message-ID: <201210060645.05225.arnd@arndb.de>
References: <1349448930-23976-1-git-send-email-arnd@arndb.de> <1349448930-23976-9-git-send-email-arnd@arndb.de> <alpine.LFD.2.00.1210052305190.1639@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1210052305190.1639@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 October 2012, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 5 Oct 2012, Arnd Bergmann wrote:
> 
> > The ip_vs_set_timeout function sets timeouts for TCP and UDP, which
> > can be enabled independently at compile time. The debug message
> > always prints both timeouts that are passed into the function,
> > but if one is disabled, the message will show uninitialized data.
> > 
> > This splits the debug message into two separte IP_VS_DBG statements
> > that are in the same #ifdef section to ensure we only print the
> > text about what is actually going on.
> > 
> > Without this patch, building ARM ixp4xx_defconfig results in:
> 
> 	Are there any CONFIG_IP_VS_PROTO_xxx options in this
> default config? It is a waste of memory if IPVS is compiled
> without any protocols.

They all appear to be turned off:

$ grep CONFIG_IP_VS obj-tmp/.config
CONFIG_IP_VS=m
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12
# CONFIG_IP_VS_PROTO_TCP is not set
# CONFIG_IP_VS_PROTO_UDP is not set
# CONFIG_IP_VS_PROTO_AH_ESP is not set
# CONFIG_IP_VS_PROTO_ESP is not set
# CONFIG_IP_VS_PROTO_AH is not set
# CONFIG_IP_VS_PROTO_SCTP is not set
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
# CONFIG_IP_VS_SED is not set
# CONFIG_IP_VS_NQ is not set
CONFIG_IP_VS_SH_TAB_BITS=8

> > net/netfilter/ipvs/ip_vs_ctl.c: In function 'ip_vs_genl_set_cmd':
> > net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.udp_timeout' may be used uninitialized in this function [-Wuninitialized]
> > net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.udp_timeout' was declared here
> > net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_fin_timeout' may be used uninitialized in this function [-Wuninitialized]
> > net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_fin_timeout' was declared here
> > net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_timeout' may be used uninitialized in this function [-Wuninitialized]
> > net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_timeout' was declared here
> 
> 	There are many __ip_vs_get_timeouts callers but
> just one calls memset(&t, 0, sizeof(t)) before that,
> problem only for ip_vs_genl_set_config and ip_vs_set_timeout.
> 
> 	To be safe, can we move this memset into
> __ip_vs_get_timeouts instead of playing games with defines?:
> 
> 	memset(t, 0, sizeof(*t));
> 
> 	This debug message will be more precise in showing the
> changed values if we replace the __ip_vs_get_timeouts 
> call in ip_vs_genl_set_config with memset(&t, 0, sizeof(t)).
> Then we will see 0 for values that are not changed/supported.

8<-----
ipvs: initialize returned data in do_ip_vs_get_ctl

As reported by a gcc warning, the do_ip_vs_get_ctl does not initalize
all the members of the ip_vs_timeout_user structure it returns if
at least one of the TCP or UDP protocols is disabled for ipvs. 

This makes sure that the data is always initialized, before it is
returned as a response to IPVS_CMD_GET_CONFIG or printed as a
debug message in IPVS_CMD_SET_CONFIG.

Without this patch, building ARM ixp4xx_defconfig results in:

net/netfilter/ipvs/ip_vs_ctl.c: In function 'ip_vs_genl_set_cmd':
net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.udp_timeout' may be used uninitialized in this function [-Wuninitialized]
net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.udp_timeout' was declared here
net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_fin_timeout' may be used uninitialized in this function [-Wuninitialized]
net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_fin_timeout' was declared here
net/netfilter/ipvs/ip_vs_ctl.c:2238:47: warning: 't.tcp_timeout' may be used uninitialized in this function [-Wuninitialized]
net/netfilter/ipvs/ip_vs_ctl.c:3322:28: note: 't.tcp_timeout' was declared here

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2770f85..3995d2e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2590,6 +2588,7 @@ __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 #if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
 	struct ip_vs_proto_data *pd;
 #endif
+	memset(u, 0, sizeof (*u));
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
@@ -2768,7 +2767,6 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
-		memset(&t, 0, sizeof(t));
 		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
