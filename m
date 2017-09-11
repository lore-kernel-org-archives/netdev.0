From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] netlink: access nlk groups safely in netlink bind and getname
Date: Mon, 11 Sep 2017 10:35:04 -0700
Message-ID: <CAM_iQpXP7ANA3EWUyy3c9iJ2zsRfM7aaA7bR=QG+fW5t6q9qSg@mail.gmail.com>
References: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
 <CAM_iQpXA7q9_WADayWiHgqsz=VfhNqZr42TL0F+N2XK+toEEOQ@mail.gmail.com> <CADvbK_dBm1b97eFqGrEp1EZN8Sfozm3PJ1MhqEZK+R3FB47-ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        David Herrmann <dh.herrmann@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:38290 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbdIKRf0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 13:35:26 -0400
Received: by mail-pg0-f48.google.com with SMTP id v66so16446193pgb.5
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 10:35:25 -0700 (PDT)
In-Reply-To: <CADvbK_dBm1b97eFqGrEp1EZN8Sfozm3PJ1MhqEZK+R3FB47-ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 10, 2017 at 4:45 AM, Xin Long <lucien.xin@gmail.com> wrote:
> On Sat, Sep 9, 2017 at 7:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Tue, Sep 5, 2017 at 8:53 PM, Xin Long <lucien.xin@gmail.com> wrote:
>>> Now there is no lock protecting nlk ngroups/groups' accessing in
>>> netlink bind and getname. It's safe from nlk groups' setting in
>>> netlink_release, but not from netlink_realloc_groups called by
>>> netlink_setsockopt.
>>>
>>> netlink_lock_table is needed in both netlink bind and getname when
>>> accessing nlk groups.
>>
>> This looks very odd.
>>
>> netlink_lock_table() should be protecting nl_table, why
>> it also protects nlk->groups?? For me it looks like you
>> need lock_sock() instead.
> I believe netlink_lock_table might be only used to protect nl_table
> at the beginning and surely lock_sock is better here. Thanks.
>
> But can you explain why  netlink_lock_table() was also used in
> netlink_getsockopt NETLINK_LIST_MEMBERSHIPS ? or it
> was just a mistake ?

No, it is fine but not necessary, because netlink_realloc_groups()
doesn't change nl_table, it only changes nlk->groups. So we
don't have take the global write lock, the lock sock makes more
sense here, same for your bind() and getname() case.
