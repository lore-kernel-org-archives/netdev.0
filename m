From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Mon, 7 Aug 2017 10:17:02 -0700
Message-ID: <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com> <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:36605 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751564AbdHGRRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:17:24 -0400
Received: by mail-vk0-f66.google.com with SMTP id z187so503932vkd.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:17:24 -0700 (PDT)
In-Reply-To: <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 6, 2017 at 6:32 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
> I think the RCU should be supposed to avoid the race between del_chan and lookup_chan.

More precisely, it is callid_sock which is protected by RCU.

Unless I miss any other code path, pptp_exit_module() is
problematic too, I don't think it can just vfree() the whole thing.


> The synchronize_rcu could make sure if there was one which calls lookup_chan in this period, it would be finished and the sock refcnt is increased if necessary.
>
> So I think it is ok to invoke sock_put directly without SOCK_RCU_FREE, because the lookup_chan caller has already hold the sock refcnt,
>

If you mean the sock_hold() inside lookup_chan(), no,
it doesn't help because we already dereference the sock
before it.

Also, lookup_chan_dst() does not have a refcnt, I don't
find any code preventing it deref'ing other sock in callid_sock
than the calling one.
