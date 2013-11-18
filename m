From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/1] fixup! ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR
 to tell kernel to manage temporary addresses
Date: Mon, 18 Nov 2013 11:23:31 +0100
Message-ID: <20131118102331.GB3743@minipsycho.orion>
References: <1384181359-23199-3-git-send-email-jiri@resnulli.us>
 <1384537726-14079-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:59070 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab3KRKXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 05:23:35 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so57780ead.34
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 02:23:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384537726-14079-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okay. I will try incorporate modify into my patch. Thanks.

Fri, Nov 15, 2013 at 06:48:46PM CET, thaller@redhat.com wrote:
>Handle IFA_F_MANAGETEMPADDR flag when modifying existing addresses too.
>
>Signed-off-by: Thomas Haller <thaller@redhat.com>
>---
>Hi,
>
>I'd like to suggest this change, I think it makes it easier for the user space
>application to set this flag of (potentially) existing addresses.
>
>Note, that if the flag gets cleared if the ifa had it set before
>and the temporary addresses will exprire immediatly. This makes sense
>for me.
>
>Or if we don't want this, then the command should fail (EEXIST?) when trying
>to set MANAGETEMPADDR for an existing address that doesn't have the flag already.
>
>Thomas
>
> net/ipv6/addrconf.c | 23 +++++++++++++++++------
> 1 file changed, 17 insertions(+), 6 deletions(-)
>
>diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>index 9e217b8..9e726c8 100644
>--- a/net/ipv6/addrconf.c
>+++ b/net/ipv6/addrconf.c
>@@ -3613,20 +3613,21 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
> 
> 	return inet6_addr_del(net, ifm->ifa_index, pfx, ifm->ifa_prefixlen);
> }
> 
> static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
> 			     u32 prefered_lft, u32 valid_lft)
> {
> 	u32 flags;
> 	clock_t expires;
> 	unsigned long timeout;
>+	int mngtmp;
> 
> 	if (!valid_lft || (prefered_lft > valid_lft))
> 		return -EINVAL;
> 
> 	timeout = addrconf_timeout_fixup(valid_lft, HZ);
> 	if (addrconf_finite_timeout(timeout)) {
> 		expires = jiffies_to_clock_t(timeout * HZ);
> 		valid_lft = timeout;
> 		flags = RTF_EXPIRES;
> 	} else {
>@@ -3636,35 +3637,48 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
> 	}
> 
> 	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
> 	if (addrconf_finite_timeout(timeout)) {
> 		if (timeout == 0)
> 			ifa_flags |= IFA_F_DEPRECATED;
> 		prefered_lft = timeout;
> 	}
> 
> 	spin_lock_bh(&ifp->lock);
>-	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
>+	if (ifa_flags & IFA_F_MANAGETEMPADDR &&
>+	    (ifp->prefix_len != 64 || ifp->flags & IFA_F_TEMPORARY)) {
>+		spin_unlock_bh(&ifp->lock);
>+		return -EEXIST;
>+	}
>+	mngtmp = ifp->flags & IFA_F_MANAGETEMPADDR;
>+	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS |
>+				     IFA_F_MANAGETEMPADDR)) | ifa_flags;
> 	ifp->tstamp = jiffies;
> 	ifp->valid_lft = valid_lft;
> 	ifp->prefered_lft = prefered_lft;
> 
> 	spin_unlock_bh(&ifp->lock);
> 	if (!(ifp->flags&IFA_F_TENTATIVE))
> 		ipv6_ifa_notify(0, ifp);
> 
> 	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
> 			      expires, flags);
> 
>-	if (ifp->flags & IFA_F_MANAGETEMPADDR)
>-		manage_tempaddrs(ifp->idev, ifp, valid_lft, prefered_lft,
>+	if (mngtmp && !(ifa_flags & IFA_F_MANAGETEMPADDR)) {
>+		/* expire the life time of the temporary addresses */
>+		manage_tempaddrs(ifp->idev, ifp, 0, 0,
> 				 false, jiffies);
>+	} else if (ifa_flags & IFA_F_MANAGETEMPADDR) {
>+		/* if we did not yet mngtmp, create temporary addresses */
>+		manage_tempaddrs(ifp->idev, ifp, valid_lft, prefered_lft,
>+				 !mngtmp, jiffies);
>+	}
> 
> 	addrconf_verify(0);
> 
> 	return 0;
> }
> 
> static int
> inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
> {
> 	struct net *net = sock_net(skb->sk);
>@@ -3710,23 +3724,20 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
> 	if (ifa == NULL) {
> 		/*
> 		 * It would be best to check for !NLM_F_CREATE here but
> 		 * userspace alreay relies on not having to provide this.
> 		 */
> 		return inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
> 				      ifm->ifa_prefixlen, ifa_flags,
> 				      preferred_lft, valid_lft);
> 	}
> 
>-	/* We ignore IFA_F_MANAGETEMPADDR for modify. */
>-	ifa_flags &= ~IFA_F_MANAGETEMPADDR;
>-
> 	if (nlh->nlmsg_flags & NLM_F_EXCL ||
> 	    !(nlh->nlmsg_flags & NLM_F_REPLACE))
> 		err = -EEXIST;
> 	else
> 		err = inet6_addr_modify(ifa, ifa_flags, preferred_lft, valid_lft);
> 
> 	in6_ifa_put(ifa);
> 
> 	return err;
> }
>-- 
>1.8.4.1.559.gdb9bdfb
>
