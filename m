From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 09:19:00 +0200
Message-ID: <20170411071900.GC1976@nanopsycho>
References: <20170411065700.2623-1-johannes@sipsolutions.net>
 <20170411065700.2623-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170411065700.2623-2-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tue, Apr 11, 2017 at 08:56:56AM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org wrote:
>From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
>Add the base infrastructure and UAPI for netlink
>extended ACK reporting. All "manual" calls to
>netlink_ack() pass NULL for now and thus don't
>get extended ACK reporting.
>
>Big thanks goes to Pablo Neira Ayuso for not only
>bringing up the whole topic at netconf (again) but
>also coming up with the nlattr passing trick and
>various other ideads.
>
>Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>---

[...]


>+/**
>+ * enum nlmsgerr_attrs - nlmsgerr attributes
>+ * @NLMSGERR_ATTR_UNUSED: unused
>+ * @NLMSGERR_ATTR_MSG: error message string (string)
>+ * @NLMSGERR_ATTR_OFFS: offset of the invalid attribute in the original
>+ *	 message, counting from the beginning of the header (u32)
>+ * @NUM_NLMSGERR_ATTRS: number of attributes
>+ * @NLMSGERR_ATTR_MAX: highest attribute number
>+ */
>+enum nlmsgerr_attrs {
>+	NLMSGERR_ATTR_UNUSED,
>+	NLMSGERR_ATTR_MSG,
>+	NLMSGERR_ATTR_OFFS,
>+
>+	NUM_NLMSGERR_ATTRS,

According to the rest of the uapi, this should be rather named:
	__NLMSGERR_ATTR_MAX


>+	NLMSGERR_ATTR_MAX = NUM_NLMSGERR_ATTRS - 1
> };
> 
> #define NETLINK_ADD_MEMBERSHIP		1
>@@ -115,6 +146,7 @@ struct nlmsgerr {
> #define NETLINK_LISTEN_ALL_NSID		8
> #define NETLINK_LIST_MEMBERSHIPS	9
> #define NETLINK_CAP_ACK			10
>+#define NETLINK_EXT_ACK			11
> 
> struct nl_pktinfo {
> 	__u32	group;
>diff --git a/kernel/audit.c b/kernel/audit.c
>index 2f4964cfde0b..d54bf5932374 100644
>--- a/kernel/audit.c
>+++ b/kernel/audit.c
>@@ -1402,7 +1402,7 @@ static void audit_receive_skb(struct sk_buff *skb)
> 		err = audit_receive_msg(skb, nlh);
> 		/* if err or if this message says it wants a response */
> 		if (err || (nlh->nlmsg_flags & NLM_F_ACK))
>-			netlink_ack(skb, nlh, err);
>+			netlink_ack(skb, nlh, err, NULL);

Wouldn't it make sense to leave netlink_ack as is and add
netlink_ack_ext for those who need to pass non-null?


> 
> 		nlh = nlmsg_next(nlh, &len);
> 	}
