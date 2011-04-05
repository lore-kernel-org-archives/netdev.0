From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH] netfilter: Fix build failure when ipv6 but xt_tproxy
 is built in
Date: Tue, 05 Apr 2011 16:43:46 +0200
Message-ID: <1302014626.67568.1.camel@nienna.balabit>
References: <1301451199.14261.327.camel@gandalf.stny.rr.com>
	 <20110329.223536.245392030.davem@davemloft.net>
	 <4D99CDA0.3030305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D99CDA0.3030305@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 2011-04-04 at 15:54 +0200, Patrick McHardy wrote:
> >> net/built-in.o: In function `tproxy_tg6_v1':
> >> /home/rostedt/work/autotest/nobackup/linux-test.git/net/netfilter/xt_TPROXY.c:288: undefined reference to `ipv6_find_hdr'
> >>
> >> This happened because the xt_TPROXY code was compiled into the kernel
> >> proper, but the ipv6 netfilter was compiled as a module. The fix is to
> >> only enter the code that calls ipv6_find_hdr if ipv6 netfilter is
> >> compiled into the kernel, or if it is a module, so is the xt_TPROXY
> >> code.
> 
> I don't think this is a good fix for the problem since it may lead to
> the confusing situation that both TPROXY and ip6tables are enabled,
> but TPROXY has no IPv6 support.
> 
> I think we should solve this by either adding a Kconfig dependency
> on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n) or using ipv6_skip_exthdr()
> instead of ipv6_find_hdr().
> 
> Krisztian, what do you think?

I'd definitely prefer using ipv6_skip_exthdr() instead of playing
various tricks with the config preprocessor macros.

What about something like this?

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index dcfd57e..1ef0e56 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -283,10 +283,10 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
        const struct in6_addr *laddr;
        __be16 lport;
        int thoff;
-       int tproto;
+       u8 tproto = iph->nexthdr;
 
-       tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
-       if (tproto < 0) {
+       thoff = ipv6_skip_exthdr(skb, sizeof(*iph), &tproto);
+       if (thoff < 0) {
                pr_debug("unable to find transport header in IPv6 packet, dropping\n");
                return NF_DROP;
        }

--
KOVACS Krisztian
