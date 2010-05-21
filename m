From: David Howells <dhowells@redhat.com>
Subject: [PATCH] rtnetlink: Fix error handling in do_setlink()
Date: Fri, 21 May 2010 13:25:27 +0100
Message-ID: <20100521122527.20442.77793.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139Ab0EUMZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 08:25:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c02db8c6290bb992442fec1407643c94cc414375:

	Author:  Chris Wright <chrisw@sous-sol.org>
	Date:    Sun May 16 01:05:45 2010 -0700
	Subject: rtnetlink: make SR-IOV VF interface symmetric

adds broken error handling to do_setlink() in net/core/rtnetlink.c.  The
problem is the following chunk of code:

	if (tb[IFLA_VFINFO_LIST]) {
		struct nlattr *attr;
		int rem;
		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
			if (nla_type(attr) != IFLA_VF_INFO)
  ---->				goto errout;
			err = do_setvfinfo(dev, attr);
			if (err < 0)
				goto errout;
			modified = 1;
		}
	}

which can get to errout without setting err, resulting in the following error:

net/core/rtnetlink.c: In function 'do_setlink':
net/core/rtnetlink.c:904: warning: 'err' may be used uninitialized in this function

Change the code to return -EINVAL in this case.  Note that this might not be
the appropriate error though.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Chris Wright <chrisw@sous-sol.org>
cc: David S. Miller <davem@davemloft.net>
---

 net/core/rtnetlink.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 31e85d3..56b4157 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1030,8 +1030,10 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		struct nlattr *attr;
 		int rem;
 		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
-			if (nla_type(attr) != IFLA_VF_INFO)
+			if (nla_type(attr) != IFLA_VF_INFO) {
+				err = -EINVAL;
 				goto errout;
+			}
 			err = do_setvfinfo(dev, attr);
 			if (err < 0)
 				goto errout;

