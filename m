From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Thu, 1 Sep 2016 14:35:20 -0700
Message-ID: <57C89F18.5030807@gmail.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
 <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
 <20160829103047.3968a4d8@redhat.com>
 <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
 <20160829153905.50066865@redhat.com> <20160829175509.7ed19b89@redhat.com>
 <09886285-aeae-625d-9d0e-bec1c1944efe@mojatatu.com>
 <20160830153155.702868f5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35457 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754499AbcIAVfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:35:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so4863730pfg.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:35:36 -0700 (PDT)
In-Reply-To: <20160830153155.702868f5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-30 06:31 AM, Jesper Dangaard Brouer wrote:
> On Tue, 30 Aug 2016 08:13:15 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 
>> On 16-08-29 11:55 AM, Jesper Dangaard Brouer wrote:
>>> tc filter add dev mlx5p2 parent ffff: prio 4 protocol ip u32 match ip protocol 17 0xff match udp dst 9 0xffff flowid 1:1 action  
>>
>> Syntax is a little more convoluted  than that ;->. Try:
>>
>> sudo tc filter add dev eth0 parent ffff: prio 4 protocol ip u32 \
>> match ip protocol 17 0xff \
>> match ip dport 1900 0xffff \
>> flowid 1:1 \
>> action drop
> 
> I think I figured out why, match "udp dst" does not work.  It seems to
> depend on "nexthdr+0" which is an implicit variable, that for unknown
> reasons are not set in my original rule (above).
> 
> Before you suggestion I managed to match the udp port by manually
> defining the offset, assuming an IP-header is 20 bytes (no-options),
> like:
> 
> tc filter add dev $device parent ffff: prio 4 protocol ip \
> 	u32 \
> 	match ip protocol 17 0xff \
> 	match udp dst $udp_port 0xffff at 21\
> 	flowid 1:1 \
> 	action drop
> 
> You solution with "ip dport" also works, but man[1] tc-u32(8) also have
> a warning about "ip dport" size assumptions...
> 
> Updated my script to use "u32 match ip port":
>  https://github.com/netoptimizer/network-testing/commit/6449f6beb4d2
> 

FWIW the 'udp dst' notation is quit fragile in that it only reads an
offset into the packet where a udp dst port might be. More robust
solutions require the use of links.

I have a wrapper tool around the 'link' creation part of u32 that we
can probably show off at netconf. :)


>> Note, this will be more cycles than drop all.
> 
> Yes, that is the point ;-) XDP also does header parsing...
> 
