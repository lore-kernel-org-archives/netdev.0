From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Thu, 4 Jun 2015 18:33:10 -0700
Message-ID: <CAE4R7bBfHeK8U_8-QWoVoaVAGT6ObemaKdGOon_nyO8gooyU4A@mail.gmail.com>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
 <20150603.233829.1362177764562847830.davem@davemloft.net> <20150604082045.GA7709@vergenet.net>
 <CAE4R7bD1EmYm4TNrWWskTeKA6NfNsasVRTP4KxhOYvZt_9n3Ow@mail.gmail.com> <20150604225425.GA7465@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33386 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbFEBdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 21:33:31 -0400
Received: by oiww2 with SMTP id w2so43831257oiw.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 18:33:31 -0700 (PDT)
In-Reply-To: <20150604225425.GA7465@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 3:54 PM, Simon Horman <horms@verge.net.au> wrote:
> Hi Scott,
>
>> Simon, just focusing on this rocker->neigh_tbl_next_index++ issue at
>> the moment, I think the change below would make _rocker_neigh_add()
>> safe to call without needing to put neigh_update into process context.
>> It works because entry is stored between PREPARE and COMMIT, so once
>> entry->index is assigned in PREPARE (under neigh_tbl_lock), it'll be
>> re-used in COMMIT, even if the NONE thread also claims it's
>> entry->index (also under neigh_tbl_lock).
>>
>> I know there are other issues you and Toshiaki Makita have pointed
>> out, but let's see if we can peel the onion one layer at a time.
>>
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -2904,10 +2904,10 @@ static void _rocker_neigh_add(struct rocker *rocker,
>>                               enum switchdev_trans trans,
>>                               struct rocker_neigh_tbl_entry *entry)
>>  {
>> -       entry->index = rocker->neigh_tbl_next_index;
>> +       if (trans != SWITCHDEV_TRANS_COMMIT)
>> +               entry->index = rocker->neigh_tbl_next_index++;
>>         if (trans == SWITCHDEV_TRANS_PREPARE)
>>                 return;
>> -       rocker->neigh_tbl_next_index++;
>>         entry->ref_count++;
>>         hash_add(rocker->neigh_tbl, &entry->entry,
>>                  be32_to_cpu(entry->ip_addr));
>
> I agree that should work.

I've been running it today with no problems.  So I'm preparing a new
patch that changes direction here, to address David's concern about
switching neigh event context.  Details:

1) Above little patch addresses the race issue with neigh_tbl_next_index

2) Keep neigh update event in event context and bring back a couple of
items I removed in the Spring Cleanup series:

   a) use ROCKER_OP_FLAG_NOWAIT to mark contexts that can't sleep
   b) if nowait, mem allocations use GFP_ATOMIC
   c) if nowait, cmd to device is issued, but we will not sleep to
wait for response from device; just hit-and-run

I was probably too aggressive with Spring Cleanup thinking we could
swing all device accesses to process context.

Thanks to all for the testing/review/feedback/patience.
