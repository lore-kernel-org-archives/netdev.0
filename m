From: Lubomir Rintel <lkundrak-NGH9Lh4a5iE@public.gmane.org>
Subject: Re: [PATCH] ipv6: expose RFC4191 route preference via rtnetlink
Date: Tue, 10 Mar 2015 16:56:53 +0100
Message-ID: <1426003013.3963.33.camel@v3.sk>
References: <1425376912-31983-1-git-send-email-lkundrak@v3.sk>
	 <20150303151715.GA2020@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150303151715.GA2020-6KJVSR23iU5sFDB2n11ItA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 16:17 +0100, Jiri Pirko wrote:
> Tue, Mar 03, 2015 at 11:01:52AM CET, lkundrak-NGH9Lh4a5iE@public.gmane.org wrote:
> >This makes it possible to retain the route preference when RAs are handled in
> >userspace.
> >
> >Signed-off-by: Lubomir Rintel <lkundrak-NGH9Lh4a5iE@public.gmane.org>
> >---
> > include/uapi/linux/rtnetlink.h |  1 +
> > net/ipv6/route.c               | 16 +++++++++++++++-
> > 2 files changed, 16 insertions(+), 1 deletion(-)
> >
> >diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> >index 5cc5d66..0671524 100644
> >--- a/include/uapi/linux/rtnetlink.h
> >+++ b/include/uapi/linux/rtnetlink.h
> >@@ -303,6 +303,7 @@ enum rtattr_type_t {
> > 	RTA_TABLE,
> > 	RTA_MARK,
> > 	RTA_MFC_STATS,
> >+	RTA_PREF,
> > 	__RTA_MAX
> > };
> > 
> >diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> >index 47b5109..08f689e 100644
> >--- a/net/ipv6/route.c
> >+++ b/net/ipv6/route.c
> >@@ -2401,6 +2401,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
> > 	[RTA_PRIORITY]          = { .type = NLA_U32 },
> > 	[RTA_METRICS]           = { .type = NLA_NESTED },
> > 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
> >+	[RTA_PREF]              = { .type = NLA_U8 },
> > };
> > 
> > static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
> >@@ -2408,6 +2409,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
> > {
> > 	struct rtmsg *rtm;
> > 	struct nlattr *tb[RTA_MAX+1];
> >+	unsigned int pref;
> > 	int err;
> > 
> > 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
> >@@ -2483,6 +2485,14 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
> > 		cfg->fc_mp_len = nla_len(tb[RTA_MULTIPATH]);
> > 	}
> > 
> >+	if (tb[RTA_PREF]) {
> >+		pref = nla_get_u8(tb[RTA_PREF]);
> >+		if (pref == ICMPV6_ROUTER_PREF_LOW ||
> >+		    pref == ICMPV6_ROUTER_PREF_MEDIUM ||
> >+		    pref == ICMPV6_ROUTER_PREF_HIGH)
> >+			cfg->fc_flags |= RTF_PREF(pref);
> 
> Don't we want to do "goto errout;" in case pref is invalid ?

I'm not sure. If RFC 4191 suggests that the invalid value ought to be
ignored (treated as medium). It could be done in the userspace or the
userspace could just relay whatever it got in the NDP message to the
kernel.

What is your opinion on this?

Thank you,
Lubo
