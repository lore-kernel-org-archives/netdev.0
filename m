From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Wed, 27 Sep 2017 06:35:40 -0700
Message-ID: <645e7a39-c172-5882-5dd9-f038430114d1@gmail.com>
References: <cover.1506297988.git.daniel@iogearbox.net>
 <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
 <20170926211342.0c8e72b0@redhat.com> <59CAB17D.5090204@iogearbox.net>
 <20170927112604.1284f536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33173 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752895AbdI0Nfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 09:35:54 -0400
Received: by mail-pf0-f193.google.com with SMTP id h4so6858016pfk.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 06:35:54 -0700 (PDT)
In-Reply-To: <20170927112604.1284f536@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2017 02:26 AM, Jesper Dangaard Brouer wrote:
> On Tue, 26 Sep 2017 21:58:53 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
> 
>> On 09/26/2017 09:13 PM, Jesper Dangaard Brouer wrote:
>> [...]
>>> I'm currently implementing a cpumap type, that transfers raw XDP frames
>>> to another CPU, and the SKB is allocated on the remote CPU.  (It
>>> actually works extremely well).  
>>
>> Meaning you let all the XDP_PASS packets get processed on a
>> different CPU, so you can reserve the whole CPU just for
>> prefiltering, right? 
> 
> Yes, exactly.  Except I use the XDP_REDIRECT action to steer packets.
> The trick is using the map-flush point, to transfer packets in bulk to
> the remote CPU (single call IPC is too slow), but at the same time
> flush single packets if NAPI didn't see a bulk.
> 
>> Do you have some numbers to share at this point, just curious when
>> you mention it works extremely well.
> 
> Sure... I've done a lot of benchmarking on this patchset ;-)
> I have a benchmark program called xdp_redirect_cpu [1][2], that collect
> stats via tracepoints (atm I'm limiting bulking 8 packets, and have
> tracepoints at bulk spots, to amortize tracepoint cost 25ns/8=3.125ns)
> 
>  [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_kern.c
>  [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_redirect_cpu_user.c
> 
> Here I'm installing a DDoS program that drops UDP port 9 (pktgen
> packets) on RX CPU=0.  I'm forcing my netperf to hit the same CPU, that
> the 11.9Mpps DDoS attack is hitting.
> 
> Running XDP/eBPF prog_num:4
> XDP-cpumap      CPU:to  pps            drop-pps    extra-info
> XDP-RX          0       12,030,471     11,966,982  0          
> XDP-RX          total   12,030,471     11,966,982 
> cpumap-enqueue    0:2   63,488         0           0          
> cpumap-enqueue  sum:2   63,488         0           0          
> cpumap_kthread  2       63,488         0           3          time_exceed
> cpumap_kthread  total   63,488         0           0          
> redirect_err    total   0              0          
> 
> $ netperf -H 172.16.0.2 -t TCP_CRR  -l 10 -D1 -T5,5 -- -r 1024,1024
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate         
> bytes  Bytes  bytes    bytes   secs.    per sec   
> 
> 16384  87380  1024     1024    10.00    12735.97   
> 16384  87380 
> 
> The netperf TCP_CRR performance is the same, without XDP loaded.
> 

Just curious could you also try this with RPS enabled (or does this have
RPS enabled). RPS should effectively do the same thing but higher in the
stack. I'm curious what the delta would be. Might be another interesting
case and fairly easy to setup if you already have the above scripts.

Thanks,
John

[...]
