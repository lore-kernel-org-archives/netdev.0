From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 16:04:50 -0800
Message-ID: <05986795-fcec-91fc-9fbd-9aed1d21bec8@hpe.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201135508.GB24547@oracle.com>
 <CALx6S35DCyi_2z1pqCLaB1bVyNykP_J3YaYEXUT8xxmuzyBDwA@mail.gmail.com>
 <aac93b13-6298-b9eb-7f3c-b074f22c388c@hpe.com>
 <CALx6S37aknqfrj66AP8hEfVT9X2OmBFK9GVa9A+0FpydPbm9kg@mail.gmail.com>
 <1e88fd64-0045-beb5-101a-a55b8f54bd08@hpe.com>
 <CALx6S34yWeU1_uGEEJvw=+a49V=vF_rgWVwpuJGzwFvwvQOkpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:48269 "EHLO
        g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752147AbcLBAEw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 19:04:52 -0500
In-Reply-To: <CALx6S34yWeU1_uGEEJvw=+a49V=vF_rgWVwpuJGzwFvwvQOkpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2016 02:12 PM, Tom Herbert wrote:
> We have consider both request size and response side in RPC.
> Presumably, something like a memcache server is most serving data as
> opposed to reading it, we are looking to receiving much smaller
> packets than being sent. Requests are going to be quite small say 100
> bytes and unless we are doing significant amount of pipelining on
> connections GRO would rarely kick-in. Response size will have a lot of
> variability, anything from a few kilobytes up to a megabyte. I'm sorry
> I can't be more specific this is an artifact of datacenters that have
> 100s of different applications and communication patterns. Maybe 100b
> request size, 8K, 16K, 64K response sizes might be good for test.

No worries on the specific sizes, it is a classic "How long is a piece 
of string?" sort of question.

Not surprisingly, as the size of what is being received grows, so too 
the delta between GRO on and off.

stack@np-cp1-c0-m1-mgmt:~/rjones2$ HDR="-P 1"; for r in 8K 16K 64K 1M; 
do for gro in on off; do sudo ethtool -K hed0 gro ${gro}; brand="$r gro 
$gro"; ./netperf -B "$brand" -c -H np-cp1-c1-m3-mgmt -t TCP_RR $HDR -- 
-P 12867 -r 128,${r} -o result_brand,throughput,local_sd; HDR="-P 0"; 
done; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 
AF_INET to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
Result Tag,Throughput,Local Service Demand
"8K gro on",9899.84,35.947
"8K gro off",7299.54,61.097
"16K gro on",8119.38,58.367
"16K gro off",5176.87,95.317
"64K gro on",4429.57,110.629
"64K gro off",2128.58,289.913
"1M gro on",887.85,918.447
"1M gro off",335.97,3427.587

So that gives a feel for by how much this alternative mechanism would 
have to reduce path-length to maintain the CPU overhead, were the 
mechanism to preclude GRO.

rick
