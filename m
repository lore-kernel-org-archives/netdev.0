From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Thu, 4 Jun 2015 09:12:55 -0700
Message-ID: <CAE4R7bD1EmYm4TNrWWskTeKA6NfNsasVRTP4KxhOYvZt_9n3Ow@mail.gmail.com>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
 <20150603.233829.1362177764562847830.davem@davemloft.net> <20150604082045.GA7709@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:36724 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbbFDQNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:13:16 -0400
Received: by qcxw10 with SMTP id w10so19682419qcx.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:13:15 -0700 (PDT)
In-Reply-To: <20150604082045.GA7709@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 1:20 AM, Simon Horman <simon.horman@netronome.com> wrote:
> Hi Dave,
>
> On Wed, Jun 03, 2015 at 11:38:29PM -0700, David Miller wrote:
>> From: sfeldma@gmail.com
>> Date: Tue,  2 Jun 2015 20:43:28 -0700
>>
>> > From: Scott Feldman <sfeldma@gmail.com>
>> >
>> > v2:
>> >
>> > Changes based on review:
>> >
>> > - David Miller <davem@davemloft.net> raise problem with system_wq not
>> >   preserving queue order to execution order.  To fix, use driver-private
>> >   ordered workqueue to preserve ordering of queued work.
>> >
>> > - Jiri Pirko <jiri@resnulli.us> small change on kfree of work queue item.
>> >
>> > v1:
>> >
>> > In review of Simon's patchset "rocker: transaction fixes". it was noted
>> > that rocker->neigh_tbl_next_index was unprotected in the call path below
>> > and could race with other contexts calling rocker_port_ipv4_neigh():
>>
>> How it rocker->neigh_tbl_next_index not protected?
>>
>> rocker->neigh_tbl_lock is _always_ held when it is accessed.
>>
>> This patch, therefore, looks like completely unnecessary complexity
>> to me.  Furthermore, I would completely prefer if the operation stays
>> completely synchronous to the call path where the neigh operation
>> occurs rather than throwing it out to a workqueue.
>
> What I was seeing is as follows:
>
> 1. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
>    with trans = SWITCHDEV_TRANS_PREPARE
>
> 2. rocker_port_ipv4_neigh() is called by rocker_neigh_update()
>    with trans = SWITCHDEV_TRANS_NONE.
>
>    The call chain goes up to arp_process() via neigh_update().
>
> 3. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
>    with trans = SWITCHDEV_TRANS_COMMIT
>
> #1 and #2 are guarded by rtl across those calls but
> #2 is not guarded by rtnl.
>
> Inside both rocker_port_ipv4_nh() and rocker_port_ipv4_neigh()
> neigh_tbl_lock lock is taken but it is not held across the
> two calls to rocker_port_ipv4_nh within a single prepare->commit transaction.
>
> I can double check that the above still occurs, but I'm not aware of any
> recent changes that would cause it not to occur any more.

Simon, just focusing on this rocker->neigh_tbl_next_index++ issue at
the moment, I think the change below would make _rocker_neigh_add()
safe to call without needing to put neigh_update into process context.
It works because entry is stored between PREPARE and COMMIT, so once
entry->index is assigned in PREPARE (under neigh_tbl_lock), it'll be
re-used in COMMIT, even if the NONE thread also claims it's
entry->index (also under neigh_tbl_lock).

I know there are other issues you and Toshiaki Makita have pointed
out, but let's see if we can peel the onion one layer at a time.

--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2904,10 +2904,10 @@ static void _rocker_neigh_add(struct rocker *rocker,
                              enum switchdev_trans trans,
                              struct rocker_neigh_tbl_entry *entry)
 {
-       entry->index = rocker->neigh_tbl_next_index;
+       if (trans != SWITCHDEV_TRANS_COMMIT)
+               entry->index = rocker->neigh_tbl_next_index++;
        if (trans == SWITCHDEV_TRANS_PREPARE)
                return;
-       rocker->neigh_tbl_next_index++;
        entry->ref_count++;
        hash_add(rocker->neigh_tbl, &entry->entry,
                 be32_to_cpu(entry->ip_addr));
