From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [patch]net/xfrm:fix crash in ipsec audit logging
Date: Tue, 9 Jan 2007 15:53:08 -0600
Message-ID: <200701092153.l09Lr8vr026631@faith.austin.ibm.com>
Cc: davem@davemloft.net, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59867 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437AbXAIWHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 17:07:43 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l09M7ehW026941
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 17:07:40 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l09M7eeM523874
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 15:07:40 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l09M7dwX014665
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 15:07:40 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-12-26 at 13:37 -0500, jamal wrote:
>On Tue, 2006-26-12 at 18:56 +0100, Ingo Molnar wrote:
> 
> 
> > +	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
> > +		       AUDIT_MAC_IPSEC_DELSPD, delete, xp, NULL);
> > +
> >  	if (!delete) {
> >  		struct sk_buff *resp_skb;
> 
> 
> You could move the call into the else from above if (!delete) maybe?
> Otherwise you have to add back the "if (delete)" check since that
> function could be used to either retrieve (which is not subject to an
> audit) or delete an xp.
> 
> cheers,
> jamal
>  

My apologies as I am just reading my email.

Yes, I think in the else part of the "if (!delete)".

I also added a check to xfrm_audit_log() such that if both xfrm
and policy are NULL, we return. There isn't anything to audit
since we are only auditing creation and deletion of xfrm and 
policy.

Ingo, could you try this patch and let me know if everything works ok
for you. I have built and test in my environment, but not tested as
you are using it.  

Regards,
Joy

Signed-off-by: Joy Latten <latten@austin.ibm.com>

--------------------------------------------------------------------------

diff -urpN linux-2.6.19.orig/net/xfrm/xfrm_policy.c linux-2.6.19/net/xfrm/xfrm_policy.c
--- linux-2.6.19.orig/net/xfrm/xfrm_policy.c	2007-01-02 14:24:14.000000000 -0600
+++ linux-2.6.19/net/xfrm/xfrm_policy.c	2007-01-02 14:28:24.000000000 -0600
@@ -2003,6 +2003,9 @@ void xfrm_audit_log(uid_t auid, u32 sid,
 	if (audit_enabled == 0)
 		return;
 
+	if ((x == NULL) && (xp == NULL))
+		return;
+
 	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
 	if (audit_buf == NULL)
 	return;
diff -urpN linux-2.6.19.orig/net/xfrm/xfrm_user.c linux-2.6.19/net/xfrm/xfrm_user.c
--- linux-2.6.19.orig/net/xfrm/xfrm_user.c	2007-01-02 14:24:14.000000000 -0600
+++ linux-2.6.19/net/xfrm/xfrm_user.c	2007-01-02 14:28:14.000000000 -0600
@@ -1268,10 +1268,6 @@ static int xfrm_get_policy(struct sk_buf
 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, delete);
 		security_xfrm_policy_free(&tmp);
 	}
-	if (delete)
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSPD, (xp) ? 1 : 0, xp, NULL);
-
 	if (xp == NULL)
 		return -ENOENT;
 
@@ -1289,6 +1285,10 @@ static int xfrm_get_policy(struct sk_buf
 	} else {
 		if ((err = security_xfrm_policy_delete(xp)) != 0)
 			goto out;
+
+		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
+			       AUDIT_MAC_IPSEC_DELSPD, (xp) ? 1 : 0, xp, NULL);
+
 		c.data.byid = p->index;
 		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;

. 
