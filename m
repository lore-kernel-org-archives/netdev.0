From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Wed, 06 Jun 2007 18:50:23 +0200
Message-ID: <4666E5CF.5010805@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>	<20070605141256.15650.37514.sendpatchset@localhost.localdomain> <m1zm3dt4wr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010003030308050101040801"
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57809 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbXFFQux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 12:50:53 -0400
In-Reply-To: <m1zm3dt4wr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010003030308050101040801
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Eric W. Biederman wrote:
>>+	if (linkinfo[IFLA_INFO_NAME]) {
>>+		nla_strlcpy(name, linkinfo[IFLA_INFO_NAME], sizeof(name));
>>+		ops = rtnl_link_ops_get(name);
> 
> 
> Ugh.  Shouldn't we have the request_module logic here?
> Otherwise it looks like we can skip the validate method and 
> have other weird interactions.


Good catch. The easiest solution seems be to simply replay the
request after successful module load, which also avoids the
device lookup race.

Something like this (untested).


--------------010003030308050101040801
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8d2f817..f2868b0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -930,6 +930,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	int err;
 
+replay:
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
 		return err;
@@ -1012,19 +1013,19 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		if (tb[IFLA_ADDRESS] || tb[IFLA_BROADCAST] || tb[IFLA_MAP])
 			return -EOPNOTSUPP;
 
+		if (!ops) {
 #ifdef CONFIG_KMOD
-		if (!ops && kind[0]) {
-			/* race condition: device may be created while rtnl is
-			 * unlocked, final register_netdevice will catch it.
-			 */
-			__rtnl_unlock();
-			request_module("rtnl-link-%s", kind);
-			rtnl_lock();
-			ops = rtnl_link_ops_get(kind);
-		}
+			if (kind[0]) {
+				__rtnl_unlock();
+				request_module("rtnl-link-%s", kind);
+				rtnl_lock();
+				ops = rtnl_link_ops_get(kind);
+				if (ops)
+					goto replay;
+			}
 #endif
-		if (!ops)
 			return -EOPNOTSUPP;
+		}
 
 		if (!ifname[0])
 			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);

--------------010003030308050101040801--
