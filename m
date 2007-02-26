From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_add_sa_expire return codes
Date: Mon, 26 Feb 2007 14:48:54 -0800 (PST)
Message-ID: <20070226.144854.102122743.davem@davemloft.net>
References: <499d6ed30702261426r107fb555hd621418376f5c61c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: shpedoikal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48055
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161295AbXBZWsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 17:48:55 -0500
In-Reply-To: <499d6ed30702261426r107fb555hd621418376f5c61c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kent Yoder" <shpedoikal@gmail.com>
Date: Mon, 26 Feb 2007 16:26:41 -0600

>   I was browsing through the xfrm_user.c code and noticed that it
> appears that in xfrm_add_sa_expire, the only possible return codes are
> -ENOENT and -EINVAL.  Was this intentional, or is this a bug?

Please use netdev@vger.kernel.org for kernel networking
discussions, thanks.

Indeed, and the tabbing on the first "err = " assignment should
be a clue that some mistake might have been added.

It looks like the code has been like that from day one, I wonder
how Jamal tested this stuff :-)

I'm going to assume the intended logic, and fix it like this.
Jamal?

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2567453..924a2fe 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1557,14 +1557,13 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_usersa_info *p = &ue->state;
 
 	x = xfrm_state_lookup(&p->id.daddr, p->id.spi, p->id.proto, p->family);
-		err = -ENOENT;
 
+	err = -ENOENT;
 	if (x == NULL)
 		return err;
 
-	err = -EINVAL;
-
 	spin_lock_bh(&x->lock);
+	err = -EINVAL;
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
 	km_state_expired(x, ue->hard, current->pid);
@@ -1574,6 +1573,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
 			       AUDIT_MAC_IPSEC_DELSA, 1, NULL, x);
 	}
+	err = 0;
 out:
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
