From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: tcp_probe: allow more advanced ingress
 filtering by mark
Date: Fri, 23 Aug 2013 17:28:21 +0200
Message-ID: <52177F95.4010005@redhat.com>
References: <1377267393-24604-1-git-send-email-dborkman@redhat.com> <1377270813.8828.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab3HWP21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 11:28:27 -0400
In-Reply-To: <1377270813.8828.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2013 05:13 PM, Eric Dumazet wrote:
> On Fri, 2013-08-23 at 16:16 +0200, Daniel Borkmann wrote:
>> Currently, the tcp_probe snooper can either filter packets by a given
>> port (handed to the module via module parameter e.g. port=80) or lets
>> all TCP traffic pass (port=0, default). When a port is specified, the
>> port number is tested against the sk's source/destination port. Thus,
>> if one of them matches, the information will be further processed for
>> the log.
>>
>> As this is quite limited, allow for more advanced filtering possibilities
>> which can facilitate debugging/analysis with the help of the tcp_probe
>> snooper. Therefore, similarly as added to BPF machine in commit 7e75f93e
>> ("pkt_sched: ingress socket filter by mark"), add the possibility to
>> use skb->mark as a filter.
>>
>> If the mark is not being used otherwise, this allows ingress filtering
>> by flow (e.g. in order to track updates from only a single flow, or a
>> subset of all flows for a given port) and other things such as dynamic
>> logging and reconfiguration without removing/re-inserting the tcp_probe
>> module, etc. Simple example:
>>
>>    insmod net/ipv4/tcp_probe.ko fwmark=8888 full=1
>>    ...
>>    iptables -A INPUT -i eth4 -t mangle -p tcp --dport 22 \
>>             --sport 60952 -j MARK --set-mark 8888
>>    [... sampling interval ...]
>>    iptables -D INPUT -i eth4 -t mangle -p tcp --dport 22 \
>>             --sport 60952 -j MARK --set-mark 8888
>>
>> The current option to filter by a given port is still being preserved. A
>> similar approach could be done for the sctp_probe module as a follow-up.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>
> Well, why not adding ability to load/use a BPF filter instead ? ;)

Hehe. ;-)

I think this patch is minimal and least intrusive and for observing flows
the skb->mark would provide an easy job for us of quickly configuring and
altering a filter during runtime through iptables or other tools.

If we would tell the user to load some BPF bytecode first through tool <xyz>,
we would need an additional interface of injecting this into tcp_probe, and
the ability to atomically change a filter at run-time. Likely, that the
biggest use-case would be to filter particular flows in order to observe
TCP params, I think the whole BPF machinery would be sort of overkill for
that, although you know I like playing with BPF. ;-)

So I think these 15 lines of code from this patch are less intrusive and
more clean than the alternative.
