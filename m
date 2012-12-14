From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] xfrm: do not check x->km.state
Date: Fri, 14 Dec 2012 15:02:32 +0800
Message-ID: <CAJFZqHxZDAeZxLyxddtxCB6ucU6hMxH1TtWcMD2TZGRRA52-_g@mail.gmail.com>
References: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
	<20121213101948.GG18940@secunet.com>
	<20121213.141922.2249665409902614569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63971 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218Ab2LNHCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 02:02:34 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so3396376vby.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 23:02:32 -0800 (PST)
In-Reply-To: <20121213.141922.2249665409902614569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/14 David Miller <davem@davemloft.net>:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 13 Dec 2012 11:19:48 +0100
>
>> On Thu, Dec 13, 2012 at 05:06:00PM +0800, roy.qing.li@gmail.com wrote:
>>> From: Li RongQing <roy.qing.li@gmail.com>
>>>
>>> do not check x->km.state, it will be checked by succedent
>>> xfrm_state_check_expire()
>>>
>>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>  ...
>> This would remove the only place where the LINUX_MIB_XFRMINSTATEINVALID
>> statistics counter is incremented. I think it would be better to ensure
>> a valid state before we call xfrm_state_check_expire(). This would make
>> the statistics more accurate and we can remove the x->km.state check
>> from xfrm_state_check_expire().
>
> Agreed.

Thanks.

since xfrm_output_one() calls xfrm_state_check_expire() too, but without
checking (x->km.state != XFRM_STATE_VALID), I think we can not directly
remove the check of km.state from xfrm_state_check_expire(). I have two
option, which one do you think it is better?

1. remove this check in xfrm_state_check_expire, and add a check in
xfrm_output_one

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 95a338c..c245370 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -61,6 +61,12 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
                }

                spin_lock_bh(&x->lock);
+
+                if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+                        XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEINVALID);
+                        goto drop_unlock;
+                }
+
                err = xfrm_state_check_expire(x);
                if (err) {
                        XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEEXPIRED);
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index d0a1af8..e4cd441 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -39,6 +39,7 @@ static const struct snmp_mib xfrm_mib_list[] = {
        SNMP_MIB_ITEM("XfrmOutStateModeError", LINUX_MIB_XFRMOUTSTATEMODEERROR),
        SNMP_MIB_ITEM("XfrmOutStateSeqError", LINUX_MIB_XFRMOUTSTATESEQERROR),
        SNMP_MIB_ITEM("XfrmOutStateExpired", LINUX_MIB_XFRMOUTSTATEEXPIRED),
+       SNMP_MIB_ITEM("XfrmOutStateInvalid", LINUX_MIB_XFRMOUTSTATEINVALID),
        SNMP_MIB_ITEM("XfrmOutPolBlock", LINUX_MIB_XFRMOUTPOLBLOCK),
        SNMP_MIB_ITEM("XfrmOutPolDead", LINUX_MIB_XFRMOUTPOLDEAD),
        SNMP_MIB_ITEM("XfrmOutPolError", LINUX_MIB_XFRMOUTPOLERROR),
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3459692..05db236 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1370,9 +1370,6 @@ int xfrm_state_check_expire(struct xfrm_state *x)
        if (!x->curlft.use_time)
                x->curlft.use_time = get_seconds();

-       if (x->km.state != XFRM_STATE_VALID)
-               return -EINVAL;
-
        if (x->curlft.bytes >= x->lft.hard_byte_limit ||
            x->curlft.packets >= x->lft.hard_packet_limit) {
                x->km.state = XFRM_STATE_EXPIRED;




2. Only remove this check in xfrm6_input.c

--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -109,7 +109,6 @@ int xfrm6_input_addr(struct sk_buff *skb,
xfrm_address_t *daddr,

                if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
-                    likely(x->km.state == XFRM_STATE_VALID) &&
                     !xfrm_state_check_expire(x)) {
                        spin_unlock(&x->lock);
                        if (x->type->input(x, skb) > 0) {
                                /* found a valid state */
