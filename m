From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 14:20:40 -0700
Message-ID: <CAKgT0Ud59j1NDHD6siPSZL24HJnPOF7m07DKf4U96Tq4dtByvg@mail.gmail.com>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
	<20160330170011.GB27540@oracle.com>
	<CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
	<20160330172001.GD27540@oracle.com>
	<CAKgT0Ufb-_X-DD2jYkVJQwLZ-JBfWD2Biuhi6YaxWBeNy9K2fQ@mail.gmail.com>
	<20160330124135.000054c6@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33655 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128AbcC3VUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 17:20:41 -0400
Received: by mail-io0-f172.google.com with SMTP id a129so83811581ioe.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 14:20:41 -0700 (PDT)
In-Reply-To: <20160330124135.000054c6@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 12:41 PM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> On Wed, 30 Mar 2016 10:35:55 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Wed, Mar 30, 2016 at 10:20 AM, Sowmini Varadhan
>> <sowmini.varadhan@oracle.com> wrote:
>> > On (03/30/16 10:12), Alexander Duyck wrote:
>> >> Yeah.  The patch was sort of a knee-jerk reaction to being told that
>> >> the patch referenced caused a regression.  From what I can tell that
>> >> is not the case as I am also seeing the Tx hangs when I run the test
>> >> with the frames being linearized.
>> >
>> > I'm not sure how important of a subtlety this is, but the actual
>> > console log after the patch is the following:
>> >
>> >  i40e 0000:82:00.0: TX driver issue detected, PF reset issued
>> >  i40e 0000:82:00.0 eth2: adding 68:05:ca:30:dd:18 vid=0
>> >  i40e 0000:82:00.0: TX driver issue detected, PF reset issued
>> >  i40e 0000:82:00.0 eth2: adding 68:05:ca:30:dd:18 vid=0
>> >  i40e 0000:82:00.0: TX driver issue detected, PF reset issued
>> >
>> > Comparing with what I'd pasted in the sourceforge thread earlier,
>> > I see that it does not say "Hung Tx queue etc."  any more, though
>> > it still resets.
>> >
>> > Not sure if that changed info is significant?
>>
>> It might be.  Right now I am chasing down the Tx driver issue as that
>> I what I am reproducing in my environment as well.
>
> This gets "Even Uglier", I've turned off all offloads at my receiver,
> enabled calling skb_linearize on *all* frames, which works fine for
> scp, but the receiver shows > MSS sized frames on the wire for
> rds-stress traffic.

Are you sure it isn't just GRO reassembling frames on the receive
side.  I know that one always trips me up when I am using the Rx path
to validate Tx checksums.

> This implies to me we have some issue with skb_linearize, possibly in
> how the stack linearizes the data, or how the driver interprets the
> linearized packets (which should always work)
>
> Wheee......

With the descriptor dump code you have you should be able to verify
what the layout is after the descriptor is linearized.  I would think
in most cases you would end up with at most something like 4 to maybe
5 descriptors for a 64K frame.

- Alex
