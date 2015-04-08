From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 16:53:19 +0200
Message-ID: <552540DF.6030504@iogearbox.net>
References: <5524B339.1070403@plumgrid.com> <5524E878.7070803@iogearbox.net> <20150408090520.GA2057@nanopsycho.orion> <552508E8.5050203@iogearbox.net> <55250D92.6030702@iogearbox.net> <55251556.4040900@mojatatu.com> <55251F9F.2050508@iogearbox.net> <55252611.3040109@mojatatu.com> <20150408131417.GA28656@casper.infradead.org> <55252CDD.8020503@iogearbox.net> <20150408133415.GD2057@nanopsycho.orion> <55252FEF.40201@iogearbox.net> <55253289.8020306@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45431 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754284AbbDHOxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 10:53:31 -0400
In-Reply-To: <55253289.8020306@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 03:52 PM, Jamal Hadi Salim wrote:
> On 04/08/15 09:41, Daniel Borkmann wrote:
>> On 04/08/2015 03:34 PM, Jiri Pirko wrote:
>>> Wed, Apr 08, 2015 at 03:27:57PM CEST, daniel@iogearbox.net wrote:
>>>> On 04/08/2015 03:14 PM, Thomas Graf wrote:
>>>>> On 04/08/15 at 08:58am, Jamal Hadi Salim wrote:
>>>>>> On 04/08/15 08:31, Daniel Borkmann wrote:
>>>>>>> That means the tc's cls_u32
>>>>>>> sample selectors a la ip, ip6, udp, tcp, icmp don't work on ingress
>>>>>>> either,so in u32 speak you would need to do that by hand, but that
>>>>>>> doesn't work as you don't have the Ethernet type context available.
>>>>>>> Am I missing something? :)
>>>>>>
>>>>>> u32 works fine. I am sure i have tests which run these on both
>>>>>> in/egress.
>>>>>
>>>>> His point is that an u32 filter written for egress won't work at
>>>>> ingress because the offsets are different. This has always been the
>>>>> case and we can't break this behaviour either. I'm sure you have
>>>>> these weird negative offset u32 egress filters in your repertoire
>>>>> as well ;-)
>>>>
>>>> Okay, you can use negative offsets in cls_u32 to accomodate for
>>>> that; so yeah, you'd need to implement your filter differently
>>>> on ingress. That should also work on cls_bpf et al.
>>>
>>> That is certainly doable. But is that what we want? I don't think so. I
>>> would like to have the same for in/eg.
>>
>> I mean it's certainly a non-obvious hack, where user space has to
>> fix up something that the kernel should have gotten right in the
>> first place. :/
>
> Try something like:
> on ingress
> filter add dev eth0 parent ffff: protocol ip prio 6 u32 match ip src \
> 10.0.0.21/32 flowid 1:16 action ok
> and egress
> filter add dev eth0 parent 1: protocol ip prio 6 u32 match ip src \
> 10.0.0.21/32 flowid 1:16 action ok
>
> and see if you need negative offsets for anything.

Yep, that works because from tc side, you push down offsets where
it's assumed that ip, etc start at offset 0, and in u32_classify()
offsets are fixed up for ingress/egress via skb_network_offset()
stored in off.

> If you really must adjust in the kernel then use the indicators which
> tell you where you are at.
>
> Negative offsets are used if you must go beyond the network header. This
> has been the expectation so far (whether it is actions or classifiers),

Yes, exactly, meaning negative offsets need to be used no matter
whether from ingress or egress, but with the advantage to be able
to use the same u32 filter on both sides. Ok, I see. Need to think
about if we could easily do the same for BPF while keeping compat.

> example, here is something that mucks around with ethernet
> headers:
>
> tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
> match ip src 192.168.1.10/32 flowid 1:2 \
> action pedit munge offset -14 u16 set 0x0000 \
> munge offset -12 u32 set 0x00010100 \
> munge offset -8 u32 set 0x0aaf0100 \
> munge offset -4 u32 set 0x0008ec06 pipe \
> action mirred egress redirect dev eth1
