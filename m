From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Mar 9 (net: bpf)
Date: Wed, 09 Mar 2016 12:20:18 -0500 (EST)
Message-ID: <20160309.122018.2278830951828937177.davem@davemloft.net>
References: <20160309163852.4dd159b1@canb.auug.org.au>
	<56E052E4.90504@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <56E052E4.90504@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Wed, 9 Mar 2016 08:44:20 -0800

> on x86_64:
> 
> ../net/core/filter.c: In function 'bpf_skb_get_tunnel_opt':
> ../net/core/filter.c:1824:2: error: implicit declaration of function 'ip_tunnel_info_opts_get' [-Werror=implicit-function-declaration]
>   ip_tunnel_info_opts_get(to, info);
>   ^
> ../net/core/filter.c: In function 'bpf_skb_set_tunnel_opt':
> ../net/core/filter.c:1918:2: error: implicit declaration of function 'ip_tunnel_info_opts_set' [-Werror=implicit-function-declaration]
>   ip_tunnel_info_opts_set(info, from, size);
>   ^
Should have been fixed last night by:

====================
>From e28e87ed474c5a0b378c66fb85efc8e487f4f63f Mon Sep 17 00:00:00 2001
From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 8 Mar 2016 23:36:03 +0100
Subject: [PATCH 1/4] ip_tunnel, bpf: ip_tunnel_info_opts_{get, set} depends on
 CONFIG_INET

Helpers like ip_tunnel_info_opts_{get,set}() are only available if
CONFIG_INET is set, thus add an empty definition into the header for
the !CONFIG_INET case, where already other empty inline helpers are
defined.

This avoids ifdef kludge inside filter.c, but also vxlan and geneve
themself where this facility can only be used with, depend on INET
being set. For the !INET case TUNNEL_OPTIONS_PRESENT would never be
set in flags.

Fixes: 14ca0751c96f ("bpf: support for access to tunnel options")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_tunnels.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index e1395d7..0acd80f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -369,6 +369,17 @@ static inline void ip_tunnel_unneed_metadata(void)
 {
 }
 
+static inline void ip_tunnel_info_opts_get(void *to,
+					   const struct ip_tunnel_info *info)
+{
+}
+
+static inline void ip_tunnel_info_opts_set(struct ip_tunnel_info *info,
+					   const void *from, int len)
+{
+	info->options_len = 0;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
-- 
2.4.1
