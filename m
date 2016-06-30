From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] net: samples: pktgen mode samples/tests
 for qdisc layer
Date: Thu, 30 Jun 2016 09:39:57 -0700
Message-ID: <57754B5D.2040303@gmail.com>
References: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
 <20160629200326.16491.11589.stgit@john-Precision-Tower-5810>
 <20160630102329.00750272@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34919 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbcF3Qkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 12:40:41 -0400
Received: by mail-oi0-f43.google.com with SMTP id r2so73168819oih.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 09:40:09 -0700 (PDT)
In-Reply-To: <20160630102329.00750272@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-30 01:23 AM, Jesper Dangaard Brouer wrote:
> On Wed, 29 Jun 2016 13:03:26 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> This adds samples for pktgen to use with new mode to inject pkts into
>> the qdisc layer. This also doubles as nice test cases to test any
>> patches against qdisc layer.

[...]

>> +#
>> +# Benchmark script:
>> +#  - developed for benchmarking egress qdisc path, derived from
>> +#    ingress benchmark script.
>> +#

As you probably gathered 'derived' is giving me too much credit here
its more like cut'n'pasted from ingress benchmark scrip :)

>> +# Script for injecting packets into egress qdisc path of the stack
>> +# with pktgen "xmit_mode queue_xmit".
>> +#
>> +basedir=`dirname $0`
>> +source ${basedir}/functions.sh
>> +root_check_run_with_sudo "$@"
>> +
>> +# Parameter parsing via include
>> +source ${basedir}/parameters.sh
>> +# Using invalid DST_MAC will cause the packets to get dropped in
>> +# ip_rcv() which is part of the test
>> +[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
>> +[ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
>> +
>> +# Burst greater than 1 are invalid but allow users to specify it and
>> +# get an error instead of silently ignoring it.
>> +[ -z "$BURST" ] && BURST=1
> 
> In other scripts I've rejected this at this step, instead of depending
> on failure when sending the burst option to pktgen. Like:
> 
> https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen_sample04_many_flows.sh#L31-L33
> 

Agreed that is nicer. I had originally left it to make sure I was
catching the burst > 1 case in pktgen but will remove.

>> +
>> +# Base Config
>> +DELAY="0"        # Zero means max speed
>> +COUNT="10000000" # Zero means indefinitely
>> +
>> +# General cleanup everything since last run
>> +pg_ctrl "reset"
>> +
>> +# Threads are specified with parameter -t value in $THREADS
>> +for ((thread = 0; thread < $THREADS; thread++)); do
>> +    # The device name is extended with @name, using thread number to
>> +    # make then unique, but any name will do.
>> +    dev=${DEV}@${thread}
>> +
>> +    # Add remove all other devices and add_device $dev to thread
>> +    pg_thread $thread "rem_device_all"
>> +    pg_thread $thread "add_device" $dev
>> +
>> +    # Base config of dev
>> +    pg_set $dev "flag QUEUE_MAP_CPU"
>> +    pg_set $dev "count $COUNT"
>> +    pg_set $dev "pkt_size $PKT_SIZE"
>> +    pg_set $dev "delay $DELAY"
>> +    pg_set $dev "flag NO_TIMESTAMP"
>> +
>> +    # Destination
>> +    pg_set $dev "dst_mac $DST_MAC"
>> +    pg_set $dev "dst $DEST_IP"
>> +
>> +    # Inject packet into RX path of stack
> 
> Hmmm, maybe above comment need to be adjusted...

Yep.

> 
>> +    pg_set $dev "xmit_mode queue_xmit"
>> +
>> +    # Burst allow us to avoid measuring SKB alloc/free overhead
> 
> This comment is confusing, maybe just remove. Didn't think burst is a
> valid use-case.

Yep.
