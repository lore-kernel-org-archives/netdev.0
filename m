From: Robert Hoo <robert.hu@linux.intel.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 01 Sep 2017 21:48:09 +0800
Message-ID: <1504273689.50064.21.camel@linux.intel.com>
References: <1503127531-134546-1-git-send-email-robert.hu@intel.com>
         <20170825111921.061713c8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        davem@davemloft.net, tariqt@mellanox.com, kyle.leet@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40359 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752000AbdIANsL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 09:48:11 -0400
In-Reply-To: <20170825111921.061713c8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 11:19 +0200, Jesper Dangaard Brouer wrote:
> (please don't use BCC on the netdev list, replies might miss the list in cc)
> 
> Comments inlined below:
> 
> On Fri, 25 Aug 2017 10:24:30 +0800 Robert Hoo <robert.hu@intel.com> wrote:
> 
> > From: Robert Ho <robert.hu@intel.com>
> > 
> > It's hard to benchmark 40G+ network bandwidth using ordinary
> > tools like iperf, netperf. I then tried with pktgen multiqueue sample
> > scripts, but still cannot reach line rate.
> 
> The pktgen_sample02_multiqueue.sh does not use burst or skb_cloning.
> Thus, the performance will suffer.
> 
> See the samples that use the burst feature:
>   pktgen_sample03_burst_single_flow.sh
>   pktgen_sample05_flow_per_thread.sh
> 
> With the pktgen "burst" feature, I can easily generate 40G.  Generating
> 100G is also possible, but often you will hit some HW limits before the
> pktgen limit.  I experienced hitting both (1) PCIe Gen3 x8 limit, and (2)
> memory bandwidth limit.

Thanks Jesper for review. Sorry for late reply, I do this part time.

I just tried 'pktgen_sample03_burst_single_flow.sh' and 'pktgen_sample05_flow_per_thread.sh'
cmd:
	./pktgen_sample05_flow_per_thread.sh -i ens801 -s 1500 -m 3c:fd:fe:9d:6f:f0 -t 2 -v -x -d 192.168.0.107
	./pktgen_sample03_burst_single_flow.sh -i ens801 -s 1500 -m 3c:fd:fe:9d:6f:f0 -t 2 -v -x -d 192.168.0.107

indeed, they can achieve nearly 40G. (though still slightly less than my 
script). pktgen_sample03 and pktgen_sample05 can approximately achieve 38xxxMb/sec ~ 39xxxMb/sec;
my script can achieve 40xxxMb/sec ~ 41xxxMb/sec. (threads >= 2)

So a general question: is it still necessary to continue my sample06_numa_awared_queue_irq_affinity work? as sample03
and sample05 already approximately achieved 40G line rate.

> 
> 
> > I then derived this NUMA awared irq affinity sample script from
> > multi-queue sample one, successfully benchmarked 40G link. I think this can
> > also be useful for 100G reference, though I haven't got device to test.
> 
> Okay, so your issue was really related to NUMA irq affinity.  I do feel
> that IRQ tuning lives outside the realm of the pktgen scripts, but
> looking closer at your script, I it doesn't look like you change the
> IRQ setting which is good.  

Sorry I don't quite understand above. I changed the irq affinities.
See "echo $thread > /proc/irq/${irq_array[$i]}/smp_affinity_list".
You would not like me to change it? I can restore them to original at the end
of the script.
> 
> You introduce some helper functions take makes it possible to extract
> NUMA information in the shell script code, really cool.  I would like
> to see these functions being integrated into the function.sh file.

Yes, it is doable, if you maintainer think so.
> 
>  
> > This script simply does:
> > Detect $DEV's NUMA node belonging.
> > Bind each thread (processor from that NUMA node) with each $DEV queue's
> > irq affinity, 1:1 mapping.
> > How many '-t' threads input determines how many queues will be
> > utilized.
> > 
> > Tested with Intel XL710 NIC with Cisco 3172 switch.
> > 
> > It would be even slightly better if the irqbalance service is turned
> > off outside.
> 
> Yes, if you don't turn-off (kill) irqbalance it will move around the
> IRQs behind your back...

Yes; while the experiment result turns out it affects just very little.
> 
>  
> > Referrences:
> > https://people.netfilter.org/hawk/presentations/LCA2015/net_stack_challenges_100G_LCA2015.pdf
> > http://www.intel.cn/content/dam/www/public/us/en/documents/reference-guides/xl710-x710-performance-tuning-linux-guide.pdf
> > 
> > Signed-off-by: Robert Hoo <robert.hu@intel.com>
> > ---
> >  ...tgen_sample06_numa_awared_queue_irq_affinity.sh | 132 +++++++++++++++++++++
> >  1 file changed, 132 insertions(+)
> >  create mode 100755 samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
> > 
> > diff --git a/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh b/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
> > new file mode 100755
> > index 0000000..f0ee25c
> > --- /dev/null
> > +++ b/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
> > @@ -0,0 +1,132 @@
> > +#!/bin/bash
> > +#
> > +# Multiqueue: Using pktgen threads for sending on multiple CPUs
> > +#  * adding devices to kernel threads which are in the same NUMA node
> > +#  * bound devices queue's irq affinity to the threads, 1:1 mapping
> > +#  * notice the naming scheme for keeping device names unique
> > +#  * nameing scheme: dev@thread_number
> > +#  * flow variation via random UDP source port
> > +#
> > +basedir=`dirname $0`
> > +source ${basedir}/functions.sh
> > +root_check_run_with_sudo "$@"
> > +#
> > +# Required param: -i dev in $DEV
> > +source ${basedir}/parameters.sh
> > +
> > +get_iface_node()
> > +{
> > +	echo `cat /sys/class/net/$1/device/numa_node`
> 
> Here you could use the following shell trick to avoid using "cat":
> 
>  echo $(</sys/class/net/$1/device/numa_node)

Thanks for teaching. Indeed this is more concise.
> 
> It looks like you don't handle the case of -1, which indicate non-NUMA
> system.  You need to use something like::
> 
> get_iface_node()
> {
>     local node=$(</sys/class/net/$1/device/numa_node)
>     if [[ $node == -1 ]]; then
> 	echo 0
>     else
> 	echo $node
>     fi
> }

Yes, I can amend in v2.
> 
> 
> > +}
> > +
> > +get_iface_irqs()
> > +{
> > +	local IFACE=$1
> > +	local queues="${IFACE}-.*TxRx"
> > +
> > +	irqs=$(grep "$queues" /proc/interrupts | cut -f1 -d:)
> > +	[ -z "$irqs" ] && irqs=$(grep $IFACE /proc/interrupts | cut -f1 -d:)
> > +	[ -z "$irqs" ] && irqs=$(for i in `ls -Ux /sys/class/net/$IFACE/device/msi_irqs` ;\
> > +		do grep "$i:.*TxRx" /proc/interrupts | grep -v fdir | cut -f 1 -d : ;\
> > +	    done)
> 
> Nice that you handle all these different methods.  I personally look
> in /proc/irq/*/$IFACE*/../smp_affinity_list , like (copy-paste):
> 
> echo " --- Align IRQs ---"
> # I've named my NICs ixgbe1 + ixgbe2
> for F in /proc/irq/*/ixgbe*-TxRx-*/../smp_affinity_list; do
>    # Extract irqname e.g. "ixgbe2-TxRx-2"
>    irqname=$(basename $(dirname $(dirname $F))) ;
>    # Substring pattern removal
>    hwq_nr=${irqname#*-*-}
>    echo $hwq_nr > $F
>    #grep . -H $F;
> done
> grep -H . /proc/irq/*/ixgbe*/../smp_affinity_list
> 
> Maybe I should switch to use:
>    /sys/class/net/$IFACE/device/msi_irqs/*
>  
> 
> > +	[ -z "$irqs" ] && echo "Error: Could not find interrupts for $IFACE"
> 
> In the error case you should let the script die.  There is a helper
> function for this called "err" (where first arg is the exitcode, which
> is useful to detect the reason your script failed).

Yes, I noticed that helper function and changed some of my original "echo Error"s;
this is a missing in my code clear/tidy work. I can amend in v2.
> 
> 
> > +	echo $irqs
> > +}
> 
> > +get_node_cpus()
> > +{
> > +	local node=$1
> > +	local node_cpu_list
> > +	local node_cpu_range_list=`cut -f1- -d, --output-delimiter=" " \
> > +			/sys/devices/system/node/node$node/cpulist`
> > +
> > +	for cpu_range in $node_cpu_range_list
> > +	do
> > +		node_cpu_list="$node_cpu_list "`seq -s " " ${cpu_range//-/ }`
> > +	done
> > +
> > +	echo $node_cpu_list
> > +}
> > +
> > +
> > +# Base Config
> > +DELAY="0"        # Zero means max speed
> > +COUNT="20000000"   # Zero means indefinitely
> > +[ -z "$CLONE_SKB" ] && CLONE_SKB="0"
> > +
> > +# Flow variation random source port between min and max
> > +UDP_MIN=9
> > +UDP_MAX=109
> > +
> > +node=`get_iface_node $DEV`
> > +irq_array=(`get_iface_irqs $DEV`)
> > +cpu_array=(`get_node_cpus $node`)
> 
> Nice trick to generate an array.
> 
> > +
> > +[ $THREADS -gt ${#irq_array[*]} -o $THREADS -gt ${#cpu_array[*]}  ] && \
> > +	err 1 "Thread number $THREADS exceeds: min (${#irq_array[*]},${#cpu_array[*]})"
> > +
> > +# (example of setting default params in your script)
> > +if [ -z "$DEST_IP" ]; then
> > +    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
> > +fi
> > +[ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
> > +
> > +# General cleanup everything since last run
> > +pg_ctrl "reset"
> > +
> > +# Threads are specified with parameter -t value in $THREADS
> > +for ((i = 0; i < $THREADS; i++)); do
> > +    # The device name is extended with @name, using thread number to
> > +    # make then unique, but any name will do.
> > +    # Set the queue's irq affinity to this $thread (processor)
> > +    thread=${cpu_array[$i]}
> > +    dev=${DEV}@${thread}
> > +    echo $thread > /proc/irq/${irq_array[$i]}/smp_affinity_list
> > +    echo "irq ${irq_array[$i]} is set affinity to `cat /proc/irq/${irq_array[$i]}/smp_affinity_list`"
> > +
> > +    # Add remove all other devices and add_device $dev to thread
> > +    pg_thread $thread "rem_device_all"
> > +    pg_thread $thread "add_device" $dev
> > +
> > +    # select queue and bind the queue and $dev in 1:1 relationship
> > +    queue_num=$i
> > +    echo "queue number is $queue_num"
> > +    pg_set $dev "queue_map_min $queue_num"
> > +    pg_set $dev "queue_map_max $queue_num"
> > +
> > +    # Notice config queue to map to cpu (mirrors smp_processor_id())
> > +    # It is beneficial to map IRQ /proc/irq/*/smp_affinity 1:1 to CPU number
> > +    pg_set $dev "flag QUEUE_MAP_CPU"
> > +
> > +    # Base config of dev
> > +    pg_set $dev "count $COUNT"
> > +    pg_set $dev "clone_skb $CLONE_SKB"
> > +    pg_set $dev "pkt_size $PKT_SIZE"
> > +    pg_set $dev "delay $DELAY"
> > +
> > +    # Flag example disabling timestamping
> > +    pg_set $dev "flag NO_TIMESTAMP"
> > +
> > +    # Destination
> > +    pg_set $dev "dst_mac $DST_MAC"
> > +    pg_set $dev "dst$IP6 $DEST_IP"
> > +
> > +    # Setup random UDP port src range
> > +    pg_set $dev "flag UDPSRC_RND"
> > +    pg_set $dev "udp_src_min $UDP_MIN"
> > +    pg_set $dev "udp_src_max $UDP_MAX"
> > +done
> > +
> > +# start_run
> > +echo "Running... ctrl^C to stop" >&2
> > +pg_ctrl "start"
> > +echo "Done" >&2
> > +
> > +# Print results
> > +for ((i = 0; i < $THREADS; i++)); do
> > +    thread=${cpu_array[$i]}
> > +    dev=${DEV}@${thread}
> > +    echo "Device: $dev"
> > +    cat /proc/net/pktgen/$dev | grep -A2 "Result:"
> > +done
> 
> 
> 
