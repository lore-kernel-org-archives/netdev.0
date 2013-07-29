From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE
Date: Mon, 29 Jul 2013 12:30:04 +0200
Message-ID: <1375093804-7534-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56780 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab3G2KaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 06:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, it is not possible to use neither NLM_F_EXCL nor
NLM_F_REPLACE from genetlink. This is due to this checking in
genl_family_rcv_msg:

	if (nlh->nlmsg_flags & NLM_F_DUMP)

NLM_F_DUMP is NLM_F_MATCH|NLM_F_ROOT. Thus, if NLM_F_EXCL or
NLM_F_REPLACE flag is set, genetlink believes that you're
requesting a dump and it calls the .dumpit callback.

The solution that I propose is to refine this checking to
make it stricter:

	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP)

And given the combination NLM_F_REPLACE and NLM_F_EXCL does
not make sense to me, it removes the ambiguity.

There was a patch that tried to fix this some time ago (0ab03c2
netlink: test for all flags of the NLM_F_DUMP composite) but it
tried to resolve this ambiguity in *all* existing netlink subsystems,
not only genetlink. That patch was reverted since it broke iproute2,
which is using NLM_F_ROOT to request the dump of the routing cache.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
There is still one possibility of breaking user-space: if
the application only sets NLM_F_MATCH or NLM_F_ROOT to request
a dump, the dump operation will not work anymore.

To address this, I have elaborated a list of all existing
in-tree subsystems that provide genetlink interfaces that
could be affected by git grepping for the "\.dumpit" keyword.
Then, I have searched for the user-space code of those
genetlink interfaces, to make sure they are using NLM_F_DUMP,
this is the result:

* nl80211: the iw utility uses NLM_F_DUMP.
* openvswitch: version 1.10.0, lib/netlink-socket.c uses
  NLM_F_DUMP.
* nfc: I could just find a nfc-example.git tree:
  http://code.openbossa.org/?p=nfc/nfc-example.git;a=summary
  which looks good.
* netlabel: netlabel_tools-0.20 looks good.
* IPVS: ipvsadm from Simon Horman's git tree looks good.
* l2tp: iproute2 code looks good as well.
* drdb: drbd-8.4 looks fine, drbd-8.3 does not seem to use
  the genetlink interface.

So it seems recent code always stick to NLM_F_DUMP, which is
good.

 net/netlink/genetlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2fd6dbe..145d145 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -571,7 +571,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	    !capable(CAP_NET_ADMIN))
 		return -EPERM;

-	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ops->dumpit,
 			.done = ops->done,
--
1.7.10.4
