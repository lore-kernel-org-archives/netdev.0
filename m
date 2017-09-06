From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Wed, 6 Sep 2017 22:33:23 +0200
Message-ID: <20170906203323.GA16570@nanopsycho>
References: <20170906111419.5115-1-jiri@resnulli.us>
 <CAM_iQpWZJ9VVD66h6RMNofobKyoFyztx2jYqBEHuE6_iAu7PNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35409 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752313AbdIFUd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 16:33:26 -0400
Received: by mail-wr0-f196.google.com with SMTP id n64so114536wrb.2
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 13:33:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpWZJ9VVD66h6RMNofobKyoFyztx2jYqBEHuE6_iAu7PNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 06, 2017 at 07:40:02PM CEST, xiyou.wangcong@gmail.com wrote:
>On Wed, Sep 6, 2017 at 4:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> There's a memleak happening for chain 0. The thing is, chain 0 needs to
>> be always present, not created on demand. Therefore tcf_block_get upon
>> creation of block calls the tcf_chain_create function directly. The
>> chain is created with refcnt == 1, which is not correct in this case and
>> causes the memleak. So move the refcnt increment into tcf_chain_get
>> function even for the case when chain needs to be created.
>>
>
>Your approach could work but you just make the code even
>uglier than it is now:
>
>1. The current code is already ugly for special-casing chain 0:
>
>        if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
>                tcf_chain_destroy(chain);
>
>2. With your patch, chain 0 has a different _initial_ refcnt with others.

No. Initial refcnt is the same. ! for every action that holds the chain.
So actually, it returns it back where it should be.


>
>3. Allowing an object (chain 0) exists with refcnt==0

So? That is for every chain that does not have goto_chain action
pointing at. Please read the code.


>
>Compare it with my patch:
>
>1. No special-case for chain 0, the above ugly part is removed
>
>2. Every chain is equal and created with refcnt==1
>
>3. Any chain with refcnt==0 is destroyed
