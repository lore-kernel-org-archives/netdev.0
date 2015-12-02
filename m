From: Jesse Gross <jesse@kernel.org>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Wed, 2 Dec 2015 10:04:16 -0800
Message-ID: <CAEh+42jn+6-JVL8fBCo2GAgCZLsYUXwtHYPPyk5B1qS=6E0b4A@mail.gmail.com>
References: <56435508.9070802@mellanox.com> <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
 <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
 <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
 <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
 <565AF849.8030008@mellanox.com> <CAOftzPi8mVWtr1aJ1EeAHjXOY7jq-WZ2XnNw5UAxO5_cQrVafA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Haggai Eran <haggaie@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:42671 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964875AbbLBSEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 13:04:39 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 0B0992054A
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 18:04:38 +0000 (UTC)
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 451142051C
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 18:04:36 +0000 (UTC)
Received: by qgcc31 with SMTP id c31so39559390qgc.3
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 10:04:35 -0800 (PST)
In-Reply-To: <CAOftzPi8mVWtr1aJ1EeAHjXOY7jq-WZ2XnNw5UAxO5_cQrVafA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 9:52 AM, Joe Stringer <joe@ovn.org> wrote:
> On 29 November 2015 at 05:06, Haggai Eran <haggaie@mellanox.com> wrote:
>> On 14/11/2015 08:45, Joe Stringer wrote:
>>> On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> > On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>>> >
>>>>> >> I don't follow the logic. You observed one flow which matched on
>>>>> >> TTL=64, therefore all vxlan packets terminated at OVS have TTL=64?
>>>> >
>>>>> >> If OVS received packets with different TTLs, they would miss and
>>>>> >> ovs-vswitchd would generate flows to match that traffic too.
>>>> >
>>>> > ok, that makes things a bit better, but (see next)
>>>> >
>>>>> >> If that becomes an issue, presumably the wildcard generation can be improved.
>>>> >
>>>> > is there a deep reason for vlxan "learned flows" to actually match w
>>>> > or w.o wild cards on TTLs?? for non-tunneled flow I don't see  this
>>>> > happening.
>>> No deep reason I'm aware of.
>>
>> Hi,
>>
>> We looked into the OVS kernel module, and apparently there's a check
>> that rejects new tunnel flows if they don't have the TTL mask set [1].
>>
>> I was able to trace it to this commit [2] on the OVS tree, but I don't
>> quite understand why the check was added. There was some discussion
>> about the patch on the mailing list [3] that hints this was about
>> catching zero TTL, but it has too little context for me to understand.
>>
>> I'm adding the author and reviewer of the patch, perhaps they can help
>> explain this requirement.
>
> I'm not the author or reviewer, but it seems like this is an attempt
> to prevent flows from matching TTL=0 then proceeding to forward the
> frame. You could still match a non-zero TTL with a wildcarded mask,
> but it wouldn't be possible for a single flow to match all (non-zero)
> TTL values.

You can match on TTL=0 as long as you do it explicitly. The assumption
though is that this isn't what most people want to do if they don't
specify any value so it would be bad default.

However, it looks like while this was primarily targeted at the key,
the check also bled over into the mask translation as well, preventing
it from being wildcarded through omission. It's still not clear to me
that this makes any difference in the real world though.
