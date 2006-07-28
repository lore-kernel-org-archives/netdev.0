From: James Morris <jmorris@namei.org>
Subject: [PATCH][SECURITY] secmark: nul-terminate secdata
Date: Fri, 28 Jul 2006 17:00:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:55462 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161302AbWG1VAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 17:00:17 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below fixes a problem in the iptables SECMARK target, where the 
user-supplied 'selctx' string may not be nul-terminated.

>From initial analysis, it seems that the strlen() called from 
selinux_string_to_sid() could run until it arbitrarily finds a zero, and 
possibly cause a kernel oops before then.

The impact of this appears limited because the operation requires 
CAP_NET_ADMIN, which is essentially always root.  Also, the module is not 
yet in wide use.

Please apply.

Note: some other iptables modules which handle strings supplied from 
userspace may require a similar fix (e.g. xt_string looks suspect at first 
glance).

cc'd Chris Wright, as this patch seems like a candidate for the stable 
tree.

Signed-off-by: James Morris <jmorris@namei.org>
Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>

---

diff -purN -X dontdiff linux-2.6.18-rc2-mm1.o/net/netfilter/xt_SECMARK.c linux-2.6.18-rc2-mm1.w/net/netfilter/xt_SECMARK.c
--- linux-2.6.18-rc2-mm1.o/net/netfilter/xt_SECMARK.c	2006-07-28 11:01:46.000000000 -0400
+++ linux-2.6.18-rc2-mm1.w/net/netfilter/xt_SECMARK.c	2006-07-28 11:15:44.000000000 -0400
@@ -57,6 +57,8 @@ static int checkentry_selinux(struct xt_
 {
 	int err;
 	struct xt_secmark_target_selinux_info *sel = &info->u.sel;
+	
+	sel->selctx[SECMARK_SELCTX_MAX - 1] = '\0';
 
 	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
 	if (err) {
