From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Soft lockup in tc_classify
Date: Tue, 20 Dec 2016 23:03:55 -0800
Message-ID: <CAM_iQpX3jL4URUQn5+-wV+3g2UKHWGBWYHr31wyZk2FQKVCzVA@mail.gmail.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com> <584EA60B.80803@iogearbox.net>
 <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com>
 <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com>
 <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com> <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com>
 <5a985705-11e5-1575-a049-723accb97608@mellanox.com> <58591A46.4060703@iogearbox.net>
 <66a3cb1e-862f-70e6-fff4-5a421766c432@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Shahar Klein <shahark@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35952 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbcLUHEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 02:04:16 -0500
Received: by mail-qk0-f196.google.com with SMTP id h201so6785726qke.3
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 23:04:16 -0800 (PST)
In-Reply-To: <66a3cb1e-862f-70e6-fff4-5a421766c432@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 10:44 PM, Shahar Klein <shahark@mellanox.com> wrote:
>
> Tried it with same results

This piece is pretty interesting:

[  408.554689] DEBUGG:SK thread-2853[cpu-1] setting tp_created to 1
tp=ffff94b5b02805a0 back=ffff94b9ea932060
[  408.574258] DEBUGG:SK thread-2853[cpu-1] add/change filter by:
fl_get [cls_flower] tp=ffff94b5b02805a0 tp->next=ffff94b9ea932060
[  408.587849] DEBUGG:SK destroy ffff94b5b0280780 tcf_destroy:1905
[  408.595862] DEBUGG:SK thread-2845[cpu-1] add/change filter by:
fl_get [cls_flower] tp=ffff94b5b02805a0 tp->next=ffff94b5b02805a0

Looks like you added a debug printk inside tcf_destroy() too,
which seems racy with filter creation, it should not happen since
in both cases we take RTNL lock.

Don't know if changing all RCU_INIT_POINTER in that file to
rcu_assign_pointer could help anything or not. Mind to try?


Thanks for debugging!
