From: Rainer Weikusat <rweikusat@cyberadapt.com>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 18:40:59 +0100
Message-ID: <8737lib3o4.fsf@doppelsaurus.mobileactivedefense.com>
References: <6f7d587b-3933-7c02-a804-db1732ced1cf@stressinduktion.org>
        <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com>
        <20160901204746.GR2356@ZenIV.linux.org.uk>
        <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
        <20160901210142.GS2356@ZenIV.linux.org.uk>
        <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
        <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
        <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com>
        <20160902160026.GT2356@ZenIV.linux.org.uk>
        <87d1kme10a.fsf@doppelsaurus.mobileactivedefense.com>
        <20160902170256.GU2356@ZenIV.linux.org.uk>
        <CA+55aFz-TaU=C47Rna4b_pibKPfabXWtt88gaqWkUdcN9ay9nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Rainer Weikusat <rweikusat@cyberadapt.com>,
        CAI Qian <caiqian@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0067.outbound.protection.outlook.com ([104.47.41.67]:58336
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752365AbcIBRzY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 13:55:24 -0400
In-Reply-To: <CA+55aFz-TaU=C47Rna4b_pibKPfabXWtt88gaqWkUdcN9ay9nQ@mail.gmail.com>
        (Linus Torvalds's message of "Fri, 2 Sep 2016 10:12:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:
> On Fri, Sep 2, 2016 at 10:02 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> It's very much _not_ just overlayfs being pathological - that it certainly is,
>> but the problem is much wider.
>
> Al, can you take a look at my two patches, and see if you agree that
> they fix it, though?

The original deadlock occurred because of some code path locking the
superblock followed by trying to acquire the af_unix readlock while
unix_bind did the same in the opposite order (by doing kern_path_create
with the readlock held). If unix_bind doesn't share a lock with the
receive routines anymore, this obviously can't happen anymore.

The other problem situation is one where a lock on someting can be
acquired both by kern_path_create and a mknod operation and the readlock
is taken in between. Because that sits in between the kern_path_create
and the mknod, it can block the thread which got a certain lock via
kern_path_create because the one which is about to try to acquire it via
mknod got the readlock first. This obviously can't happen anymore the when the
original 'acquire readlock (now bindlock) first' is restored.
