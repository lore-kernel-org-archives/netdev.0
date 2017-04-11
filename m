From: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibmveth: Support to enable LSO/CSO for Trunk VEA.
Date: Tue, 11 Apr 2017 09:53:06 +0530
Message-ID: <1379a627-97da-f5af-3a5e-54cbb81bb7ac@linux.vnet.ibm.com>
References: <1491559079-10855-1-git-send-email-ksiva@linux.vnet.ibm.com>
 <20170408.114515.1339820744697810446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        brking@linux.vnet.ibm.com, seroyer@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34364 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750721AbdDKEXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 00:23:15 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3B4EESa181057
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 00:23:15 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29r99uf6dh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 00:23:14 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ksiva@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 00:23:14 -0400
In-Reply-To: <20170408.114515.1339820744697810446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-sending as my earlier response had some HTML subparts.

Let me give some background before I answer your queries.

In IBM PowerVM environment, ibmveth driver supports largesend and 
checksum offload today, but only for virtual ethernet adapters (VEA) 
which are not configured in "Trunk mode".  In trunk mode, one cannot 
enable checksum and largesend offload capabilities. Without these 
offloads enabled, the performance numbers are not good. This patch is to 
enable these offloads for "Trunk" VEAs.

The following shows a typical configuration for network packet flow, 
when VMs in the PowerVM server have their network virtualized and 
communicate to external world.

         VM (ibmveth) <=> PowerVM Hypervisor <=>  PowerVM I/O Server VM 
( ibmveth in "Trunk mode" <=> OVS <=> Physical NIC ) <=>  External Network

As you can see the packets originating in VM will travel through local 
ibmveth driver and then to PowerVM Hypervisor, then it gets delivered to 
ibmveth driver configured in "Trunk" mode in I/O Server, which is then 
bridged by OVS to external network via Physical NIC.  To have largesend 
and checksum offload enabled end to end, from VM up to Physical NIC, 
ibmveth needs to support these offload capabilities when configured in 
"Trunk" mode too.

Before this patch, when a VM communicates with external network (in a 
configuration similar to above), throughput numbers were not so good 
(~1.5 Gbps) and with the patch, I see ~9.4 Gbps throughput for a 10G NIC 
(iperf used for measurements).

On 4/9/2017 12:15 AM, David Miller wrote:
> From: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
> Date: Fri,  7 Apr 2017 05:57:59 -0400
>
>> Enable largesend and checksum offload for ibmveth configured in trunk mode.
>> Added support to SKB frag_list in TX path by skb_linearize'ing such SKBs.
>>
>> Signed-off-by: Sivakumar Krishnasamy <ksiva@linux.vnet.ibm.com>
>
> Why is linearization necessary?
>
> It would seem that the gains you get from GRO are nullified by
> linearizing the SKB and thus copying all the data around and
> allocating buffers.
>
When Physical NIC has GRO enabled and when OVS bridges these packets, 
OVS vport send code will end up calling dev_queue_xmit, which in turn 
calls validate_xmit_skb.

validate_xmit_skb has the below code snippet,

     if (netif_needs_gso(skb, features)) {
         struct sk_buff *segs;

         segs = skb_gso_segment(skb, features);     <=== Segments the 
GSO packet into MTU sized segments.

When the OVS outbound vport is ibmveth, netif_needs_gso returns 
positively if the SKB has a frag_list and if the driver doesn't support 
the same (NETIF_F_FRAGLIST feature).  So all the packets received by 
ibmveth are of MSS size (or lesser) due to the above code.

On a 10G physical NIC, the maximum throughput achieved was 2.2 Gbps due 
to the above segmentation in validate_xmit_skb. With the patch to 
linearize the SKB, the throughput increased to 9 Gbps (and ibmveth 
received packets without being segmented). This is ~4X improvement even 
though we end up allocating buffers and copying data.

> Finally, all of that new checksumming stuff looks extremely
> suspicious.  You have to explain why that is happening and why it
> isn't because this driver is doing something incorrectly.
>
> Thanks.
>
We are now enabling support for OVS and improving bridging performance 
in IBM's PowerVM environment, which brings in these new offload 
requirements for ibmveth driver configured in Trunk mode.

Please let me know if you need more details.

Regards,
Siva K
