From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 0/5] netlink extended ACK reporting
Date: Mon, 10 Apr 2017 13:38:25 +0200
Message-ID: <1491824305.2455.10.camel@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
         (sfid-20170408_222447_224133_39B19566)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36342 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751615AbdDJLi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 07:38:27 -0400
In-Reply-To: <20170408202434.12018-1-johannes@sipsolutions.net> (sfid-20170408_222447_224133_39B19566)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a simple iw patch that shows the error message string:

--- a/iw.c
+++ b/iw.c
@@ -62,6 +62,10 @@ static int nl80211_init(struct nl80211_state *state)
 
 	nl_socket_set_buffer_size(state->nl_sock, 8192, 8192);
 
+	/* try to set NETLINK_EXT_ACK to 1 (ignore errors) */
+	err = 1;
+	setsockopt(nl_socket_get_fd(state->nl_sock), SOL_NETLINK, 11, &err, sizeof(err));
+
 	state->nl80211_id = genl_ctrl_resolve(state->nl_sock, "nl80211");
 	if (state->nl80211_id < 0) {
 		fprintf(stderr, "nl80211 not found.\n");
@@ -270,11 +274,45 @@ static int phy_lookup(char *name)
 	return atoi(buf);
 }
 
+#ifndef NETLINK_EXT_ACK
+enum nlmsgerr_attrs {
+	NLMSGERR_ATTR_UNUSED,
+	NLMSGERR_ATTR_MSG,
+	NLMSGERR_ATTR_OFFS,
+	NLMSGERR_ATTR_ATTR,
+	NLMSGERR_ATTR_COOKIE,
+
+	NUM_NLMSGERR_ATTRS,
+	NLMSGERR_ATTR_MAX = NUM_NLMSGERR_ATTRS - 1
+};
+#endif
+
 static int error_handler(struct sockaddr_nl *nla, struct nlmsgerr *err,
 			 void *arg)
 {
+	struct nlmsghdr *nlh = (struct nlmsghdr *)err - 1;
+	int len = nlh->nlmsg_len;
+	struct nlattr *attrs;
+	struct nlattr *tb[NUM_NLMSGERR_ATTRS];
 	int *ret = arg;
+	int ack_len = sizeof(*nlh) + sizeof(int) + err->msg.nlmsg_len;
+
 	*ret = err->error;
+
+	if (len <= ack_len)
+		return NL_STOP;
+
+	attrs = (void *)((unsigned char *)nlh + ack_len);
+	len -= ack_len;
+
+	nla_parse(tb, NLMSGERR_ATTR_MAX, attrs, len, NULL);
+	if (tb[NLMSGERR_ATTR_MSG]) {
+		len = strnlen((char *)nla_data(tb[NLMSGERR_ATTR_MSG]),
+			      nla_len(tb[NLMSGERR_ATTR_MSG]));
+		fprintf(stderr, "kernel reports: %*s\n", len,
+			(char *)nla_data(tb[NLMSGERR_ATTR_MSG]));
+	}
+
 	return NL_STOP;
 }
 

johannes
