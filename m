From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next v5 1/5] netlink: extended ACK reporting
Date: Wed, 12 Apr 2017 15:41:37 +0200
Message-ID: <20170412134137.GE1952@nanopsycho>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-2-johannes@sipsolutions.net>
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
In-Reply-To: <20170412123408.22012-2-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wed, Apr 12, 2017 at 02:34:04PM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org wrote:
>From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
>Add the base infrastructure and UAPI for netlink extended ACK
>reporting. All "manual" calls to netlink_ack() pass NULL for
>now and thus don't get extended ACK reporting.
>
>Big thanks goes to Pablo Neira Ayuso for not only bringing up
>the whole topic at netconf (again) but also coming up with the
>nlattr passing trick and various other ideas.
>
>Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>---

[...]


>diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
>index b2c9c26ea30f..7df88770e029 100644
>--- a/include/uapi/linux/netlink.h
>+++ b/include/uapi/linux/netlink.h
>@@ -69,6 +69,10 @@ struct nlmsghdr {
> #define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
> #define NLM_F_APPEND	0x800	/* Add to end of list		*/
> 
>+/* Flags for ACK message */
>+#define NLM_F_CAPPED	0x100	/* request was capped */

The comment did not help me. What is this supposed to signalize?


>+#define NLM_F_ACK_TLVS	0x200	/* extended ACK TVLs were included */
>+
> /*
>    4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
>    4.4BSD CHANGE	NLM_F_REPLACE
>@@ -101,6 +105,33 @@ struct nlmsghdr {

[...]


>diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
>index 85f2fdc360c2..c8bf5136a72b 100644
>--- a/net/decnet/netfilter/dn_rtmsg.c
>+++ b/net/decnet/netfilter/dn_rtmsg.c
>@@ -96,7 +96,7 @@ static unsigned int dnrmg_hook(void *priv,
> }
> 
> 
>-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
>+#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err), NULL); return; } while (0)

You can easily break this into multiple lines to avoid over-80


> 
> static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
> {

[...]


>-void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
>+void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
>+		 const struct netlink_ext_ack *extack)
> {
> 	struct sk_buff *skb;
> 	struct nlmsghdr *rep;
> 	struct nlmsgerr *errmsg;
> 	size_t payload = sizeof(*errmsg);
>+	size_t tlvlen = 0;
> 	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
>+	unsigned int flags = 0;
> 
> 	/* Error messages get the original request appened, unless the user
>-	 * requests to cap the error message.
>+	 * requests to cap the error message, and get extra error data if
>+	 * requested.
> 	 */
>-	if (!(nlk->flags & NETLINK_F_CAP_ACK) && err)
>-		payload += nlmsg_len(nlh);
>+	if (err) {
>+		if (!(nlk->flags & NETLINK_F_CAP_ACK))
>+			payload += nlmsg_len(nlh);
>+		else
>+			flags |= NLM_F_CAPPED;
>+		if (nlk->flags & NETLINK_F_EXT_ACK && extack) {
>+			if (extack->_msg)
>+				tlvlen += nla_total_size(strlen(extack->_msg) + 1);
>+			if (extack->bad_attr)
>+				tlvlen += nla_total_size(sizeof(u32));
>+		}
>+	} else {
>+		flags |= NLM_F_CAPPED;
>+	}
> 
>-	skb = nlmsg_new(payload, GFP_KERNEL);
>+	if (tlvlen)
>+		flags |= NLM_F_ACK_TLVS;

You can move this check and bitset to the end of
	"if (nlk->flags & NETLINK_F_EXT_ACK && extack) { "
as it is directly related to that.


>+
>+	skb = nlmsg_new(payload + tlvlen, GFP_KERNEL);
> 	if (!skb) {
> 		struct sock *sk;
> 
