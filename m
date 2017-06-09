From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri, 9 Jun 2017 17:49:50 +0800
Message-ID: <CADvbK_c=ZrFAKeaTvM2PBGbAOO4_38v4S4QB93QChUO0nK2zHw@mail.gmail.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com>
 <20170609083255.GR22049@secunet.com> <CADvbK_dn9QMd8_yRsBMZnjstxjy_L-Pc_UPkyNbyZ=0OORu85A@mail.gmail.com>
 <CAPwn2JR8MUauO44qAeb3tw93PuQHEbO_8Tocs-ZW8Y9ZK+Ln8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33469 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdFIJuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 05:50:02 -0400
Received: by mail-qt0-f194.google.com with SMTP id w1so13872197qtg.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 02:50:01 -0700 (PDT)
In-Reply-To: <CAPwn2JR8MUauO44qAeb3tw93PuQHEbO_8Tocs-ZW8Y9ZK+Ln8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 5:06 PM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> 2017-06-09 16:43 GMT+08:00 Xin Long <lucien.xin@gmail.com>:
>> On Fri, Jun 9, 2017 at 4:32 PM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>>> On Fri, Jun 09, 2017 at 04:23:01PM +0800, Hangbin Liu wrote:
>>>> Hi Steffen,
>>>>
>>>> BTW, If we put the check in xfrm_policy_flush(), we can prevent it earlier.
>>>> But If we put the check in flow_cache_percpu_empty(), we can prevent
>>>> other functions set fc->percpu to NULL, although not much possible : )
>>>>
>>>> So I'm not quite sure whether we should put the check in
>>>> flow_cache_percpu_empty() or in xfrm_policy_flush().
>>>
>>> Can't we just call xfrm_policy_fini() first and then flow_cache_fini()?
>
> Yes, that would be easy fix. I have been thinking about that.  But if we change
>  the order in xfrm_net_exit(), do we also need to change the order in
>  xfrm_net_init()? That would change a lot.
>
> If no need, that would be good.
>
>>>
>> That would be a better fix. seems safe as what flow_cache_fini does
>> is only to free fcp->hash_table and stop timer, I didn't see  it has
>> any dependence on xfrm_policy stuff.
>
> I'm not familiar about this part. So not sure about the influence if we free
> the flow cache after xfrm_policy_fini(). I need do some test first.
>
> I would also be appreciate if you or some one could make sure if it doesn't
> influence anything.
>
another fix is to move xfrm_garbage_collect out of xfrm_policy_flush.
I could only see two places need to call it.
something like:

--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2755,6 +2755,8 @@ static int pfkey_spdflush(struct sock *sk,
struct sk_buff *skb, const struct sad
        int err, err2;

        err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, true);
+       if (!err)
+               xfrm_garbage_collect(net);
        err2 = unicast_flush_resp(sk, hdr);
        if (err || err2) {
                if (err == -ESRCH) /* empty table - old silent behavior */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ed4e52d..89343a3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1007,9 +1007,6 @@ int xfrm_policy_flush(struct net *net, u8 type,
bool task_valid)
 out:
        spin_unlock_bh(&net->xfrm.xfrm_policy_lock);

-       if (cnt)
-               xfrm_garbage_collect(net);
-
        return err;
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 38614df..86116e9 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2027,6 +2027,7 @@ static int xfrm_flush_policy(struct sk_buff
*skb, struct nlmsghdr *nlh,
                        return 0;
                return err;
        }
+       xfrm_garbage_collect(net);
