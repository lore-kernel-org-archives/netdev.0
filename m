From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if available
Date: Tue, 10 Dec 2013 11:28:08 -0800
Message-ID: <CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: Francesco Fusco <ffusco@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:41341 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751018Ab3LJT2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:28:30 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so9373140ieb.39
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 11:28:29 -0800 (PST)
In-Reply-To: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 1:52 AM, Francesco Fusco <ffusco@redhat.com> wrote:
> Currently OVS uses jhash2() for calculating flow hashes in its
> internal flow_hash() function. The performance of the flow_hash()
> function is critical, as the input data can be hundreds of bytes
> long.
>
> One possible direction to achieve higher performance consists
> of replacing jhash2() with an architecture specific hash
> function pretty much like the Intel folks have proposed in
> DPDK. DPDK provides a very fast hash function that leverages
> the 32bit crc32l instruction part of the Intel SSE4.2
> instruction set.
>
> OVS is largely deployed in x86_64 based datacenters.
> Therefore, we argue that the performance critical fast path
> of OVS should exploit underlying CPU features in order to reduce
> the per packet processing costs.
>
> We adapted and integrated Intel's hashing function from DPDK in
> order to be used with OVS internally. Our patch greatly reduces
> the hash footprint from ~200 cycles of jhash2() to around ~90
> cycles in case of ovs_flow_hash_crc() (measured with rdtsc over
> maximum length flow keys on an i7 Intel CPU).
>
> Additionally, we wrote a microbenchmark to stress the flow table
> performance. The benchmark inserts random flows into the flow
> hash and then performs lookups. Our hash deployed on a CRC32
> capable CPU reduces the lookup for 1000 flows, 100 masks from
> ~10,100us to ~6,700us, for example.
>
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

I think this is definitely a good optimization to do given that so
much of the work that OVS does is hashing. However, isn't there a
library where there would be a more appropriate place to put this?
