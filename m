From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Re: [Intel-wired-lan] [PATCH] ixgbe: initialize u64_stats_sync
 structures early at ixgbe_probe
Date: Tue, 25 Apr 2017 10:16:22 -0700
Message-ID: <CAKgT0Uc31ehKGmjKWFg6YNWtqvD1grosaVXqBX+GUCxUBdQUHg@mail.gmail.com>
References: <1480909244-16460-1-git-send-email-liwei.song@windriver.com>
 <EF50CC0C76A53A44BAD798C58E0A157E50B87CBB@ORSMSX103.amr.corp.intel.com>
 <CAKgT0UeTdY9j1qDHP=DscgAZF2pPFCb+=ACySqKBK+UuBsaNBA@mail.gmail.com> <trinity-a348af9b-9ef5-47a9-a14e-94265c880cf1-1493134775614@3capp-gmx-bs78>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Singh, Krishneil K" <krishneil.k.singh@intel.com>,
        "Song, Liwei (Wind River)" <liwei.song@windriver.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38577 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951822AbdDYRQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:23 -0400
In-Reply-To: <trinity-a348af9b-9ef5-47a9-a14e-94265c880cf1-1493134775614@3capp-gmx-bs78>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 8:39 AM, Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:
> Hi,
>
>> This patch doesn't look right to me. I would suggest rejecting it.
>>
>> The call to initialize the stats should be done when the ring is
>> allocated, not in ixgbe_probe(). This should probably be done in
>> ixgbe_alloc_q_vector() instead.
>>
>
> AFAICS ixgbe_alloc_q_vector() is also called in probe() (by ixgbe_init_interrupt_scheme()).
> Furthermore it is also called in resume() which would lead to multiple initialization of
> the u64_stats_sync in case of resume.

ixgbe_alloc_q_vector() is what allocates the ring structures that are
being initialized here. Calling it anywhere other than here doesn't
make sense since what we want to do is initialize the memory after we
have allocated it, but before we hand the pointer to it over to a
netdev or in this case an adapter structure.

> IMHO the u64_stats_sync variables have to be initialized before register_netdev() is called
> since this is the point from which userspace can call ixgbe_get_stats64(). I would say the
> best place to do so is the probe() function as it is done in this patch.

I would disagree here. We should be initializing the stats variables
after we allocate them. Especially since we can end up freeing and
reallocating them any time the number of queues is changed.

> Just my 2 cents.
>
> Regards,
> Lino

My advice would be to look through the code and verify what it is you
need to initialize and where it should happen. In this case we are
getting a lockdep splat since we are just letting things get
initialized with kzalloc and aren't following up in the right place. I
don't disagree that the original code has the u64_stats_init in the
wrong place since we can open/close the interface and trigger a
reinitialization of the stats. I would say we need to initialize the
stats just after we allocate them in memory so that if we decide to
free and reallocate the rings we initialize the new rings before they
are added to the netdev and don't reintroduce this issue in just a
different form.

- Alex
