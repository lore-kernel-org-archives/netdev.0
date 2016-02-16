From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Tue, 16 Feb 2016 12:11:57 -0800
Message-ID: <CAEh+42jbaryH8J4vZYXM0yVQcaXZ23Q59_iHr8QT_2PHRmDGgg@mail.gmail.com>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
 <20160211114124.17ae429a@griffin> <CAEh+42jyFVjM4A5HzJQ94xW+XZOTG5iBEFu2VHKCJU0sRwNgWA@mail.gmail.com>
 <20160216.144759.1984502562641417028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, Paolo Abeni <pabeni@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:35846 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865AbcBPUMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:12:14 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 66C9420304
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:12:13 +0000 (UTC)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6BAA8202BE
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:12:12 +0000 (UTC)
Received: by mail-qk0-f172.google.com with SMTP id o6so71441793qkc.2
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:12:12 -0800 (PST)
In-Reply-To: <20160216.144759.1984502562641417028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@kernel.org>
> Date: Tue, 16 Feb 2016 10:22:38 -0800
>
>> On Thu, Feb 11, 2016 at 2:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
>> There's a bigger problem here, not really related to lightweight tunnels or OVS.
>>
>> The VXLAN RFC says (referring to the UDP checksum and not specific to IPv4/v6):
>> "It SHOULD be transmitted as zero. When a packet is received with a
>> UDP checksum of zero, it MUST be accepted for decapsulation."
>>
>> We can debate whether this is correct or whether it conflicts with RFC
>> 2460 but this is what essentially everyone is going to implement. With
>> the default settings of the flags in IPv6, we are violating both
>> statements. With the second one in particular, the result is that
>> Linux will not be able to communicate with any non-Linux VXLAN
>> endpoint over IPv6 with default settings.
>
> I do not see any such conflict here.
>
> It's a SHOULD, therefore a recommendation.  Likely they thought this
> would improve performance, and ironically it has the opposite effect.
>
> The text of the VXLAN RFC does not say that the checksum MUST be sent
> as zero, and it also does not say that receiving a non-zero checksum
> is violating the RFC.
>
> I therefore do not see the interoperability issue.  Maybe some
> deployed systems will run more slowly or hit a slot path (which is not
> our problem), but they absolutely should not drop such frames.

"When a packet is received with a UDP checksum of zero, it MUST be
accepted for decapsulation."

This is a requirement and directly in conflict with having
VXLAN_F_UDP_ZERO_CSUM6_RX set to false as the default.

As far as the use of checksums, saying that it improves performance is
only valid for a class of devices. It is not true as a blanket
statement, such as for switching ASICs. In these cases, the
performance drop in hitting a slow path is so big that it is
equivalent to dropping frames and creates a de-facto interoperability
issue.
