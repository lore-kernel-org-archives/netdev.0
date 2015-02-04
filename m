From: Avery Fay <avery@mixpanel.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of thousands
 of packets / sec)
Date: Wed, 4 Feb 2015 00:35:38 -0800
Message-ID: <CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
	<1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:41901 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932773AbbBDIfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 03:35:39 -0500
Received: by mail-qg0-f42.google.com with SMTP id q107so189626qgd.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 00:35:39 -0800 (PST)
In-Reply-To: <1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure, https://dl.dropboxusercontent.com/u/9777748/loop.pcap.gz

Also, no idea if it helps, but here's the traceroute:

HOST: apibalancer-wdc-05                          Loss%   Snt   Last
Avg  Best  Wrst StDev
  1.|-- 184.173.130.1-static.reverse.softlayer.com   0.0%    10    0.2
  1.9   0.2   9.6   3.1
  2.|-- 208.43.118.164-static.reverse.softlayer.com  0.0%    10    0.2
  0.2   0.2   0.3   0.0
  3.|-- ae8.bbr02.eq01.wdc02.networklayer.com        0.0%    10    1.2
  1.3   1.1   2.6   0.5
  4.|-- ash-b1-link.telia.net                        0.0%    10    1.2
  4.3   1.1  12.7   5.0
  5.|-- ash-bb3-link.telia.net                       0.0%    10    1.2
  2.6   1.1  15.0   4.4
  6.|-- atl-bb1-link.telia.net                       0.0%    10   13.4
 13.3  13.3  13.4   0.0
  7.|-- 213.248.94.220                               0.0%    10   14.2
 14.2  14.2  14.4   0.1
  8.|-- 130.207.254.6                                0.0%    10   14.2
 14.2  14.1  14.3   0.1
    |  `|-- 130.207.254.185
  9.|-- gateway2-rtr.gatech.edu                      0.0%    10   14.2
 14.3  14.1  14.8   0.2
    |  `|-- 143.215.254.97
 10.|-- 143.215.254.97                               0.0%    10   14.6
 14.6  14.4  14.7   0.1
    |  `|-- 143.215.253.114
 11.|-- 143.215.253.114                              0.0%    10   15.1
 14.7  14.5  15.1   0.2
 12.|-- ???                                         100.0    10    0.0
  0.0   0.0   0.0   0.0

On Wed, Feb 4, 2015 at 12:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-02-03 at 22:50 -0800, Avery Fay wrote:
>> Hello,
>>
>> Let me say first: if there's a better place to ask this, please point
>> me in that direction.
>>
>> We've been having huge packets / sec spikes in the past few days.
>> After some investigation, it looks like single connections are getting
>> stuck in a loop (see tcpdump below). Each "stuck" connection will
>> generate about 200kpps. It looks like our side is rejecting packets
>> with "packets rejects in established connections because of timestamp"
>> from netstat -s (internally PAWSEstab counter) and then generating an
>> additional packet that we send out. All of these connections originate
>> from georgia tech, but so far (not completely verified) it doesn't
>> seem like there's any pattern to the client/os other than the fact
>> that they're trying to make an https request to us.
>>
>> As a temporary countermeasure, we've disabled net.ipv4.tcp_timestamps,
>> which solves the immediate problem.
>>
>> Our server is 174.36.240.86 running Ubuntu 12.04 with kernel 3.13.0-35-generic
>>
>> The client is 128.61.57.205 and in this case almost certainly has user
>> agent (we found successful requests 10 seconds before the tcpdump with
>> same ip): Dalvik/2.1.0 (Linux; U; Android 5.0; XT1095
>> Build/LXE22.46-11)
>>
>> Beginning of tcpdump:
>
> ...
>
>>
>> At this point, it just repeats until some timeout is hit. I haven't
>> timed it, but probably one or two minutes.
>>
>> I guess I have a few questions:
>>
>> 1.) What's going on here? It looks like maybe there's some packet loss
>> and then connection termination gets stuck in a loop because the
>> client timestamp went down?
>> 2.) Is there a better way to mitigate this other than disabling
>> tcp_timestamps or blocking gatech ips?
>> 3.) Is this our problem (ok, obviously our problem since we're
>> affected but...), a kernel problem, or a gatech problem?
>>
>> I'd really appreciate any help on this,
>
> Would you have a pcap file instead ?
>
> It looks a middlebox is broken, I dont think Android could possibly send
> a frame with no payload, but with Push flag.
>
> Neal has some patches that add a rate limiting on DACKS, that we might
> upstream. (per socket rate limiting of 2 DACK per second)
>
> Thanks
>
>
>
