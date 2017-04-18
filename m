From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Tue, 18 Apr 2017 09:03:51 -0400
Message-ID: <d5cc1abc-1ea0-5041-504a-4c162eaafceb@mojatatu.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35709 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753254AbdDRNDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 09:03:53 -0400
Received: by mail-io0-f193.google.com with SMTP id d203so30715042iof.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 06:03:53 -0700 (PDT)
In-Reply-To: <20170418101322.27666-2-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 06:13 AM, Wolfgang Bumiller wrote:
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
> I'm thinking the first patch should be enough. (I've tested forcing the
> other filters into the error path *without* this patch and couldn't
> produce crashes or reference count problems (while with this patch
> applied it was leaking reference counts on creation (which makes sense
> considering tcf_hash_release is used and the ACT_P_CREATED case will
> keep repeating)). (Whereas without both patches simply looking through
> creating and deleting a policing filter pretty much always resulted in
> crashes with various different backtraces.)
>

The error path for cookie failure still needs handling.
In retrospect:
I think you should leave the module_put() to the end,
it protects any unloading while the action is being
processed.
It may be worth remembering a_o->init() results and
conditionally calling tcf_hash_release() based on whether
a creation happened or not. I think your original patch had
a similar idea without the extra variable I am suggesting.

cheers,
jamal
