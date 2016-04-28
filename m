From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Thu, 28 Apr 2016 16:49:19 +1000
Message-ID: <20160428064915.GA29503@penelope.isobedori.kobe.vergenet.net>
References: <cover.1461346798.git.jbenc@redhat.com>
 <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35936 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbcD1Gtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 02:49:36 -0400
Received: by mail-pf0-f180.google.com with SMTP id c189so30134169pfb.3
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 23:49:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 07:44:08PM +0200, Jiri Benc wrote:
> For ipgre interfaces in collect metadata mode, receive also traffic with
> encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
> out correctly. This allows to have mixed Ethernet + L3-only traffic on the
> same lwtunnel interface.
> 
> To keep backwards compatibility and prevent any surprises, gretap interfaces
> have priority in receiving packets with Ethernet headers.

Hi Jiri,

I have had some success wiring up Open vSwitch to use this patch for
transmit. However, I am wondering if something more is needed to allow
differentiation between packets with and without an L2 header present
on receive.

I had luck getting receive working with the following:

From: Simon Horman <simon.horman@netronome.com>
Date: Mon, 18 Apr 2016 17:48:47 +1000
Subject: [PATCH] gre: mark presense of l2 when recieving TEB packets for lwtunnels

There seems to be some way for receivers to differentiate between
packets recieved with and without an l2 header. The approach taken here
is to use a new mode bit in struct ip_tunnel_key.

Another approach might be to store tpi->proto in tunnel metadata,
though that would consume 16 bits somewhere and seems like overkill
at this point.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/ip_tunnels.h | 6 ++++++
 net/ipv4/ip_gre.c        | 3 +++
 2 files changed, 9 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d916b4315903..cdf71ced429e 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -58,6 +58,12 @@ struct ip_tunnel_key {
 /* Flags for ip_tunnel_info mode. */
 #define IP_TUNNEL_INFO_TX	0x01	/* represents tx tunnel parameters */
 #define IP_TUNNEL_INFO_IPV6	0x02	/* key contains IPv6 addresses */
+#define IP_TUNNEL_INFO_L2_PRESENT  0x04	/* Set on receive by tunnels that
+					 * may receive packets both with
+					 * and without an L2 header present
+					 * when a packet is received with
+					 * L2 header present.
+					 */
 
 /* Maximum tunnel options length. */
 #define IP_TUNNEL_OPTS_MAX					\
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0a4af2896a15..1290695fbc95 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -401,6 +401,9 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 			tun_dst = ip_tun_rx_dst(skb, flags, tun_id, 0);
 			if (!tun_dst)
 				return PACKET_REJECT;
+			if (tpi->proto == htons(ETH_P_TEB))
+				tun_dst->u.tun_info.mode |=
+					IP_TUNNEL_INFO_L2_PRESENT;
 		}
 
 		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
-- 
2.7.0.rc3.207.g0ac5344
