From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next v3 8/8] geneve: break dependency to network drivers
Date: Fri, 8 Jan 2016 13:12:40 -0800
Message-ID: <CAEh+42izmdn5hHBxQWfSQEduWE2OeY0puM-5DEU-iHTWYXdobQ@mail.gmail.com>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
 <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
 <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com> <5690204B.7000004@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45274 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999AbcAHVM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 16:12:56 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D7B4B201DD
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 21:12:55 +0000 (UTC)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2546B201C7
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 21:12:55 +0000 (UTC)
Received: by mail-qk0-f169.google.com with SMTP id p186so125588330qke.0
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 13:12:55 -0800 (PST)
In-Reply-To: <5690204B.7000004@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 12:47 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 07.01.2016 01:18, Jesse Gross wrote:
>>
>> I think we should merge vxlan_get_rx_port() and geneve_get_rx_port()
>> into a single generic function. For drivers that support both, they
>> now have two calls to get notified for all offloaded ports. This
>> actually can cause problems related to duplicates, similar to what you
>> feared before.
>
>
> Checking out the ndo_add_vxlan_port callbacks, we cannot change how we
> refresh the ports unfortunately. For some drivers it might be easy to
> update, some look a little bit more complicated.
>
> I guess we should try to keep more complexity in the core and make sure we
> only call those functions if necessary for the particular type of offload
> than to replicate the logic in each driver.
>
> If you agree I prepare this series with the changes to have separate
> callbacks, address your other feedback and send it out.

I'm not sure that I totally understand, do you have an example of a
problematic driver?

I think what I was proposing is fairly simple, so maybe I wasn't
totally clear. Here's what I think we can do:

In your most recent series, vxlan_get_rx_port() and
geneve_get_rx_port() have the same implementation. I think we can
merge them into a single function (i.e. udp_tunnel_get_rx_port()). For
all of the drivers that only implement VXLAN offloads, this is just a
1:1 switch so there should be no functionality change. There's only
one driver than currently implements both (i40e) and it calls both
vxlan_get_rx_port() and geneve_get_rx_port() back to back. We can just
collapse this into a single call and since that will trigger both
offloads to refresh, the behavior should again be the same as we have.

I do know that there are so drivers that try to do clever things as
far as refcounting, etc. However, since the callbacks are the same as
we did before, it shouldn't introduce any issues.
