From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Sun, 28 Jun 2015 10:20:40 -0700
Message-ID: <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com>
 <558DF24A.1040504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:37918 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbbF1RUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 13:20:43 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Sun, 28 Jun 2015 11:20:43 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id E821C1FF0043
	for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 11:11:50 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5SHIGGc36503738
	for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 10:18:16 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5SHKekG016504
	for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 11:20:41 -0600
In-Reply-To: <558DF24A.1040504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-06-26 17:46, Rick Jones wrote:
> On 06/26/2015 04:09 PM, Tom Herbert wrote:
>> Add calls to gro_cells infrastructure to do GRO when receiving on a 
>> tunnel.
>> 
>> Testing:
>> 
>> Ran 200 netperf TCP_STREAM instance
>> 
>> - With fix (GRO enabled on VXLAN interface)
>> 
>>    Verify GRO is happening.
>> 
>>    9084 MBps tput
>>    3.44% CPU utilization
>> 
>> - Without fix (GRO disabled on VXLAN interface)
>> 
>>    Verified no GRO is happening.
>> 
>>    9084 MBps tput
>>    5.54% CPU utilization
> 
> This has been an area of interest so:
> 
> Tested-by: Rick Jones <rick.jones2@hp.com>
> 
> Some single-stream results between two otherwise identical systems
> with 82599ES NICs in them, one running a 4.1.0-rc1+ kernel from a
> davem tree from a while ago, the other running 4.1.0+ from a davem
> tree pulled yesterday upon which I've applied the patch.
> 
> Netperf command used:
> 
> netperf -l 30 -H <IP> -t TCP_MAERTS -c -- -O
> throughput,local_cpu_util,local_cpu_peak_util,local_cpu_peak_id,local_sd
> 
> First, inbound to the unpatched system from the patched:
> 
> 
> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.0.21 () port 0 AF_INET : demo
> Throughput Local Local   Local   Local
>            CPU   Peak    Peak    Service
>            Util  Per CPU Per CPU Demand
>            %     Util %  ID
> 5487.42    6.01  99.83   0       2.872
> 5580.83    6.20  99.16   0       2.911
> 5445.52    5.68  98.92   0       2.734
> 5653.36    6.24  99.80   0       2.891
> 5187.56    5.66  97.41   0       2.858
> 
> Second, inbound to the patched system from the unpatched:
> 
> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.0.22 () port 0 AF_INET : demo
> Throughput Local Local   Local   Local
>            CPU   Peak    Peak    Service
>            Util  Per CPU Per CPU Demand
>            %     Util %  ID
> 6933.29    3.19  93.67   3       1.208
> 7031.35    3.34  95.08   3       1.244
> 7006.28    3.27  94.55   3       1.223
> 6948.62    3.09  93.20   3       1.165
> 7007.80    3.22  94.34   3       1.206
> 
> Comparing the service demands shows a > 50% reduction in overhead.

Rick, in your test, are you seeing gro becoming effective on the vxlan 
interface
with the 82599ES nic ? (ie, tcpdump on the vxlan interface shows larger 
frames
than the mtu of that interface, and kernel trace shows 
vxlan_gro_receive() being hit)

Throughputs of 5.5 Gbps (or the improved 7Gbs) leads me to suspect that 
gro is still not effective
in your test on the vxlan interface with the 82588ES nic - Because, when 
vxlan gro became effective with the patch
I suggested earlier, I could see throughput of ~8.5 Gbps on that nic.
