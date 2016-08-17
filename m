From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: linearize early if it's not GSO
Date: Tue, 16 Aug 2016 21:49:31 -0300
Message-ID: <20160817004931.GF3110@localhost.localdomain>
References: <a4bc263e62ced9f5790932f11e7d829c36566808.1471386679.git.marcelo.leitner@gmail.com>
 <57B39AC5.7000002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbcHQAth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 20:49:37 -0400
Content-Disposition: inline
In-Reply-To: <57B39AC5.7000002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 12:59:17AM +0200, Daniel Borkmann wrote:
> On 08/17/2016 12:35 AM, Marcelo Ricardo Leitner wrote:
> > Because otherwise when crc computation is still needed it's way more
> > expensive than on a linear buffer to the point that it affects
> > performance.
> > 
> > It's so expensive that netperf test gives a perf output as below:
> > 
> > Overhead  Shared Object        Symbol
> >    69,44%  [kernel]             [k] gf2_matrix_square
> >     2,84%  [kernel]             [k] crc32_generic_combine.part.0
> >     2,78%  [kernel]             [k] _raw_spin_lock_bh
> 
> What kernel is this, seems not net kernel?
> 
> $ git grep -n gf2_matrix_square
> $ git grep -n crc32_generic_combine
> $
> 
> Maybe RHEL? Did you consider backporting 6d514b4e7737 et al?

Damn, correct. I'll post a v2 later with a proper changelog.
No I hadn't considered backporting that commit.

Now from a different environment, upstream kernel, without the patch, using
mlx4 and perf record -a -- sleep 5 during netperf (Xeon E5-2690 v3, 24 cpus):

Overhead  Command         Shared Object       Symbol
  16,85%  netserver       [kernel.vmlinux]    [k] crc32_generic_shift
   3,46%  swapper         [kernel.vmlinux]    [k] intel_idle
   2,00%  netserver       [kernel.vmlinux]    [k] __pskb_pull_tail
   1,73%  netserver       [kernel.vmlinux]    [k] copy_user_enhanced_fast_string
   1,72%  swapper         [kernel.vmlinux]    [k] crc32_generic_shift
   1,64%  swapper         [kernel.vmlinux]    [k] poll_idle
   1,59%  netserver       [kernel.vmlinux]    [k] memcpy_erms
   1,57%  netserver       [kernel.vmlinux]    [k] fib_table_lookup
   1,47%  netserver       [kernel.vmlinux]    [k] _raw_spin_lock
   1,37%  netserver       [kernel.vmlinux]    [k] __slab_free
   1,32%  netserver       [sctp]              [k] sctp_packet_transmit
   1,18%  netserver       [kernel.vmlinux]    [k] skb_copy_datagram_iter

With the patch:
Overhead  Command         Shared Object        Symbol
   4,71%  swapper         [kernel.vmlinux]     [k] intel_idle
   2,11%  netserver       [kernel.vmlinux]     [k] copy_user_enhanced_fast_string
   1,45%  netserver       [kernel.vmlinux]     [k] memcpy_erms
   1,29%  swapper         [kernel.vmlinux]     [k] memcpy_erms
   1,28%  netserver       [kernel.vmlinux]     [k] fib_table_lookup
   1,27%  netserver       [kernel.vmlinux]     [k] __slab_free
   1,27%  swapper         [kernel.vmlinux]     [k] fib_table_lookup
   1,26%  netserver       [kernel.vmlinux]     [k] kmem_cache_free
   1,14%  netserver       [kernel.vmlinux]     [k] _raw_spin_lock
   1,07%  netserver       [kernel.vmlinux]     [k] __pskb_pull_tail
   1,06%  netserver       [kernel.vmlinux]     [k] skb_copy_datagram_iter
   1,04%  netserver       [sctp]               [k] sctp_packet_transmit
   1,04%  swapper         [kernel.vmlinux]     [k] __pskb_pull_tail
   1,01%  swapper         [mlx4_en]            [k] mlx4_en_process_rx_cq
   0,99%  swapper         [kernel.vmlinux]     [k] native_queued_spin_lock_slowpath
   0,96%  swapper         [kernel.vmlinux]     [k] _raw_spin_lock
   0,89%  swapper         [sctp]               [k] sctp_packet_transmit

Without the patch:
# netperf -H 192.168.10.1 -l 10 -t SCTP_STREAM -cC -- -m 12000
SCTP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

212992 212992  12000    10.00      2896.13   3.34     3.88     2.267   2.635


With the patch:
# netperf -H 192.168.10.1 -l 10 -t SCTP_STREAM -cC -- -m 12000
SCTP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

212992 212992  12000    10.00      3444.89   3.88     3.02     2.216   1.721

And without the patch netperf fluctuates more as there are more packet
drops and netserver is constantly at 100% cpu usage.

Thanks,
Marcelo
