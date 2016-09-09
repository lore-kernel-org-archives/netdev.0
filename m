From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V6 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 8 Sep 2016 17:15:45 -0700
Message-ID: <CAM_iQpWuuyE025h2YsUKenZ30En2xFWqtUt26-FoR2-2gw=dgA@mail.gmail.com>
References: <1473235686-18975-1-git-send-email-hadarh@mellanox.com>
 <1473235686-18975-5-git-send-email-hadarh@mellanox.com> <CAM_iQpUrLg=i7Zug5h2OxpKoBqO5OWYmBCaMm=wYAYC3XZ-4uQ@mail.gmail.com>
 <CAJL1qvE8ij_63efQA-jdH_nfR1zWwYGVromGf72HW1MJYBmt4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35221 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcIIAQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:16:06 -0400
Received: by mail-oi0-f67.google.com with SMTP id 2so7326847oif.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 17:16:06 -0700 (PDT)
In-Reply-To: <CAJL1qvE8ij_63efQA-jdH_nfR1zWwYGVromGf72HW1MJYBmt4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 6:18 AM, Hadar Hen Zion
<hadarh@dev.mellanox.co.il> wrote:
> On Wed, Sep 7, 2016 at 7:27 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Also, ->cleanup() should be called with RTNL, no need to
>> take read lock here.
>
> RTNL lock isn't taken when cleanup is called.

Interesting... Then we have some problem here:

1) On the netns exit path, we only take the hashtable
spinlock while detaching it from hashtable, after
all refcnt is gone of course.

2) But, when we modify an existing action in hashtable,
we immediately release the refcnt before modifying it.

Fortunately the netns is refcnt'ed too, so this problem
doesn't show in real world.

If so, then you don't need read lock either, because
refcnt guarantees this call is only called by the last
process? IOW, there is no other possible parallel
writer??
