From: Ben Greear <greearb@candelatech.com>
Subject: Re: Slow ramp-up for single-stream TCP throughput on 4.2 kernel.
Date: Sun, 04 Oct 2015 10:05:44 -0700
Message-ID: <56115C68.1080803@candelatech.com>
References: <560F1672.5000602@candelatech.com>	<560F1F74.9010207@candelatech.com>	<CADVnQym4U_dVVRdOVhORvVabwFjSHTQJ_LbbbYtzWVu0=mAp_A@mail.gmail.com>	<56105AD2.7070906@candelatech.com> <CADVnQynKmhrpD63sF5aWPYo9f8L3wOMuEyACBnTdkzQQ=D1_uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	ath10k <ath10k@lists.infradead.org>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:55543 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbbJDRFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 13:05:46 -0400
In-Reply-To: <CADVnQynKmhrpD63sF5aWPYo9f8L3wOMuEyACBnTdkzQQ=D1_uA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/03/2015 06:20 PM, Neal Cardwell wrote:
> On Sat, Oct 3, 2015 at 6:46 PM, Ben Greear <greearb@candelatech.com> wrote:
>>
>>
>> On 10/03/2015 09:29 AM, Neal Cardwell wrote:
>>>
>>> On Fri, Oct 2, 2015 at 8:21 PM, Ben Greear <greearb@candelatech.com>
>>> wrote:
>>>>
>>>> Gah, seems 'cubic' related.  That is the default tcp cong ctrl
>>>> I was using (same in 3.17, for that matter).
>>>
>>>
>>> There have been recent changes to CUBIC that may account for this. If
>>> you could repeat your test with more instrumentation, eg "nstat", that
>>> would be very helpful.
>>>
>>> nstat > /dev/null
>>> # run one test
>>> nstat
>>>
>>> Also, if you could take a sender-side tcpdump trace of the test, that
>>> would be very useful (default capture length, grabbing just headers,
>>> is fine).
>>
>>
>> Here is nstat output:
>>
>> [root@ben-ota-1 ~]# nstat
>> #kernel
>> IpInReceives                    14507              0.0
>> IpInDelivers                    14507              0.0
>> IpOutRequests                   49531              0.0
>> TcpActiveOpens                  3                  0.0
>> TcpPassiveOpens                 2                  0.0
>> TcpInSegs                       14498              0.0
>> TcpOutSegs                      50269              0.0
>> UdpInDatagrams                  9                  0.0
>> UdpOutDatagrams                 1                  0.0
>> TcpExtDelayedACKs               43                 0.0
>> TcpExtDelayedACKLost            5                  0.0
>> TcpExtTCPHPHits                 483                0.0
>> TcpExtTCPPureAcks               918                0.0
>> TcpExtTCPHPAcks                 12758              0.0
>> TcpExtTCPDSACKOldSent           5                  0.0
>> TcpExtTCPRcvCoalesce            49                 0.0
>> TcpExtTCPAutoCorking            3                  0.0
>> TcpExtTCPOrigDataSent           49776              0.0
>> TcpExtTCPHystartTrainDetect     1                  0.0
>> TcpExtTCPHystartTrainCwnd       16                 0.0
>> IpExtInBcastPkts                8                  0.0
>> IpExtInOctets                   2934274            0.0
>> IpExtOutOctets                  74817312           0.0
>> IpExtInBcastOctets              640                0.0
>> IpExtInNoECTPkts                14911              0.0
>> [root@ben-ota-1 ~]#
>>
>>
>> And, you can find the pcap here:
>>
>> http://www.candelatech.com/downloads/cubic.pcap.bz2
>>
>> Let me know if you need anything else.
>
> Thanks! This is very useful. It looks like the sender is sending 3
> (and later 4) packets every ~1.5ms for the entirety of the trace. 3
> packets per burst is usually a hint that this may be related to TSQ.
>
> This slow-and-steady behavior triggers CUBIC's Hystart Train Detection
> to enter congestion avoidance at a cwnd of 16, which probably in turn
> leads to slow cwnd growth, since the sending is not cwnd-limited, but
> probably TSQ-limited, so cwnd does not grow in congestion avoidance
> mode. Probably most of the other congestion control modules do better
> because they stay in slow-start, which has a more aggressive criterion
> for growing cwnd.
>
> So this is probably at root due to the known issue with an interaction
> between the ath10k driver and the following change in 3.19:
>
>    605ad7f tcp: refine TSO autosizing
>
> There has been a lot of discussion about how to address the
> TSQ-related issues with this driver. For example, you might consider:
>
>    https://patchwork.ozlabs.org/patch/438322/
>
> But I am not sure of the latest status of that effort. Perhaps someone
> on the ath10k list will know.

If the guys in that thread cannot get a patch upstream, then there is
little chance I'd be able to make a difference.

I guess I'll just stop using Cubic.  Any suggestions for another
congestion algorithm to use?  I'd prefer something that worked well
in pretty much any network condition, of course, and it has to work with
ath10k.

We can also run some tests with 1G, 10G, ath10k, ath9k, and in conjunction
with network emulators and various congestion control algorithms.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
