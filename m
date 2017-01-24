From: David Windsor <dwindsor@gmail.com>
Subject: Re: Reference counting struct inet_peer
Date: Tue, 24 Jan 2017 06:05:26 -0500
Message-ID: <CAEXv5_hyDYMCKX-ZuK1nw=SSTpgKb-DCT3EoTC_L41sQ+RJojQ@mail.gmail.com>
References: <CAEXv5_j1cz1EUPgmAKO5OHxKcoHVLuPPVRs316CWyMpw8UtpRw@mail.gmail.com>
 <alpine.LFD.2.11.1701240853370.1779@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:36151 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdAXLF1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 06:05:27 -0500
Received: by mail-ua0-f195.google.com with SMTP id f2so15998588uaf.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 03:05:27 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1701240853370.1779@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 2:38 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Mon, 23 Jan 2017, David Windsor wrote:
>
>> Hi,
>>
>> I'm working on a patchset that adds overflow protection to kernel
>> reference counters, as part of the KSPP effort.  We're introducing a
>> new type, tentatively called refcount_t, that will ultimately replace
>> atomic_t as the type used for kernel reference counters.  refcount_t
>> has a constrained interface relative to atomic_t and stores reference
>> counts as unsigned integers.
>>
>> While performing an audit of kernel reference counters, we've come
>> upon a few corner cases that we're unable to cleanly migrate to
>> refcount_t.  One of these is the reference counting scheme for struct
>> inet_peer.
>
> ...
>
>> We're also seeing the same thing (freeing shared objects when their
>> refcount becomes -1) in ip_vs.h:
>>
>> http://lxr.free-electrons.com/source/include/net/ip_vs.h#L1424
>>
>> static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
>> {
>>     if (atomic_dec_return(&dest->refcnt) < 0)
>>         kfree(dest);
>> }
>
>         I think, this is easy to fix. The problem is that
> dest_trash currently holds deleted dests (unlinked from RCU lists)
> with refcnt=0. If we change the dest_trash to hold dest
> with refcnt=1, the above atomic_dec_return can be changed to
> atomic_dec_and_test. Change should be small: ip_vs_dest_put
> should be removed from __ip_vs_del_dest(), ip_vs_dest_hold()
> from ip_vs_trash_get_dest() and refcnt check in
> ip_vs_dest_trash_expire() should be updated. Let me know if
> this holds your work, I can provide such patch to fix it.
>

Thanks for looking into this.  Your solution does indeed solve the
problem we're looking to fix.  Essentially, we just need the reference
count to never become < 0.  If you have a patch to fix this, that
would be great.

Thanks,
David Windsor

> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
