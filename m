From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Wed, 6 Sep 2017 10:40:02 -0700
Message-ID: <CAM_iQpWZJ9VVD66h6RMNofobKyoFyztx2jYqBEHuE6_iAu7PNQ@mail.gmail.com>
References: <20170906111419.5115-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36274 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752405AbdIFRkX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 13:40:23 -0400
Received: by mail-pg0-f66.google.com with SMTP id d8so3794494pgt.3
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 10:40:23 -0700 (PDT)
In-Reply-To: <20170906111419.5115-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 6, 2017 at 4:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> There's a memleak happening for chain 0. The thing is, chain 0 needs to
> be always present, not created on demand. Therefore tcf_block_get upon
> creation of block calls the tcf_chain_create function directly. The
> chain is created with refcnt == 1, which is not correct in this case and
> causes the memleak. So move the refcnt increment into tcf_chain_get
> function even for the case when chain needs to be created.
>

Your approach could work but you just make the code even
uglier than it is now:

1. The current code is already ugly for special-casing chain 0:

        if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
                tcf_chain_destroy(chain);

2. With your patch, chain 0 has a different _initial_ refcnt with others.

3. Allowing an object (chain 0) exists with refcnt==0

Compare it with my patch:

1. No special-case for chain 0, the above ugly part is removed

2. Every chain is equal and created with refcnt==1

3. Any chain with refcnt==0 is destroyed
