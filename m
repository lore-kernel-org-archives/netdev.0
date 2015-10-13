From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement
 bpf_perf_event_sample_enable/disable() helpers
Date: Mon, 12 Oct 2015 21:16:59 -0700
Message-ID: <561C85BB.3000505@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
 <561C0A1E.2080500@plumgrid.com> <561C7A1F.6040702@huawei.com>
 <561C7CDA.8050004@plumgrid.com> <561C7FBE.4000104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33333 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbJMERC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 00:17:02 -0400
Received: by pabrc13 with SMTP id rc13so8216339pab.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 21:17:01 -0700 (PDT)
In-Reply-To: <561C7FBE.4000104@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/15 8:51 PM, Wangnan (F) wrote:
>> why 'set disable' is needed ?
>> the example given in cover letter shows the use case where you want
>> to receive samples only within sys_write() syscall.
>> The example makes sense, but sys_write() is running on this cpu, so just
>> disabling it on the current one is enough.
>>
>
> Our real use case is control of the system-wide sampling. For example,
> we need sampling all CPUs when smartphone start refershing its display.
> We need all CPUs because in Android system there are plenty of threads
> get involed into this behavior. We can't achieve this by controling
> sampling on only one CPU. This is the reason we need 'set enable'
> and 'set disable'.

ok, but that use case may have different enable/disable pattern.
In sys_write example ultra-fast enable/disable is must have, since
the whole syscall is fast and overhead should be minimal.
but for display refresh? we're talking milliseconds, no?
Can you just ioctl() it from user space?
If cost of enable/disable is high or the time range between toggling is
long, then doing it from the bpf program doesn't make sense. Instead
the program can do bpf_perf_event_output() to send a notification to
user space that condition is met and the user space can ioctl() events.
