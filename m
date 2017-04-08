From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sat, 8 Apr 2017 20:34:41 +0200
Message-ID: <20170408183440.GA1900@nanopsycho>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
 <20170408174900.12820-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35984 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752196AbdDHSeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 14:34:44 -0400
Received: by mail-it0-f66.google.com with SMTP id a140so1816605ita.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 11:34:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170408174900.12820-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 08, 2017 at 07:48:56PM CEST, johannes@sipsolutions.net wrote:
>From: Johannes Berg <johannes.berg@intel.com>
>
>Add the base infrastructure and UAPI for netlink
>extended ACK reporting. All "manual" calls to
>netlink_ack() pass NULL for now and thus don't
>get extended ACK reporting.

Why so narrow? :)


>
>Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>---

[...]


>diff --git a/include/linux/netlink.h b/include/linux/netlink.h
>index da14ab61f363..47562e940e9c 100644
>--- a/include/linux/netlink.h
>+++ b/include/linux/netlink.h
>@@ -62,11 +62,41 @@ netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg)
> 	return __netlink_kernel_create(net, unit, THIS_MODULE, cfg);
> }
> 
>+/**
>+ * struct netlink_ext_ack - netlink extended ACK report struct
>+ * @_msg: message string to report - don't access directly, use
>+ *	%NL_SET_ERR_MSG
>+ * @bad_attr: attribute with error
>+ * @missing_attr: number of missing attr (or 0)
>+ * @cookie: cookie data to return to userspace (for success)
>+ * @cookie_len: actual cookie data length
>+ */
>+struct netlink_ext_ack {
>+	const char *_msg;
>+	const struct nlattr *bad_attr;
>+	u16 missing_attr;
>+	u8 cookie[NETLINK_MAX_COOKIE_LEN];
>+	u8 cookie_len;
>+};
>+
>+/* Always use this macro, this allows later putting the
>+ * message into a separate section or such for things
>+ * like translation or listing all possible messages.
>+ * Currently string formatting is not supported (due
>+ * to the lack of an output buffer.)

Please use 80 cols.

[...]


>@@ -2267,21 +2284,37 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
> }
> EXPORT_SYMBOL(__netlink_dump_start);
> 
>-void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
>+void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
>+		 const struct netlink_ext_ack *extack)
> {
> 	struct sk_buff *skb;
> 	struct nlmsghdr *rep;
> 	struct nlmsgerr *errmsg;
> 	size_t payload = sizeof(*errmsg);
>+	size_t acksize = sizeof(*errmsg);
> 	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
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
>+		acksize = payload;
>+		if (nlk->flags & NETLINK_F_EXT_ACK) {
>+			if (extack && extack->_msg)
>+				acksize +=
>+					nla_total_size(strlen(extack->_msg) + 1);
>+			if (extack && extack->bad_attr)
>+				acksize += nla_total_size(sizeof(u32));
>+			if (extack &&
>+			    (extack->missing_attr || extack->bad_attr))

Attr could be 0, right? I know that on the most of the places 0 is
UNSPEC, but I'm pretty sure not everywhere.


>+				acksize += nla_total_size(sizeof(u16));
>+		}
>+	}
> 
>-	skb = nlmsg_new(payload, GFP_KERNEL);
>+	skb = nlmsg_new(acksize, GFP_KERNEL);
> 	if (!skb) {
> 		struct sock *sk;
> 

[...]

Look very good. Thanks for taking care of this!
