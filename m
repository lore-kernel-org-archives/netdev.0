From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 12:11:05 -0700
Message-ID: <CALnjE+qLPeJN1h1qFnYuiipbJH06Gtx_7vJGzjocVoH40fNUcQ@mail.gmail.com>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151006174205.799ac484@griffin>
	<CALnjE+qSdDnmbbHV0O6Pa9z=T=8jFSL2bw5k_m_DwgtchZaCOg@mail.gmail.com>
	<20151006205553.6975a147@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38193 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbbJFTLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 15:11:06 -0400
Received: by igxx6 with SMTP id x6so87852640igx.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 12:11:05 -0700 (PDT)
In-Reply-To: <20151006205553.6975a147@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 11:55 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 6 Oct 2015 11:26:31 -0700, Pravin Shelar wrote:
>> I do not see need to drop and reallocate dst in this operation. I just
>> need to set source IP address and source and dst port in the metadata
>> dst already set in skb.
>
> If I'm looking at the code correctly, metadata_dst is stored in the
> action and each skb gets only a reference to it. Modifying it would
> modify the shared metadata_dst (see execute_set_action).
>
right, I was thinking about updating just the source IPv4 address
which should be same for given tunnel metadata. But that can get
complicated for updates to ipv6 address.

>> This fill_metadata function is not called for every packet so
>> ndo_start_xmit() still needs to do route lookup.
>
> Yes. I meant that in those cases where the fill_metadata function was
> called, we may skip the lookup. Just an optimization and not an
> important one. I'm not even sure it can currently happen as the skb is
> cloned for each action.
>
The function is called for sampling which is rare operation. So I do
not want to complicate code to optimize such case.

>> egress_tun_info in dp_upcall_info is required to check for failure. It
>> would be only set on successful fill_metadata operation.
>
> Or you can just set dst to NULL on failure.
>

In that case we would need to extra logic to update error stats
correctly device xmit operation. For example geneve_xmit() updates
different error stats for route lookup.
