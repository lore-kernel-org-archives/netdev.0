From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Tue, 18 Apr 2017 22:21:12 -0400
Message-ID: <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
 <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34513 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758587AbdDSCVP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 22:21:15 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so2079523ioi.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 19:21:14 -0700 (PDT)
In-Reply-To: <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 01:03 PM, Cong Wang wrote:
> On Tue, Apr 18, 2017 at 3:13 AM, Wolfgang Bumiller
> <w.bumiller@proxmox.com> wrote:

> police action...That is why I said we may need a TCA_POLICE_COOKIE.
>

Unless it is very old user space code (which wouldnt know what a
cookie is), dont think there's much use of direct policer access.

>> I'm thinking the first patch should be enough. (I've tested forcing the
>> other filters into the error path *without* this patch and couldn't
>> produce crashes or reference count problems (while with this patch
>> applied it was leaking reference counts on creation (which makes sense
>> considering tcf_hash_release is used and the ACT_P_CREATED case will
>> keep repeating)). (Whereas without both patches simply looking through
>> creating and deleting a policing filter pretty much always resulted in
>> crashes with various different backtraces.)
>>
>
> The action API's suck here.
>
> The idea is we should rollback everything when cookie setup fails.
>
> Taking another look, it seems the current code (without this patch) is
> correct:
>
> 1) When ->init() returns ACT_P_CREATED, we should rollback both
> act creation and module refcnt, the former is already taken care by
> tcf_hash_release(), the latter is at err_mod.
>
> 2) When ->init() returns !ACT_P_CREATED, we should rollback the
> the modification to the existing action and module refcnt, the former is
> impossible with current code (because we don't do copy and update)
> so we only do tcf_hash_release(), module refcnt needs to rollback
> like normal path.
>

Indeed. Allocate the cookie before init? That way, we fail early
and dont need to worry about restoring anything.
In the case of a replace, do you really want to call tcf_hash_release?

> Ideally, these action API's should handle it nicely, exposing the
> module_put()/module_get() is ugly and confusing.
>

lots of room for improvement.

cheers,
jamal
