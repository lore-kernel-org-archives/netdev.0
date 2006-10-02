From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH v2 1/1] NetLabel: secid reconciliation support
Date: Mon, 02 Oct 2006 15:39:21 -0400
Message-ID: <45216AE9.8060305@hp.com>
References: <20061002180633.639599000@hp.com>	 <20061002181633.788771000@hp.com> <1159817041.6855.150.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:15490 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S965383AbWJBTjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 15:39:23 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <1159817041.6855.150.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Smalley wrote:
> On Mon, 2006-10-02 at 14:06 -0400, paul.moore@hp.com wrote:
> 
>>plain text document attachment (netlabel-secid_support)
>>This patch provides the missing NetLabel support to the secid reconciliation
>>patchset.
>>
>>Signed-off-by: Paul Moore <paul.moore@hp.com>
>>---
>> security/selinux/hooks.c                    |   67 +++++++++++------
>> security/selinux/include/objsec.h           |    1 
>> security/selinux/include/selinux_netlabel.h |   28 +++----
>> security/selinux/ss/services.c              |  106 ++++++++++------------------
>> 4 files changed, 98 insertions(+), 104 deletions(-)
> 
> 
>>@@ -3725,7 +3723,16 @@ static int selinux_skb_flow_in(struct sk
>> 	if (xfrm_sid)
>> 		skb->secmark = xfrm_sid;
>> 
>>-	/* See if NetLabel can flow in thru the current secmark here */
>>+	err = selinux_netlbl_skb_sid(skb, skb->secmark, &nlbl_sid);
>>+	BUG_ON(err);
> 
> 
> If this selinux_netlbl_skb_sid() call can fail for any reason other than
> a kernel bug, then this needs to goto out instead of using BUG_ON.  For
> example, if the function can fail due to temporary memory pressure
> leading to a failed allocation, then you want to simply drop the packet,
> not panic the kernel.  

That's fine - see the discussion Venkat and I had earlier.  I'll change
it to jump to "out".

>>+
>>+	err = avc_has_perm(nlbl_sid, skb->secmark, SECCLASS_PACKET,
>>+					PACKET__FLOW_IN, NULL);
> 
> 
> This means we end up with two flow_in checks each time, even if only one
> or none of the two labeling mechanisms was used, right?  Given the
> conclusion on the discussion of what it means to use them together (just
> redundant), this seems to be pointless overhead.

I was just trying to match what Venkat had already done.

It's easy enough to distinguish when there is not a NetLabel present and
skip the second check, but I think we need a second access check for
NetLabel when it is present as to skip that check could result in some
wierd behaviors if both forms of external labeling are used.

Yes, we all agree it's redundant to use both at the same time, but I
don't think there is anything preventing users from doing so at the
present time.

>>@@ -3749,6 +3757,12 @@ static int selinux_skb_flow_out(struct s
>> 			struct sk_security_struct *sksec = skb->sk->sk_security;
>> 			skb->secmark = sksec->sid;
>> 		}
>>+
>>+		err = selinux_netlbl_skb_sid(skb, skb->secmark, &nlbl_sid);
>>+		BUG_ON(err);
> 
> 
> Same concern about BUG_ON as above.  Also, I'd have expected this to
> happen at the same point that selinux_skb_xfrm_sid() is called.
>
>>+		if (nlbl_sid)
>>+			skb->secmark = nlbl_sid;
> 
> 
> And then I'd expect this to be moved up prior to the if (xfrm_sid)
> clause, turning that into an else clause, e.g.:
> 	if (nlbl_sid)
> 		skb->secmark = nlbl_sid;
> 	else if (xfrm_sid)
> 		skb->secmark = xfrm_sid;
> 	else if (skb->sk) ...

Easy enough to change.

>>@@ -3913,9 +3928,15 @@ static unsigned int selinux_ip_postroute
>> 						skb->sk->sk_security;
>> 				skb->secmark = sksec->sid;
>> 			}
>>+
>>+			err = selinux_netlbl_skb_sid(skb,
>>+						     skb->secmark,
>>+						     &nlbl_sid);
>>+			BUG_ON(err);
>>+
>>+			if (nlbl_sid)
>>+				skb->secmark = nlbl_sid;
> 
> 
> Similar comments as above.
> 
>> 		}
>>-		err = avc_has_perm(skb->secmark, SECINITSID_UNLABELED,
>>-				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
> 
> 
> Why do you think you can remove this?

I don't, that was a mistake/typo that I missed.  Thanks.

-- 
paul moore
linux security @ hp
