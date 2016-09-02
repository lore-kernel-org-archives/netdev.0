From: Rainer Weikusat <rweikusat@cyberadapt.com>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 16:18:04 +0100
Message-ID: <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com>
References: <CA+55aFy0cQq569m=0umnqZe6HJp8eQX2ed-yi=Fmntuhd2AM=Q@mail.gmail.com>
        <87h99zo4d8.fsf@doppelsaurus.mobileactivedefense.com>
        <CA+55aFwcPK_wXS8SE5wPitCXUewZ1+OGqVrWxvvU8tVDuCeHWA@mail.gmail.com>
        <CA+55aFxGW8_DpYa6rZAq0s7zzFCB58U=7Kgy1T+7cY2=TasGrw@mail.gmail.com>
        <871t13o1n1.fsf@doppelsaurus.mobileactivedefense.com>
        <CA+55aFzbCDwOTbHiawpY2xSaR_EBkTDbYeJV3CH09OLLtPW3nw@mail.gmail.com>
        <6f7d587b-3933-7c02-a804-db1732ced1cf@stressinduktion.org>
        <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com>
        <20160901204746.GR2356@ZenIV.linux.org.uk>
        <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
        <20160901210142.GS2356@ZenIV.linux.org.uk>
        <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
        <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Al Viro <viro@zeniv.linux.org.uk>, CAI Qian <caiqian@redhat.com>,
        "Miklos Szeredi" <miklos@szeredi.hu>,
        Rainer Weikusat <rweikusat@cyberadapt.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0076.outbound.protection.outlook.com ([104.47.40.76]:64651
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932464AbcIBQvV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 12:51:21 -0400
In-Reply-To: <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
        (Linus Torvalds's message of "Thu, 1 Sep 2016 15:04:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:
> On Thu, Sep 1, 2016 at 2:43 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>> On Thu, Sep 1, 2016 at 2:01 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>>
>>> Outside as in "all fs activity in bind happens under it".  Along with
>>> assignment to ->u.addr, etc.  IOW, make it the outermost lock there.
>>
>> Hah, yes. I misunderstood you.
>>
>> Yes. In fact that fixes the problem I mentioned, rather than introducing it.
>
> So the easiest approach would seem to be to revert commit c845acb324aa
> ("af_unix: Fix splice-bind deadlock"), and then apply the lock split.
>
> Like the attached two patches.
>
> This is still *entirely* untested.

As far as I can tell, this should work as I can't currently imagine why
a fs operation might end up binding a unix socket despite the idea to
make af_unix.c yet more complicated in order to work around irregular
behaviour of (as far as I can tell) a single filesystem (for which
kern_path_create doesn't really mean kern_path_create and it has to work
around that once it gets control) goes against all instincts I have in
this area. If filesystems need to do arbitrary stuff when
__sb_start_write is called for 'their' superblock, they should be able
to do so directly.

At present, this is a theoretic concern as I can't (due to other work
committments) put any non-cursory work into this before Sunday. There
may also be other reasons why this idea is impractical or even
unworkable.
