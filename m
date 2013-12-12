From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 2/2] net: ovs: use CRC32 accelerated flow hash
 if available
Date: Thu, 12 Dec 2013 12:20:14 -0800
Message-ID: <CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q@mail.gmail.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com> <1386860946-1621-3-git-send-email-ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: Francesco Fusco <ffusco@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:52492 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751554Ab3LLUUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:20:35 -0500
Received: by mail-ig0-f175.google.com with SMTP id j1so139845iga.2
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 12:20:34 -0800 (PST)
In-Reply-To: <1386860946-1621-3-git-send-email-ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 7:09 AM, Francesco Fusco <ffusco@redhat.com> wrote:
> Currently OVS uses jhash2() for calculating flow hashes in its
> internal flow_hash() function. The performance of the flow_hash()
> function is critical, as the input data can be hundreds of bytes
> long.
>
> OVS is largely deployed in x86_64 based datacenters.  Therefore,
> we argue that the performance critical fast path of OVS should
> exploit underlying CPU features in order to reduce the per packet
> processing costs. We replace jhash2 with the hash implementation
> provided by the kernel hash lib, which exploits the crc32l
> instruction to achieve high performance
>
> Our patch greatly reduces the hash footprint from ~200 cycles of
> jhash2() to around ~90 cycles in case of ovs_flow_hash_crc()
> (measured with rdtsc over maximum length flow keys on an i7 Intel
> CPU).
>
> Additionally, we wrote a microbenchmark to stress the flow table
> performance. The benchmark inserts random flows into the flow
> hash and then performs lookups. Our hash deployed on a CRC32
> capable CPU reduces the lookup for 1000 flows, 100 masks from
> ~10,100us to ~6,700us, for example.
>
> Thus, simply use the newly introduced arch_fast_hash2() as a
> drop-in replacement.
>
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

Acked-by: Jesse Gross <jesse@nicira.com>

Out of curiosity, did you try using crc32q? OVS data structures are
already aligned to 8 bytes. It would also be interesting to know if a
parallelized implementation is worthwhile, although my guess is that
the OVS flow key is not quite long enough.
