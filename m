From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 27 Jul 2016 08:03:18 +0200
Message-ID: <57984EA6.3040205@oracle.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <20160720121520.GD3775@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070105020505000705060104"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44286 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145AbcG0GDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 02:03:30 -0400
In-Reply-To: <20160720121520.GD3775@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070105020505000705060104
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 07/20/2016 02:15 PM, Steffen Klassert wrote:
> On Wed, Jul 20, 2016 at 10:32:35AM +0200, Vegard Nossum wrote:
>> AFAICT this message is just printed whenever input validation fails.
>> This is a normal failure and we shouldn't be dumping the stack over it.
>>
>> Looks like it was originally a printk that was maybe incorrectly
>> upgraded to a WARN:
>>
>> commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
>> Author: stephen hemminger <shemminger@vyatta.com>
>> Date:   Wed May 12 06:37:06 2010 +0000
>>
>>      xfrm: add severity to printk
>>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
>> ---
>>   net/xfrm/xfrm_user.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
>> index 4fb04ce..0b81bfc 100644
>> --- a/net/xfrm/xfrm_user.c
>> +++ b/net/xfrm/xfrm_user.c
>> @@ -2150,7 +2150,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
>>   	return 0;
>>
>>   bad_policy:
>> -	WARN(1, "BAD policy passed\n");
>> +	printk(KERN_WARNING "xfrm_user: bad policy passed\n");
>
> Why should we print here anything at all? If it is a normal
> configuration error, we should remove the printing.
>

New patch attached. Thanks,


Vegard

--------------070105020505000705060104
Content-Type: text/x-patch;
 name="0001-xfrm-get-rid-of-incorrect-WARN.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-xfrm-get-rid-of-incorrect-WARN.patch"

>From 5bc56901bfea60e8d521f859ce73180796df0e56 Mon Sep 17 00:00:00 2001
From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Tue, 19 Jul 2016 23:41:16 -0700
Subject: [PATCH] xfrm: get rid of incorrect WARN

AFAICT this message is just printed whenever input validation fails.
This is a normal failure and we shouldn't be dumping the stack over it.

Looks like it was originally a printk that was maybe incorrectly
upgraded to a WARN:

commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Wed May 12 06:37:06 2010 +0000

    xfrm: add severity to printk

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/xfrm/xfrm_user.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d516845..2477b24 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2117,7 +2117,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = verify_newpolicy_info(&ua->policy);
 	if (err)
-		goto bad_policy;
+		goto free_state;
 
 	/*   build an XP */
 	xp = xfrm_policy_construct(net, &ua->policy, attrs, &err);
@@ -2149,8 +2149,6 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	return 0;
 
-bad_policy:
-	WARN(1, "BAD policy passed\n");
 free_state:
 	kfree(x);
 nomem:
-- 
1.9.1


--------------070105020505000705060104--
