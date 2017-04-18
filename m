From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount earlier
Date: Tue, 18 Apr 2017 10:03:56 -0700
Message-ID: <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com> <20170418101322.27666-2-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37013 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757586AbdDRRET (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:04:19 -0400
Received: by mail-wm0-f50.google.com with SMTP id u2so2475713wmu.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:04:17 -0700 (PDT)
In-Reply-To: <20170418101322.27666-2-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 3:13 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
> Whether the reference count has to be decremented depends
> on whether the policy was created. If TCA_ACT_COOKIE is
> passed and an error occurs there, the same condition still
> has to be honored.
>
> Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>
> I did not include the Acked-bys here because I've noticed that this
> is still wrong. After reading a bit more and doing more tests with
> different filters I realized that the `name != NULL` case is specific
> to the police filter only. For the other filters this patch here breaks
> refcounting in the error case (I included it for reference only).


police action...That is why I said we may need a TCA_POLICE_COOKIE.

> I'm thinking the first patch should be enough. (I've tested forcing the
> other filters into the error path *without* this patch and couldn't
> produce crashes or reference count problems (while with this patch
> applied it was leaking reference counts on creation (which makes sense
> considering tcf_hash_release is used and the ACT_P_CREATED case will
> keep repeating)). (Whereas without both patches simply looking through
> creating and deleting a policing filter pretty much always resulted in
> crashes with various different backtraces.)
>

The action API's suck here.

The idea is we should rollback everything when cookie setup fails.

Taking another look, it seems the current code (without this patch) is
correct:

1) When ->init() returns ACT_P_CREATED, we should rollback both
act creation and module refcnt, the former is already taken care by
tcf_hash_release(), the latter is at err_mod.

2) When ->init() returns !ACT_P_CREATED, we should rollback the
the modification to the existing action and module refcnt, the former is
impossible with current code (because we don't do copy and update)
so we only do tcf_hash_release(), module refcnt needs to rollback
like normal path.

Ideally, these action API's should handle it nicely, exposing the
module_put()/module_get() is ugly and confusing.
