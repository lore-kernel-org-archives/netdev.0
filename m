From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv10 ovs 00/15] Revalidate flows with unique identifiers.
Date: Tue, 25 Nov 2014 11:45:26 -0800
Message-ID: <CANr6G5w9tSTH=a-JmJpisF1Mf4L6vb8+1dRhcNxGjZWNHdna0A@mail.gmail.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "dev@openvswitch.org" <dev@openvswitch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:41369 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750877AbaKYTpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:45:47 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so13020967wiv.4
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:45:46 -0800 (PST)
In-Reply-To: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 November 2014 at 11:17, Joe Stringer <joestringer@nicira.com> wrote:
>
> This series modifies the dpif interface for flow commands to use 128-bit unique
> identifiers as an alternative to the netlink-formatted flow key, and caches the
> mask/actions in the udpif_key. This significantly reduces the cost of
> assembling messages between revalidators and the datapath, improving
> revalidation performance by 40% or more. In a test environment of many
> short-lived flows constantly being set up in the datapath, this increases the
> number of flows that can be maintained in the linux datapath from around
> 130-140K up to 190-200K. For the userspace datapath, this decreases the time
> spent revalidating 160K flows from 250ms to 150ms.
>
> The core of the changes sits in the handler and revalidator code. Handlers take
> responsibility for creating udpif_key cache entries which now include a copy of
> the flow mask and actions. Revalidators request datapaths to dump flows using
> only the unique identifier and stats, rather than the full set of
> netlink-formatted flow key, mask and actions.
>
> In cases where full revalidation is required, revalidators will use the
> udpif_key cache of the key/mask/acts to validate the flow. The dpif will
> detect datapath support for the unique identifer "UFID" feature, and omit flow
> keys from netlink transactions if it is supported. For backwards compatibility,
> flow keys will always be serialised if UFID support is not detected in the
> datapath.
>
> Patches 1,2,3,15 are unreviewed. Patch 12 needs further review.
>
> This series is also made available here to assist review:
> https://github.com/joestringer/openvswitch/tree/submit/ufid_v10
>

<snip>

>
> Joe Stringer (15):
>   tests: Add command to purge revalidators of flows.
>   ovs-bugtool: Log more detail for dumped flows.
>   datapath: Add 'is_mask' to ovs_nla_put_flow().
>   revalidator: Use 'cmap' for storing ukeys.
>   revalidator: Protect ukeys with a mutex.
>   udpif: Separate udpif_key maps from revalidators.
>   upcall: Rename dump_op -> ukey_op.
>   upcall: Create ukeys in handler threads.
>   upcall: Revalidate using cache of mask, actions.
>   hash: Add 128-bit murmurhash.
>   dpif: Generate flow_hash for revalidators in dpif.
>   datapath: Add support for unique flow identifiers.
>   dpif: Index flows using unique identifiers.
>   dpif: Minimize memory copy for revalidation.
>   dpctl: Add support for using UFID to add/del flows.


<snip>

I'm currently addressing feedback for the datapath patches, which also
involves minor changes to patch #13.

I've already pushed patch #1 as it provided an unrelated benefit.  As
this series is fairly close, my current plan is to push patches 4-11
to master this afternoon; these are long-running unchanged patches. I
will then resend patches 2,13,14,15 and the openvswitch.h changes for
final review here. I'll rebase the datapath changes against net-next
and go through review there.
