From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 15:38:35 -0700
Message-ID: <55415D6B.7070009@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>	 <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>	 <5541535E.1060908@plumgrid.com> <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34369 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbbD2Wii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:38:38 -0400
Received: by iget9 with SMTP id t9so139260ige.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:38:37 -0700 (PDT)
In-Reply-To: <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/15 3:19 PM, Eric Dumazet wrote:
> On Wed, 2015-04-29 at 14:55 -0700, Alexei Starovoitov wrote:
>> On 4/28/15 9:14 PM, Eric Dumazet wrote:
>>> On Tue, 2015-04-28 at 19:11 -0700, Alexei Starovoitov wrote:
>>>
>>>
>>> This looks buggy.
>>>
>>> skb can be put on a queue, so skb->next and skb->prev cannot be reused,
>>> or queues will be corrupted.
>>
>> don't see the bug yet.
>> Any layer that wants to do such queueing should do skb_share_check
>> first. Just like ip_rcv does. So everything in IP world should
>> work fine, because it will be operating on clean cloned skb.
>
> Really this is what _you_ think is needed, so that your patch can fly.
>
> In current state of the stack, the skb_share_check() is done where we
> know that packet _might_ be delivered to multiple end points
> (deliver_skb() does atomic_inc(&skb->users) )
>
> But RPS/RFS/GRO do not care of your new rule.
>
> Yes, before reaching __netif_receive_skb_core(), packets are supposed to
> belong to the stack. We are supposed to queue them, without adding a
> check for skb->users being one or not, and eventually add an expensive
> memory allocation/copy.
>
> We are not going to add an extra check just to make pktgen rx fast.
> pktgen will have to comply to existing rules.

I'm not making and not suggesting any new rules.
ip_rcv is doing this skb_share_check() not because of pktgen rx,
but because there can be taps and deliver_skb() as you said.
gro has a different interface and this pktgen cannot benchmark it.
rps/rfs is not benchmarkable but this approach either.
To me this is all fine. I'm not trying to do a universal
benchmarking tool. This one is dumb and simple and primarily
oriented to benchmark changes to netif_receive_skb and ingress
qdisc only. I'm not suggesting to use it everywhere.
I already mentioned in cover letter:
"The profile dump looks as expected for RX of UDP packets
without local socket except presence of __skb_clone."
Clearly I'm not suggesting to use pktgen rx to optimize IP stack
and not suggesting at all that stack should assume users!=1
when skb hits netif_receive_skb. Today at the beginning of
netif_receive_skb we know that users==1 without checking.
I'm not changing that assumption.
Just like pktgen xmit path is cheating little bit while
benchmarking TX, I'm cheating a little bit with users!=1 on RX.
