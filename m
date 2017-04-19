From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount earlier
Date: Tue, 18 Apr 2017 23:23:30 -0700
Message-ID: <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com> <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Bumiller <w.bumiller@proxmox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36216 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760184AbdDSGXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 02:23:51 -0400
Received: by mail-wm0-f51.google.com with SMTP id o81so71601984wmb.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 23:23:51 -0700 (PDT)
In-Reply-To: <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 7:21 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Indeed. Allocate the cookie before init? That way, we fail early
> and dont need to worry about restoring anything.

No, a->act_cookie needs an action pointer first. ;)

> In the case of a replace, do you really want to call tcf_hash_release?
>

Good point. Probably no, we already call it inside ->init().

Something like this...

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 82b1d48d91cc..29ffc348fe2f 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -609,14 +609,12 @@ struct tc_action *tcf_action_init_1(struct net
*net, struct nlattr *nla,

                if (cklen > TC_COOKIE_MAX_SIZE) {
                        err = -EINVAL;
-                       tcf_hash_release(a, bind);
-                       goto err_mod;
+                       goto err_release;
                }

                if (nla_memdup_cookie(a, tb) < 0) {
                        err = -ENOMEM;
-                       tcf_hash_release(a, bind);
-                       goto err_mod;
+                       goto err_release;
                }
        }

@@ -629,6 +627,9 @@ struct tc_action *tcf_action_init_1(struct net
*net, struct nlattr *nla,

        return a;

+err_release:
+       if (err == ACT_P_CREATED)
+               tcf_hash_release(a, bind);
 err_mod:
        module_put(a_o->owner);
 err_out:
