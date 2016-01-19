From: Jesse Gross <jesse@kernel.org>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Tue, 19 Jan 2016 13:07:43 -0800
Message-ID: <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
References: <5697D833.5010506@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com
To: John <john.phillips5@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:36185 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932702AbcASVIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 16:08:00 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 2F4CF20557
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 21:07:59 +0000 (UTC)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 647E22054C
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 21:07:58 +0000 (UTC)
Received: by mail-qk0-f174.google.com with SMTP id o6so28655877qkc.2
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 13:07:58 -0800 (PST)
In-Reply-To: <5697D833.5010506@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 14, 2016 at 9:17 AM, John <john.phillips5@hpe.com> wrote:
> I'm getting what seems to be a kernel memory leak while doing a TCP
> throughput test between two VMs on identical systems, in order to test a
> broadcom NIC's performance with a kernel 4.4.0-rc8 and OpenVSwitch version
> 2.4.90. The host system of the receiving (server) VM leaks memory during the
> throughput test. The memory leaks fast enough to make the system completely
> unusable within five minutes. Once I stop the throughput test, the memory
> stops
> leaking. A couple of times, the kernel on the host system has actually
> killed
> the qemu process for me, but this doesn't happen reliably. The leaked memory
> doesn't become available again even after the VM is killed.

It looks like the problem is in napi_skb_finish(). If we when do
GRO_MERGED_FREE we have NAPI_GRO_CB(skb)->free ==
NAPI_GRO_FREE_STOLEN_HEAD then we will just free the skb memory itself
but not any of the associated elements. Historically, this would have
been OK but these days we will have allocated a dst entry already for
tunnel metadata, which will get leaked.

If we don't have NAPI_GRO_FREE_STOLEN_HEAD then we'll do a
__kfree_skb(), which will release the dst entry. That would explain
why some drivers have the problem but not others since the memory is
laid out differently.
