From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][DECNET] dn_nl_deladdr() almost always returns no error
Date: Thu, 29 Nov 2007 19:29:20 +0300
Message-ID: <474EE8E0.3050107@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick Caulfield <patrick@tykepenguin.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	linux-decnet-user@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52469 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758808AbXK2Qa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:30:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As far as I see from the err variable initialization
the dn_nl_deladdr() routine was designed to report errors
like "EADDRNOTAVAIL" and probaby "ENODEV".

But the code sets this err to 0 after the first nlmsg_parse
and goes on, returning this 0 in any case.

Is this made deliberately, or the patch below is correct?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 66e266f..3bc82dc 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -651,16 +651,18 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct dn_dev *dn_db;
 	struct ifaddrmsg *ifm;
 	struct dn_ifaddr *ifa, **ifap;
-	int err = -EADDRNOTAVAIL;
+	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
 	if (err < 0)
 		goto errout;
 
+	err = -ENODEV;
 	ifm = nlmsg_data(nlh);
 	if ((dn_db = dn_dev_by_index(ifm->ifa_index)) == NULL)
 		goto errout;
 
+	err = -EADDRNOTAVAIL;
 	for (ifap = &dn_db->ifa_list; (ifa = *ifap); ifap = &ifa->ifa_next) {
 		if (tb[IFA_LOCAL] &&
 		    nla_memcmp(tb[IFA_LOCAL], &ifa->ifa_local, 2))
