From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/16] ipvs: fix ip_vs_set_timeout debug messages
Date: Sat, 6 Oct 2012 09:54:15 +0000
Message-ID: <201210060954.15831.arnd@arndb.de>
References: <1349448930-23976-1-git-send-email-arnd@arndb.de> <201210060645.05225.arnd@arndb.de> <alpine.LFD.2.00.1210061052170.1971@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: Julian Anastasov <ja@ssi.bg>, Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:54461 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab2JFJy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 05:54:56 -0400
In-Reply-To: <alpine.LFD.2.00.1210061052170.1971@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 06 October 2012, Julian Anastasov wrote:
> On Sat, 6 Oct 2012, Arnd Bergmann wrote:
> > > 	Are there any CONFIG_IP_VS_PROTO_xxx options in this
> > > default config? It is a waste of memory if IPVS is compiled
> > > without any protocols.
> > 
> > They all appear to be turned off:
> > 
> > $ grep CONFIG_IP_VS obj-tmp/.config
> > CONFIG_IP_VS=m
> > CONFIG_IP_VS_DEBUG=y
> > CONFIG_IP_VS_TAB_BITS=12
> > # CONFIG_IP_VS_PROTO_TCP is not set
> > # CONFIG_IP_VS_PROTO_UDP is not set
> > # CONFIG_IP_VS_PROTO_AH_ESP is not set
> > # CONFIG_IP_VS_PROTO_ESP is not set
> > # CONFIG_IP_VS_PROTO_AH is not set
> > # CONFIG_IP_VS_PROTO_SCTP is not set
> 
> 	Something should be changed here, may be at least
> TCP/UDP, who knows.

I don't try to read too much into our defconfigs. We have 140 of them
on ARM, and they are mainly useful to give a reasonable build coverage,
but I wouldn't expect them to be actually used on that hardware.

I'll leave it up to Krzysztof to send a patch for this if he wants.

> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -2590,6 +2588,7 @@ __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
> >  #if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
> >  	struct ip_vs_proto_data *pd;
> >  #endif
> 
> 	That is what we want. If you plan another submission
> you can add empty line before this memset and to replace
> the __ip_vs_get_timeouts call in ip_vs_genl_set_config with
> memset but they are cosmetic changes. Or may be Simon will
> take care about the coding style when applying the change.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

I'd prefer Simon to pick up the patch. He should also decide whether he wants
to add it to stable. In theory, this is a small leak of kernel stack data
to user space, but as you say in practice it should not happen because it
only exists for silly configurations that nobody should be using.

AFAICT, removing the call to __ip_vs_get_timeouts in do_ip_vs_get_ctl would
be a semantic change for the case where a user sends a IPVS_CMD_SET_CONFIG
message without without the complete set of attributes inside it. The current
behavior is to leave the timeouts alone, replacing the __ip_vs_get_timeouts
with a memset would zero them. I left this part alone then.

	Arnd

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
Acked-by: Julian Anastasov <ja@ssi.bg>
---
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2770f85..c4ee437 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2591,6 +2589,8 @@ __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 	struct ip_vs_proto_data *pd;
 #endif
 
+	memset(u, 0, sizeof (*u));
+
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 	u->tcp_timeout = pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
@@ -2768,7 +2768,6 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
-		memset(&t, 0, sizeof(t));
 		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
