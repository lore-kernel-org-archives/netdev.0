From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify
 software only rules
Date: Wed, 24 Feb 2016 08:31:28 -0500
Message-ID: <56CDB0B0.4080609@mojatatu.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
 <20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35922 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932501AbcBXNba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 08:31:30 -0500
Received: by mail-io0-f174.google.com with SMTP id l127so38451156iof.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 05:31:30 -0800 (PST)
In-Reply-To: <20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 02:03 PM, John Fastabend wrote:
> In the initial implementation the only way to stop a rule from being
> inserted into the hardware table was via the device feature flag.
> However this doesn't work well when working on an end host system
> where packets are expect to hit both the hardware and software
> datapaths.
>
> For example we can imagine a rule that will match an IP address and
> increment a field. If we install this rule in both hardware and
> software we may increment the field twice. To date we have only
> added support for the drop action so we have been able to ignore
> these cases. But as we extend the action support we will hit this
> example plus more such cases. Arguably these are not even corner
> cases in many working systems these cases will be common.
>
> To avoid forcing the driver to always abort (i.e. the above example)
> this patch adds a flag to add a rule in software only. A careful
> user can use this flag to build software and hardware datapaths
> that work together. One example we have found particularly useful
> is to use hardware resources to set the skb->mark on the skb when
> the match may be expensive to run in software but a mark lookup
> in a hash table is cheap. The idea here is hardware can do in one
> lookup what the u32 classifier may need to traverse multiple lists
> and hash tables to compute. The flag is only passed down on inserts
> on deletion to avoid stale references in hardware we always try
> to remove a rule if it exists.
>
> Notice we do not add a hardware only case here. If you were to
> add a hardware only case then you are stuck with the problem
> of where to stick the software representation of that filter
> rule. If its stuck on the same filter list as the software only and
> software/hardware rules it then has to be walked over and ignored
> in the classify path. The overhead is not huge but is measurable.
> And with so much work being invested in speeding up rx/tx of
> pkt processing this is unacceptable IMO. The other option is to
> have a special hook just for hardware only resources. This is
> implemented in the next patch.
>

Dont have much time to look closely - will do later. Just wanted
to quip:
Would it make sense to have a user flag which says, "please store
this in s/ware - dont use it in s/ware just install it in h/ware."
This should be totally optional policy, but would help find the rules
faster from a control plane if i look for them in s/ware first.
There's some really freaking slow hardware interfaces out there...
(a record of 60 seconds to find something is not unheard of).

cheers,
jamal
