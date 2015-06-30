From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH] rtnetlink: Actually use the policy for the IFLA_VF_INFO
Date: Tue, 30 Jun 2015 16:52:55 -0600
Message-ID: <20150630225255.GA22529@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:41027 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbbF3WxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 18:53:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It turns out the policy was defined but never actually checked,
so lets check it.

Fixes: ebc08a6f47ee ("rtnetlink: Add VF config code to rtnetlink")
Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 net/core/rtnetlink.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

DaveM: This shouldn't be applied until someone with the hardware that
uses this can test it to make sure the policy is actually correct and
matches what iproute does..

I noticed this by inspection when investigating how to properly use
netlink in another area. Compile tested only.

Daniel/Mitch/Jeff: Can you test this?

I suspect the absence of these checks allows user space to cause a
read past the end of a buffer?

I dropped the ifla_vfinfo_policy to match how
IFLA_VF_PORTS/IFLA_VF_PORT is working but I wonder if that should be
changed as well?

Thanks,
Jason

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a2b90e1fc115..7d5dc347bf7c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1258,10 +1258,6 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_SLAVE_DATA]	= { .type = NLA_NESTED },
 };
 
-static const struct nla_policy ifla_vfinfo_policy[IFLA_VF_INFO_MAX+1] = {
-	[IFLA_VF_INFO]		= { .type = NLA_NESTED },
-};
-
 static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_MAC]		= { .len = sizeof(struct ifla_vf_mac) },
 	[IFLA_VF_VLAN]		= { .len = sizeof(struct ifla_vf_vlan) },
@@ -1681,6 +1677,7 @@ static int do_setlink(const struct sk_buff *skb,
 	}
 
 	if (tb[IFLA_VFINFO_LIST]) {
+		struct nlattr *vf_attrs[IFLA_VF_MAX + 1];
 		struct nlattr *attr;
 		int rem;
 		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
@@ -1688,6 +1685,10 @@ static int do_setlink(const struct sk_buff *skb,
 				err = -EINVAL;
 				goto errout;
 			}
+			err = nla_parse_nested(vf_attrs, IFLA_VF_MAX, attr,
+					       ifla_vf_policy);
+			if (err < 0)
+				goto errout;
 			err = do_setvfinfo(dev, attr);
 			if (err < 0)
 				goto errout;
-- 
2.1.4
