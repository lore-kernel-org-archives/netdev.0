From: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/1] NUMA aware scheduling per cpu vhost thread
Date: Tue, 27 Mar 2012 09:34:35 -0500
Message-ID: <2290046.f5KjQb758a@tomlt1.ibmoffice.com>
References: <1332460136.7730.19.camel@oc3660625478.ibm.com> <1510318.F8gXLSD366@tomlt1.ibmoffice.com> <4F6D0B24.1010300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F6D0B24.1010300@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, March 23, 2012 05:45:40 PM David Ahern wrote:
> On 3/23/12 12:32 PM, Thomas Lendacky wrote:
> > Quick description of the tests:
> >    TCP_RR and UDP_RR using 256 byte request/response size in 1, 10, 30
> >    and 60 instances
> >    TCP_STREAM and TCP_MAERTS using 256, 1K, 4K and 16K message sizes
> >    and 1 and 4 instances
> >    
> >    Remote host to VM using 1, 4, 12 and 24 VMs (2 vCPUs) with the tests
> >    running between an external host and each VM.
> >    
> >    Local VM to VM using 2, 4, 12 and 24 VMs (2 vCPUs) with the tests
> >    running between VM pairs on the same host (no TCP_MAERTS done in
> >    this situation).
> > 
> > For TCP_RR and UDP_RR tests I report the transaction rate as the
> > score and the transaction rate / KVMhost CPU% as the efficiency.
> > 
> > For TCP_STREAM and TCP_MAERTS tests I report the throughput in Mbps
> > as the score and the throughput / KVMhost CPU% as the efficiency.
> 
> Would you mind sharing the netperf commands you are running and an
> example of the math done to arrive at the summaries presented?

I'm actually using uperf not netperf.  Uperf allows me to launch
multiple instances of a test with one executable. I've provided the
XML profiles for the tests below.

The math is simply taking the score (for TCP_RR it is the tranaction
rate and for TCP_STREAM/TCP_MAERTS it is the throughput) and dividing
by the CPU utilization of the KVM host (obtained from running sar
during the test).

Here are the uperf profiles that were used. The destination,
instances and message sizes are set using environment variables.

TCP_RR
  <?xml version="1.0"?>
  <!--
   Note: uperf reports operations/second. A transaction is made up of
         two operations, so to get transactions/second (like netperf)
         you must divide the operations/second by 2.
  -->
  <profile name="TCP_RR">
   <group nprocs="$uperf_instances">
    <transaction iterations="1">
     <flowop type="connect" options="remotehost=$uperf_dest
       protocol=tcp"/>
     </transaction>
     <transaction duration="$uperf_duration">
      <flowop type="write" options="size=$uperf_tx_msgsize"/>
      <flowop type="read"  options="size=$uperf_rx_msgsize"/>
     </transaction>
     <transaction iterations="1">
      <flowop type="disconnect" />
     </transaction>
   </group>
  </profile>

UDP_RR:
 <?xml version="1.0"?>
 <!--
  Note: uperf reports operations/second. A transaction is made up of
        two operations, so to get transactions/second (like netperf)
        you must divide the operations/second by 2.
 -->
 <profile name="UDP_RR">
  <group nprocs="$uperf_instances">
   <transaction iterations="1">
    <flowop type="connect" options="remotehost=$uperf_dest
      protocol=udp"/>
   </transaction>
   <transaction duration="$uperf_duration">
    <flowop type="write" options="size=$uperf_tx_msgsize"/>
    <flowop type="read"  options="size=$uperf_rx_msgsize"/>
   </transaction>
   <transaction iterations="1">
    <flowop type="disconnect" />
   </transaction>
  </group>
 </profile>

TCP_STREAM:
  <?xml version="1.0"?>
  <profile name="TCP_STREAM">
   <group nprocs="$uperf_instances">
    <transaction iterations="1">
     <flowop type="connect" options="remotehost=$uperf_dest
       protocol=tcp"/>
    </transaction>
    <transaction duration="$uperf_duration">
     <flowop type="write" options="count=16 size=$uperf_tx_msgsize"/>
    </transaction>
    <transaction iterations="1">
     <flowop type="disconnect" />
    </transaction>
   </group>
  </profile>

TCP_MAERTS:
  <?xml version="1.0"?>
  <profile name="TCP_MAERTS">
   <group nprocs="$uperf_instances">
    <transaction iterations="1">
     <flowop type="accept"  options="remotehost=$uperf_dest
       protocol=tcp"/>
    </transaction>
    <transaction duration="$uperf_duration">
     <flowop type="read"  options="count=16 size=$uperf_rx_msgsize"/>
    </transaction>
    <transaction iterations="1">
     <flowop type="disconnect" />
    </transaction>
  </group>
 </profile>

Tom

> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

