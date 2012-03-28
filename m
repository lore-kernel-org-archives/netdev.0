From: Li Yu <raise.sail@gmail.com>
Subject: Re: a F-RTO question
Date: Wed, 28 Mar 2012 14:43:10 +0800
Message-ID: <4F72B2FE.6030906@gmail.com>
References: <4F7281ED.1060603@gmail.com> <CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com> <4F728EC9.1050302@gmail.com> <CAK6E8=cgHxQMXA9QVu6=v6OqRAd6v7-wsEpM9ENFhqDpn88GvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chao Pei <peichao85@gmail.com>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53947 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab2C1GnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 02:43:18 -0400
Received: by iagz16 with SMTP id z16so1059035iag.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 23:43:18 -0700 (PDT)
In-Reply-To: <CAK6E8=cgHxQMXA9QVu6=v6OqRAd6v7-wsEpM9ENFhqDpn88GvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA03=D4=C228=C8=D5 13:35, Yuchung Cheng =D0=B4=B5=C0:
> On Tue, Mar 27, 2012 at 9:08 PM, Li Yu<raise.sail@gmail.com>  wrote:
>> =D3=DA 2012=C4=EA03=D4=C228=C8=D5 11:49, Chao Pei =D0=B4=B5=C0:
>>
>>>> Hi,
>>>>
>>>>         I have a question about tcp_process_frto(), the below sour=
ce
>>>> code :
>>>>
>>>> static int tcp_process_frto(struct sock *sk, int flag)
>>>> {
>>>>         .....
>>>>
>>>>         if (!before(tp->snd_una, tp->frto_highmark)) {
>>>>                 tcp_enter_frto_loss(sk, ...);
>>>>                 return 1;
>>>>         }
>>>>
>>>>         .....
>>>>
>>>> }
>>>>
>>>>         As my understanding, the tp->frto_highmark likes tp->high_=
seq,
>>>> it saves the seqno SND_NXT when a TCP connection enters F-RTO phas=
e,
>>>> is it the variable "recovery" in NewReno? So I think that if snd_u=
na is
>>>> equal with or after frto_highmark, which means peer ack new data, =
so
>>>> why we enter Loss state here?
>>>>
>>>>         Thanks!
>>>>
>>>> Yu
>>>>
>>>>
>>>
>>> If snd_una advances to frto_highmark, it is likely that the hole wa=
s
>>> filled by the retransimitted packet, which means the original packe=
t
>>> was likely to have been lost.
>>> So, we should enter loss state.
>>>
>>
>> I do not agree with it, if snd_una advanced to frto_highmark, which =
means
>> peer acks whole window of data instead of just one segment, and
>> we can not make sure that reason of peer sends ack is whether it rec=
eived
>> original segment or retransmitted segment.
>>
>> Even, the reason is latter, it also means the netowrk already is
>> recovered from temporarily congestion or disordered state, so we als=
o should
>> not enter loss state.
> Like you said there is some ambiguity and F-RTO takes the conservativ=
e approach.
> You can find answers to your question in RFC 5682  (Section 2.2). Unl=
ess the RTO
> is proven to be spurious, TCP should reduce window and performs
> slow-start regardlessly.
>=20

I think I got it, if the new ack covers "frto_highmark",
it may mean the fast retransmitted segments are lost likely.

In RFC5682:

   If the first acknowledgment after the RTO retransmission covers the
   "recover" point at algorithm step (2a), there is not enough evidence
   that a non-retransmitted segment has arrived at the receiver after
   the timeout.  This is a common case when a fast retransmission is
   lost and has been retransmitted again after an RTO, while the rest o=
f
   the unacknowledged segments were successfully delivered to the TCP
   receiver before the retransmission timeout.  Therefore, the timeout
   cannot be declared spurious in this case.

And as Chao's words, if the RTO is proven, we should enter
slow-start then.

Thanks!

Yu
