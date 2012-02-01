From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/6] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Wed, 1 Feb 2012 15:47:44 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1202011523590.18699@frira.zrqbmnf.qr>
References: <1327269381-20748-1-git-send-email-richard@nod.at> <1327269381-20748-2-git-send-email-richard@nod.at> <CAFLxGvzLvdyyaBvh7LCM2+tTmKobK6n8jTRoH8NXd=MVmN4ocA@mail.gmail.com> <alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
 <CAFLxGvwh5J=CR6OzST7ok6cEuHPWTziDN5TSbGxAiJOpANpAAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	eric.dumazet@gmail.com, Pablo Neira Ayuso <pablo@netfilter.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFLxGvwh5J=CR6OzST7ok6cEuHPWTziDN5TSbGxAiJOpANpAAQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2012-02-01 10:14, richard -rw- weinberger wrote:
>>
>> Do you have the patchset as a retrievable git tree, btw?
>
>Only for kernel stuff:
>git://git.kernel.org/pub/scm/linux/kernel/git/rw/misc.git xt_LOG
>
>If you want it for the user space part too, I can setup something...

That would be welcome.

>>>[PATCH 6/6] iptables: xt_LOG: Add ring buffer support
>>>
>>>in libxt_LOG.c:
>>>+.size = XT_ALIGN(sizeof(struct xt_log_info_v1) + sizeof(void *)),
>>
>> Why the extra void*?
>
>The kernel space part of  xt_log_info_v1 differs from the user space struct,
>it contains an extra pointer to the ring buffer context.
>Iptables must not see this extra pointer because the kernel writes to it.

I don't see that extra pointer (outside xt_log_info_v1) that you talk about.

+struct xt_log_info_v1 {
+       unsigned char level;
+       unsigned char logflags;
+       char prefix[30];
+
+       char ring_name[30];
+       unsigned long ring_size;
+       struct xt_LOG_ring_ctx *rctx;
+};

This is the struct as you defined it. First, you must not use
unsigned long (due to its flexible size, which is an ABI breaker; cf.
"Writing Netfilter Modules" PDF), and the pointer must be tagged for
8-alignment as well for the same reason.

Second, the kernel will reject a ruleset if (kernel) .targetsize != (user)
.size. This is likely to occur, since you essentially have
.targetsize=72 in xt_LOG.c and .size=72+sizeof(void*)
in libxt_LOG.



Check commit 8a252e8941cd50e4390e6fedf280ba1c7ff9ac43 for
trailing whitespace, git log -p shows them.

+       if (par->family == NFPROTO_IPV4)
+               m = ipt_log_packet(NFPROTO_IPV4, par->hooknum, skb, par->in,
+                                  par->out, &li, loginfo->prefix);
+#if IS_ENABLED(CONFIG_IPV6)
+       else if (par->family == NFPROTO_IPV6)
+               m = ip6t_log_packet(NFPROTO_IPV6, par->hooknum, skb, par->in,
+                                   par->out, &li, loginfo->prefix);
+#endif
+       else
+               BUG();

Please avoid BUG. Either do nothing in the 'else' case, or print
a courtesy message with some unkn_log_packet() or
WARN_ON_ONCE(). The same goes for xt_LOG_ring_exit, which I vote
for being reduced to WARN_ON as well. If the condition triggers,
one will have a little memory leak, but at least the machine
still runs.
