From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v2 2/2] net: samples: pktgen mode samples/tests
 for qdisc layer
Date: Thu, 30 Jun 2016 10:23:29 +0200
Message-ID: <20160630102329.00750272@redhat.com>
References: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
	<20160629200326.16491.11589.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbcF3IXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 04:23:35 -0400
In-Reply-To: <20160629200326.16491.11589.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Jun 2016 13:03:26 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> This adds samples for pktgen to use with new mode to inject pkts into
> the qdisc layer. This also doubles as nice test cases to test any
> patches against qdisc layer.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  .../pktgen/pktgen_bench_xmit_mode_queue_xmit.sh    |   70 ++++++++++++++++++++
>  1 file changed, 70 insertions(+)
>  create mode 100755 samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
> 
> diff --git a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
> new file mode 100755
> index 0000000..eee06cc
> --- /dev/null
> +++ b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
> @@ -0,0 +1,70 @@
> +#!/bin/bash
> +#
> +# Benchmark script:
> +#  - developed for benchmarking egress qdisc path, derived from
> +#    ingress benchmark script.
> +#
> +# Script for injecting packets into egress qdisc path of the stack
> +# with pktgen "xmit_mode queue_xmit".
> +#
> +basedir=`dirname $0`
> +source ${basedir}/functions.sh
> +root_check_run_with_sudo "$@"
> +
> +# Parameter parsing via include
> +source ${basedir}/parameters.sh
> +# Using invalid DST_MAC will cause the packets to get dropped in
> +# ip_rcv() which is part of the test
> +[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
> +[ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
> +
> +# Burst greater than 1 are invalid but allow users to specify it and
> +# get an error instead of silently ignoring it.
> +[ -z "$BURST" ] && BURST=1

In other scripts I've rejected this at this step, instead of depending
on failure when sending the burst option to pktgen. Like:

https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen_sample04_many_flows.sh#L31-L33

> +
> +# Base Config
> +DELAY="0"        # Zero means max speed
> +COUNT="10000000" # Zero means indefinitely
> +
> +# General cleanup everything since last run
> +pg_ctrl "reset"
> +
> +# Threads are specified with parameter -t value in $THREADS
> +for ((thread = 0; thread < $THREADS; thread++)); do
> +    # The device name is extended with @name, using thread number to
> +    # make then unique, but any name will do.
> +    dev=${DEV}@${thread}
> +
> +    # Add remove all other devices and add_device $dev to thread
> +    pg_thread $thread "rem_device_all"
> +    pg_thread $thread "add_device" $dev
> +
> +    # Base config of dev
> +    pg_set $dev "flag QUEUE_MAP_CPU"
> +    pg_set $dev "count $COUNT"
> +    pg_set $dev "pkt_size $PKT_SIZE"
> +    pg_set $dev "delay $DELAY"
> +    pg_set $dev "flag NO_TIMESTAMP"
> +
> +    # Destination
> +    pg_set $dev "dst_mac $DST_MAC"
> +    pg_set $dev "dst $DEST_IP"
> +
> +    # Inject packet into RX path of stack

Hmmm, maybe above comment need to be adjusted...

> +    pg_set $dev "xmit_mode queue_xmit"
> +
> +    # Burst allow us to avoid measuring SKB alloc/free overhead

This comment is confusing, maybe just remove. Didn't think burst is a
valid use-case.

> +    pg_set $dev "burst $BURST"
> +done
> +
> +# start_run
> +echo "Running... ctrl^C to stop" >&2
> +pg_ctrl "start"
> +echo "Done" >&2
> +
> +# Print results
> +for ((thread = 0; thread < $THREADS; thread++)); do
> +    dev=${DEV}@${thread}
> +    echo "Device: $dev"
> +    cat /proc/net/pktgen/$dev | grep -A2 "Result:"
> +done
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
