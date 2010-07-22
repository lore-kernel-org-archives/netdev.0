From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH nf-next-2.6] netfilter: add xt_cpu match
Date: Thu, 22 Jul 2010 16:19:13 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>
References: <1279807385.2467.67.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279807385.2467.67.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-07-22 16:03, Eric Dumazet wrote:

>This match is a bit strange, being packet content agnostic...
>+/*
>+ * Yes, packet content is not interesting for us, we only take care
>+ * of cpu handling this packet
>+ */

That is not so strange after all, we have many packet agnostic matches: 
xt_time, xt_condition, xt_IDLETIMER, xt_iface.
So this little comment looks a bit redundant.

Or it seems that academia can't come up with enough new protocols in time that
we have to resort to do -m coffeemaker :)

>@@ -0,0 +1,8 @@
>+#ifndef _XT_CPU_H
>+#define _XT_CPU_H
>+
>+struct xt_cpu_info {
>+	unsigned int	cpu;
>+	int		invert;
>+};
>+#endif /*_XT_MAC_H*/

Please take a read in "Writing Netfilter Modules" e-book :-)
It will tell you that types other than fixed ones are a no-no.

>diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
>index e28420a..0fe7efd 100644
>--- a/net/netfilter/Makefile
>+++ b/net/netfilter/Makefile
>@@ -79,6 +79,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
>+obj-$(CONFIG_NETFILTER_XT_MATCH_CPU) += xt_cpu.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o

Try to keep it alphabetic (KConfig too).

>+ *
>+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 0 -j REDIRECT --to-port 8080
>+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 1 -j REDIRECT --to-port 8081
>+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 2 -j REDIRECT --to-port 8082
>+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 3 -j REDIRECT --to-port 8083
>+ *
>+ */

Well the commands you already have presented in the commit log, and the 
most efficient place for these is actually the manpage.

>+static bool cpu_mt(const struct sk_buff *skb, struct xt_action_param *par)
>+{
>+	const struct xt_cpu_info *info = par->matchinfo;
>+	bool ret;
>+
>+	ret = info->cpu == smp_processor_id();
>+	ret ^= info->invert;
>+	return ret;
>+}

Looks simple enough that it could do it in a single line,

	return (info->cpu == smp_processor_id()) ^ !!info->invert;
