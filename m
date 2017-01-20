From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix refcnt when GETing of
 action after bind
Date: Thu, 19 Jan 2017 22:20:55 -0800
Message-ID: <CAM_iQpXZqgcSbK2A0_RYmZxmawNgM9RtUsA2Bf0Jf91meu2SWg@mail.gmail.com>
References: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpURppLMupbxCSqmZe866APGrcYficzaOTFNyzheQrrePg@mail.gmail.com> <7a55a129-1e96-80f7-373d-1ff6a95b5269@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33432 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdATGVR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 01:21:17 -0500
Received: by mail-wm0-f67.google.com with SMTP id r144so4255298wme.0
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 22:21:16 -0800 (PST)
In-Reply-To: <7a55a129-1e96-80f7-373d-1ff6a95b5269@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 3:33 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 17-01-17 01:17 PM, Cong Wang wrote:
>>
>> Why this check for RTM_GETACTION? It does not make sense
>> at least for the error case, that is, when tcf_action_get_1() fails
>> in the middle of the loop, all the previous ones should be destroyed
>> no matter it's GETACTION or DELACTION...
>>
>> Also, for the non-error case of GETACTION, they should be
>> destroyed too after dumping to user-space, otherwise there is no
>> way to use them since 'actions' is local to that function.
>>
>> I thought in commit aecc5cefc389 you grab that refcnt on purpose.
>>
>
> I did.
> The issue there (after your original patch) was destroy() would
> decrement the refcount to zero and a GET was essentially translated
> to a DEL. Incrementing the refcount earlier protected against that
> assuming destroy was going to decrement it.
> However, when an action is bound the destroy() doesnt decrement
> the refcnt. So the refcnt keeps going up forever (and therefore
> deleting fails in the future). So we cant use destroy() as is.

Hmm, tcf_action_destroy() should not touch the refcnt at all in this case,
right? Since the refcnt here is not for readers in kernel code but for
user-space. We mix the use of this refcnt, which leads to problems.

Your patch is not correct either for DEL, tcf_action_destroy() is not
needed to call again after tcf_del_notify() fails, right? Probably
it is not needed at all:

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index e10456ef6f..82eed18 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -907,13 +907,8 @@ tca_action_gd(struct net *net, struct nlattr
*nla, struct nlmsghdr *n,
                ret = act_get_notify(net, portid, n, &actions, event);
        else { /* delete */
                ret = tcf_del_notify(net, n, &actions, portid);
-               if (ret)
-                       goto err;
-               return ret;
        }
 err:
-       if (event != RTM_GETACTION)
-               tcf_action_destroy(&actions, 0);
        return ret;
 }
