From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: Re: How do I receive vlan tags on an AF_PACKET socket in 3.4 kernel?
Date: Fri, 2 Aug 2013 11:03:41 +0200
Message-ID: <CAMJ=MEeE1UmJ2ndZ1_uMe+0Wgd20pA=iMRuqezCe0xF5g=Xwtw@mail.gmail.com>
References: <CAMJ=MEe4cvp7-fwbCnq7SLM=44Zy8Jrz35FwRoWG-ytahdPRQA@mail.gmail.com>
 <1375193392.10515.28.camel@edumazet-glaptop> <CAMJ=MEdfn2uPHbNQZ1LOytOqwFTbAyV1ZtxOW8NomLCZJq+caQ@mail.gmail.com>
 <1375280187.10515.92.camel@edumazet-glaptop> <CAMJ=MEeLRQTROpj4LBJ2b--dqyxBUKPcW7F=q9qdqxm_4kHL7g@mail.gmail.com>
 <51F9226F.30202@redhat.com> <1375283370.10515.100.camel@edumazet-glaptop>
 <CAMJ=MEcZBU9e+X3w5EFv3+FfKq5K7nKpF+Qc4XWYOFq7apKprw@mail.gmail.com>
 <1375303651.10515.110.camel@edumazet-glaptop> <CAMJ=MEfZbCzQAzA-G9ooZQrwjR2vf7FGf4p66J0H6Eo2Xtdw0A@mail.gmail.com>
 <51FB6A9D.2050002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:42084 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755010Ab3HBJED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 05:04:03 -0400
Received: by mail-ob0-f172.google.com with SMTP id er7so717512obc.17
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 02:04:02 -0700 (PDT)
In-Reply-To: <51FB6A9D.2050002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 2, 2013 at 10:15 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 08/01/2013 11:24 AM, Ronny Meeus wrote:
>>
>> On Wed, Jul 31, 2013 at 10:47 PM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>>>
>>> On Wed, 2013-07-31 at 22:01 +0200, Ronny Meeus wrote:
>>>>
>>>> On Wed, Jul 31, 2013 at 5:09 PM, Eric Dumazet <eric.dumazet@gmail.com>
>>>> wrote:
>>>>>
>>>>> On Wed, 2013-07-31 at 16:42 +0200, Daniel Borkmann wrote:
>>>>>
>>>>>> You can use bpfc (git://github.com/borkmann/netsniff-ng.git), it also
>>>>>> has
>>>>>> an extensive man page. That should probably do it:
>>>>>>
>>>>>> $ cat foo
>>>>>> ld vlant
>>>>>> jneq #4094, drop
>>>>>> ret #-1
>>>>>> drop: ret #0
>>>>>>
>>>>>> $ bpfc foo
>>>>>> { 0x20, 0, 0, 0xfffff02c },
>>>>>> { 0x15, 0, 1, 0x00000ffe },
>>>>>> { 0x6, 0, 0, 0xffffffff },
>>>>>> { 0x6, 0, 0, 0x00000000 },
>>>>>
>>>>>
>>>>
>>>> Thanks Daniel, this is very useful information.
>>>> I have cloned the repo and compiled the tool myself. It will be very
>>>> useful in the future.
>>>>
>>>>> Thanks Daniel.
>>>>>
>>>>> If the load of this BPF fails (because its an old kernel), then load
>>>>> your old filter.
>>>>>
>>>>
>>>> I created a small test application after I backported the filter code
>>>> to the 3.4 kernel.
>>>> I instrumented the kernel with a printk at the moment the
>>>> vlan_tx_tag_get call is done to see the actual value of the vlan tag
>>>> since it did not work initially.
>>>>
>>>> These are the packets displayed by tcpdump:
>>>>
>>>> tcpdump: WARNING: eth-ntb: no IPv4 address assigned
>>>> tcpdump: verbose output suppressed, use -v or -vv for full protocol
>>>> decode
>>>> listening on eth-ntb, link-type EN10MB (Ethernet), capture size 65535
>>>> bytes
>>>> 00:18:49.233283 06:00:00:00:00:80 > f7:00:00:00:ff:ff, ethertype
>>>> 802.1Q (0x8100), length 64:
>>>>          0x0000:  f700 0000 ffff 0600 0000 0080 8100 affe
>>>>          0x0010:  08ab 0014 0000 0000 0f00 0001 0096 6000
>>>>          0x0020:  0096 0000 0001 0000 000d 0000 0000 0000
>>>>          0x0030:  0000 0000 0000 0000 0000 0000 0000 0000
>>>>
>>>> So the Vlan is 0xffe and the priority/CFI field is 0xA.
>>>> Apparently the value I need to  use in the filter is 0xaffe to make it
>>>> work. Is this normal or is this a bug in the kernel?
>>>>
>>>> This is the filter I used:
>>>> { 0x20, 0, 0, 0xfffff02c }
>>>> { 0x15, 0, 1, 0x0000affe }
>>>> { 0x06, 0, 0, 0x00000800 }
>>>> { 0x06, 0, 0, 0x00000000 }
>>>>
>>>> And this is the trace of the kernel and my application:
>>>>
>>>> [12529.357172] BPF_S_ANC_VLAN_TAG: affe
>>>> packets received:          1
>>>> [12533.020743] BPF_S_ANC_VLAN_TAG: affe
>>>> packets received:          2
>>>> [12536.667159] BPF_S_ANC_VLAN_TAG: affe
>>>> packets received:          3
>>>> [12540.343857] BPF_S_ANC_VLAN_TAG: affe
>>>> packets received:          4
>>>
>>>
>>> Right, vlan_tx_tag_get() gets the whole tag, so you want to mask A with
>>> 0xfff before the compare (to strip the prio)
>>>
>>> ld vlant
>>> and #4095
>>> jneq #4094, drop
>>> ret #-1
>>> drop: ret #0
>>>
>>> or something like that.
>>
>>
>> OK the receiving side is clear now. Thanks.
>>
>> Now the sending side.
>> I created an application that sends packets using libpcap. These
>> packets are full Ethernet packets, including VLAN tags etc.
>> If I connect a PC running Wireshark to the Ethernet port I'm sending
>> on I receive the packets, no issues.
>>
>> If a start on the device that is sending the packets also the receive
>> application I created before I do not receive anything.
>> This is because the filter attached to the kernel by this application
>> is checking the VLAN tag in metadata of the buffer, which is in this
>> case not filled in.
>> If I do not attach a filter to the receiving application all packets I
>> send are also received by the receiving application, which is what I
>> expect since all packets sent on a raw socket are received by all
>> other sockets listening on the same interface.
>>
>> I have the feeling that there is something wrong with the current
>> implementation.
>> In my opinion, the same VLAN processing as done for packets received
>> from the network (strip vlan and put it in the meta data) should be
>> done on packets that are sent by an application just before passing
>> them to other sockets listening on the same interface.
>> Right?
>
>
> Nope, we already had this discussion in the past [1]. ;-)
>
> The vlan id is in skb->vlan_id when vlan accel is on, or in the packet
> itself when vlan accel off. Thus, you can distinguish accelerated traffic
> from non-accelerated one as well.
>

Not completely correct in my opinion.
The vlan is never present in the packet anymore. It is always put in
the skb->vlan_id, also for non-accelerated environments.

> If you want to filter for it, you need to extend your BPF filter by adding
> an ethernet type/vlan id check in the packet itself in case the loaded
> vlant instruction does not equal the id that you're looking for, thus this
> is being done as a fallback. And actually libpcap is supposed to do the same
> in their filter compiler.

This is an option, but it costs performance and like I said before,
the vlan is always removed by the kernel.

>  [1] http://article.gmane.org/gmane.linux.network/254454
