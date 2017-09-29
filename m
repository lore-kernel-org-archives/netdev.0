From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Fri, 29 Sep 2017 09:56:42 +0200
Message-ID: <8737760wg5.fsf@stressinduktion.org>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
        <150660342793.2808.10838498581615265043.stgit@firesoul>
        <20170929032146.vs5v454wjs4niu4k@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>, pabeni@redhat.com,
        edumazet@google.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56817 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751037AbdI2H4r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 03:56:47 -0400
In-Reply-To: <20170929032146.vs5v454wjs4niu4k@ast-mbp> (Alexei Starovoitov's
        message of "Thu, 28 Sep 2017 20:21:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding Paolo, Eric]

Alexei Starovoitov <alexei.starovoitov@gmail.com> writes:

> On Thu, Sep 28, 2017 at 02:57:08PM +0200, Jesper Dangaard Brouer wrote:

[...]

>> +	wake_up_process(rcpu->kthread);
>
> In general the whole thing looks like 'threaded NAPI' that Hannes was
> proposing some time back. I liked it back then and I like it now.
> I don't remember what were the objections back then.
> Something scheduler related?
> Adding Hannes.

Yes.

The main objection from Eric at that time was that user space now starts
to compete with the threaded NAPI threads depending on process
priorities, which are under control of user space. Softirq always runs
first to end. Networking could starve because a process with higher
priority is runnable. At that time Eric found a way to fix the
particular problem, which resulted in commit 4cd13c21b207e80d. Pinning
and other control is also possible from user space, causing more complex
tuning set ups and problems will be harder to debug.

In particular after Eric's patch threaded NAPI proofed itself to be not
useful anymore, because his patch successfully deferred work to the
ksoftirqd more reliable thus allowing the UDP rx queue to get drained by
user space.

> Still curious about the questions I asked in the other thread
> on what's causing it to be so much better than RPS

My guess is that RPS uses expensive IPI to notify the remote
softirq. The batching size on RPS depends on how many packets could get
worked on during one softirq invocation on the source CPU until we wake
up remote CPU(s!), if they are not constantly running.
