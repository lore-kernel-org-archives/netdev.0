From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-timestamp: Fix a documentation typo
Date: Tue, 25 Nov 2014 13:01:52 -0500
Message-ID: <CA+FuTSeB65X+kJ46QOwkshf65DQOP37pTq3dziSbF=kU3KXRHA@mail.gmail.com>
References: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
 <CA+FuTSenSVXP-=hH+erpoE7yz1HbF8n9PeD_Xof-W=3GaQ6OFA@mail.gmail.com>
 <CALCETrU6tjwZoSCdfXnnhRy5H0uG9B8h5ftu9tA42iBuLXTQog@mail.gmail.com> <CA+FuTSe8pjpUUpStfEHsuZ2Row9=MHVPH0S-MjUxiauBSNMOsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36051 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaKYSCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:02:23 -0500
Received: by mail-qg0-f48.google.com with SMTP id q107so812886qgd.7
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 10:02:22 -0800 (PST)
In-Reply-To: <CA+FuTSe8pjpUUpStfEHsuZ2Row9=MHVPH0S-MjUxiauBSNMOsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just sent an initial patch set for comments.

On Mon, Nov 24, 2014 at 5:38 PM, Willem de Bruijn <willemb@google.com> wrote:
>>>> Is user code supposed to rely on this and, further, on the fact that the
>>>> counter starts at zero?  If not, how else is user code supposed to match
>>>> outgoing data to timestamps?
>>>
>>> That is correct. The per-socket counter is reset when
>>> SOF_TIMESTAMPING_OPT_ID is set. On datagram sockets, it returns the
>>> packet number since the reset. On stream sockets, it returns the byte
>>> offset since the reset.
>>>
>>
>> It might be worth tweaking the docs at some point to make this clearer.
>
> Good point. The commit message is apparently more informative than the
> actual documentation.

I did not update the documentation yet, as that would conflict with your
patch, Andy.

>>>> Also, is it intentional that the payload data associated with the tx
>>>> timestamp is (I think) the full outgoing packet including lower-layer
>>>> headers?
>>>
>>> Absolutely not. I'll look into that right away. It doesn't on ACK, and
>>> should certainly not expose this info in the other cases, either.
>>
>> Then I won't start trying to decode it :)
>
> The datagram feature existed before I added the counter and stream
> support, so returning the entire packet in that case is legacy
> behavior, I suppose. I did not intend to expose network headers for
> the new stream socket interface, though.

Since the interface with headers is legacy and cannot be changed,
you could actually use it. The counter + PKTINFO hopefully give the
same information in a cleaner way.

>> TBH, all I looked at was the packet size, which matched the full
>> link-layer packet.
>>
>> Also, the address returned by recvmsg appeared to be garbage instead
>> of 0.0.0.0 (or something meaningful, whatever that would be).
>>
>>>
>>>> And, finally, would it be possible to attach IP_PKTINFO to the looped
>>>> timestamp?  That way I could finally update my fancy ping program to
>>>> track which outgoing interface was used for a request.
>>>
>>> If socket option IP_PKTINFO is set, you want to receive in_pktinfo for
>>> any packet that happens to be queued onto the error queue? Both
>>> SKB_EXT_ERR(skb) and PKTINFO_SKB_CB(skb) use the control block to
>>> store data that is later encoded in a cmsg, so there may not be enough
>>> room to hold both. I'll take a look.
>>
>> I don't really care what the mechanism is, but it would be really nice
>> if I could see what interface the send timestamp is associated with.
>
> Okay. I'll see if I can cook something up.

I decided to make the feature independent from the timestamps. There
may be other uses for finding out the egress device. The two metadata
structures are looped back together with the same payload, though, so
it still allows correlation of all fields.
