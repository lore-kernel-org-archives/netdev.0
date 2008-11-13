From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Thu, 13 Nov 2008 13:59:04 +0000
Message-ID: <20081113135904.GA23103@ff.dom.local>
References: <20081113114814.sslsf752hwbvsh5o@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Mailing List <netdev@vger.kernel.org>
To: Sami Farin <safari-kernel@safari.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:51180 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbYKMN7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:59:11 -0500
Received: by yx-out-2324.google.com with SMTP id 8so399299yxm.1
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 05:59:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081113114814.sslsf752hwbvsh5o@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-11-2008 12:48, Sami Farin wrote:
> On Thu, Nov 13, 2008 at 07:15:43 +0000, Jarek Poplawski wrote:
>> On 11-11-2008 22:47, Sami Farin wrote:
>> ...
>>> When 2.6.27.5 was sending:
>>>
>>> 2008-11-11T21:16:13.488287Z IP (tos 0x0, ttl 255, id 10323, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0x96a4), 4123538094:4123545194(7100) ack 1017886112 win 710 <nop,nop,timestamp 418352 372760162>
>>> 2008-11-11T21:16:13.620018Z IP (tos 0x0, ttl 255, id 10328, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xf1d0), 4123545194:4123552294(7100) ack 1017886112 win 710 <nop,nop,timestamp 418458 372760270>
>>> 2008-11-11T21:16:13.751751Z IP (tos 0x0, ttl 255, id 10333, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xc685), 4123552294:4123559394(7100) ack 1017886112 win 710 <nop,nop,timestamp 418562 372760374>
>>>
>>> I noticed it's 7152 bytes a packet!
>>> Is this a new trick in 2.6.27 or 2.6.26?
>>> But:
>>> <3>[ 1583.914947] 0000:00:19.0: eth0: Jumbo Frames not supported.
>>>
>> Could you check for TSO (and maybe turn this off) with ethtool?
> 
> It was off:
> 
> # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off

I guess the later options are off as well? What is mtu btw?

> 
> Sometimes I am also sending over 15000 byte packets according to
> tcpdump.  What I'd like to know is:
> 1) How can I get tcpdump to show the actual packets I am sending,
>    without needing to buy another computer for sniffing the packets?

Since a driver and a hardware are later in the queue I doubt you can
do this with tcpdump easily without some loop or something... Maybe
you should try with driver's debug option? (But I'm not an expert.)

> 2) What does it really mean when 15000 byte packet is sent?
>    Can other packets be queued normally "in between" or am I doomed
>    to 250 ms latency, if I happen to e.g. ping one microsecond after
>    the first of these packets is being sent?
>    Or are many packets of the same stream just coalesced into one
>    bigger, if there are no other packets from other streams in
>    between, so that is looks neater when tcpdump is used?

Packets could be coalesced e.g. by TCP if TSO/GSO is on, but an actual
packet sent to the wire should be not more than mtu (15000 if "jumbo"
frames etc. are supported). Since you have warnings about this it looks
like some of your configs could be different between kernel versions.

Your stats from the first message show some differences: class htb 1:19
and qdisc sfq 19 show very different values. HTB can count gso segments,
then it seems some application could try this TSO or GSO. So to compare
these two kernels you should first find the reason why packets are
prepared differenly, and I doubt it's because of some HTB or SFQ change.

Anyway these TSO/GSO/jumbo_frames are usually bad idea with packet
schedulers (or need more tweaking - e.g. sfq quantum).

Jarek P.
