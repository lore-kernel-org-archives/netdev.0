From: Jesse Gross <jesse@kernel.org>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Tue, 19 Jan 2016 15:34:27 -0800
Message-ID: <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
References: <5697D833.5010506@hpe.com> <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:43130 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757279AbcASXep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 18:34:45 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 1F4482053C
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 23:34:44 +0000 (UTC)
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6AFDC20552
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 23:34:42 +0000 (UTC)
Received: by mail-qg0-f52.google.com with SMTP id 6so514215254qgy.1
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 15:34:42 -0800 (PST)
In-Reply-To: <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2016 at 2:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-01-19 at 13:07 -0800, Jesse Gross wrote:
>> On Thu, Jan 14, 2016 at 9:17 AM, John <john.phillips5@hpe.com> wrote:
>> > I'm getting what seems to be a kernel memory leak while doing a TCP
>> > throughput test between two VMs on identical systems, in order to test a
>> > broadcom NIC's performance with a kernel 4.4.0-rc8 and OpenVSwitch version
>> > 2.4.90. The host system of the receiving (server) VM leaks memory during the
>> > throughput test. The memory leaks fast enough to make the system completely
>> > unusable within five minutes. Once I stop the throughput test, the memory
>> > stops
>> > leaking. A couple of times, the kernel on the host system has actually
>> > killed
>> > the qemu process for me, but this doesn't happen reliably. The leaked memory
>> > doesn't become available again even after the VM is killed.
>>
>> It looks like the problem is in napi_skb_finish(). If we when do
>> GRO_MERGED_FREE we have NAPI_GRO_CB(skb)->free ==
>> NAPI_GRO_FREE_STOLEN_HEAD then we will just free the skb memory itself
>> but not any of the associated elements. Historically, this would have
>> been OK but these days we will have allocated a dst entry already for
>> tunnel metadata, which will get leaked.
>>
>> If we don't have NAPI_GRO_FREE_STOLEN_HEAD then we'll do a
>> __kfree_skb(), which will release the dst entry. That would explain
>> why some drivers have the problem but not others since the memory is
>> laid out differently.
>
>
> Wow.... What is the purpose of using skb_dst_set() on skb before calling
> gro_cells_receive() exactly ?
>
> Commit 2e15ea390e6f4466655066d97e22ec66870a042c changelog is not
> helpful :
>
>     Following patch create new tunnel flag which enable
>     tunnel metadata collection on given device.

Note that this isn't really the problem commit. The general issue is
lightweight tunnels - the above commit is just adding support for GRE
in a way that I think follows the existing model.

> This is rather strange since later the dst is thrown away with the
> skb_valid_dst() test.

This isn't really an IP routing dst - it's the tunnel encapsulation
information - so there isn't much to with it in ip_rcv_finish().
However, the information can be consumed in other places, such as
through eBPF.

> Note also that IP early demux is broken as well, since it does not use
> skb_valid_dst() but a simple :
>
> if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
>  ...
> }

I agree that this should use the helper function.
