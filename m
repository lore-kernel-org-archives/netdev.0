From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: kernel stack  trace using conntrack
Date: Fri, 19 Feb 2010 03:18:04 +0100
Message-ID: <4B7DF4DC.4000502@netfilter.org>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>	 <1266313889.3045.1.camel@edumazet-laptop>	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>	 <1266318928.3045.38.camel@edumazet-laptop>  <4B7A9E95.103@netfilter.org> <1266327917.3045.55.camel@edumazet-laptop> <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC905D@FRSPX100.fr01.awl.atosorigin.net> <4B7D17CE.6010805@trash.net> <4B7D1E32.6000705@netfilter.org> <4B7D215A.6060400@trash.net> <4B7D3022.9030405@netfilter.org> <4B7D306F.9060808@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070806040107040000020307"
Cc: Ramblewski David <David.Ramblewski@atosorigin.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37168 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590Ab0BSCSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 21:18:20 -0500
In-Reply-To: <4B7D306F.9060808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070806040107040000020307
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>>>> Pablo, please let me know whether you want me to apply this.
>>>> ctnetlink_change_helper() also calls nf_ct_ext_add() for conntracks that
>>>> are confirmed (in case of a helper update for an existing conntrack).
>>>> That would also trigger the assertion. If we want to support helper
>>>> assignation via ctnetlink for existing conntracks, we will need to add
>>>> locking to the conntrack extension infrastructure to avoid races.
>>>>
>>>> I don't see a clear solution for this yet.
>>> I see, this is indeed a problem. Since the helper is known at the
>>> first event, we could restrict this to only allow manual assignment
>>> for newly created conntracks. Most helpers probably can't properly
>>> cope with connections not seen from the beginning anyways.
>> Indeed, changing the helper in the middle of the road doesn't make too
>> much sense to me either. I can send you a patch for this along today,
>> I'll find some spare time to do it.
> 
> Great, thanks Pablo.

I have slightly tested the following patch here. I think it should fix
the problem.

We can revisit ctnetlink_change_helper() later, I think there's some
code there that can be refactorized.

Let me know if you're OK with it.

--------------070806040107040000020307
Content-Type: text/x-patch;
 name="fix-helper.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-helper.patch"

netfilter: ctnetlink: fix creation of conntrack with helpers

This patch fixes a bug that triggers an assertion if you create
a conntrack entry with a helper and netfilter debugging is enabled.
Basically, we hit the assertion because the confirmation flag is
set before the conntrack extensions are added. To fix this, we
move the extension addition before the aforementioned flag is
set.

This patch also removes the possibility of setting a helper for
existing conntracks. This operation would also trigger the
assertion since we are not allowed to add new extensions for
existing conntracks. We know noone that could benefit from
this operation sanely.

Thanks to Eric Dumazet for initial posting a preliminary patch
to address this issue.

Reported-by: David Ramblewski <David.Ramblewski@atosorigin.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 8b05f36..2b2af63 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1077,9 +1077,8 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 		/* need to zero data of old helper */
 		memset(&help->help, 0, sizeof(help->help));
 	} else {
-		help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
-		if (help == NULL)
-			return -ENOMEM;
+		/* we cannot set a helper for an existing conntrack */
+		return -EOPNOTSUPP;
 	}
 
 	rcu_assign_pointer(help->helper, helper);
@@ -1263,7 +1262,6 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	ct->timeout.expires = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
 	ct->timeout.expires = jiffies + ct->timeout.expires * HZ;
-	ct->status |= IPS_CONFIRMED;
 
 	rcu_read_lock();
  	if (cda[CTA_HELP]) {
@@ -1314,14 +1312,19 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 			goto err2;
 	}
 
-	if (cda[CTA_STATUS]) {
-		err = ctnetlink_change_status(ct, cda);
+	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
+		err = ctnetlink_change_nat(ct, cda);
 		if (err < 0)
 			goto err2;
 	}
 
-	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
-		err = ctnetlink_change_nat(ct, cda);
+	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
+	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
+	/* we must add conntrack extensions before confirmation. */
+	ct->status |= IPS_CONFIRMED;
+
+	if (cda[CTA_STATUS]) {
+		err = ctnetlink_change_status(ct, cda);
 		if (err < 0)
 			goto err2;
 	}
@@ -1340,9 +1343,6 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 			goto err2;
 	}
 
-	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
-	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
-
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
 		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));

--------------070806040107040000020307--
