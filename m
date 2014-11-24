From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-timestamp: Fix a documentation typo
Date: Mon, 24 Nov 2014 17:38:21 -0500
Message-ID: <CA+FuTSe8pjpUUpStfEHsuZ2Row9=MHVPH0S-MjUxiauBSNMOsg@mail.gmail.com>
References: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
 <CA+FuTSenSVXP-=hH+erpoE7yz1HbF8n9PeD_Xof-W=3GaQ6OFA@mail.gmail.com> <CALCETrU6tjwZoSCdfXnnhRy5H0uG9B8h5ftu9tA42iBuLXTQog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:49646 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaKXWiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 17:38:52 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so7197311qab.30
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 14:38:51 -0800 (PST)
In-Reply-To: <CALCETrU6tjwZoSCdfXnnhRy5H0uG9B8h5ftu9tA42iBuLXTQog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Is user code supposed to rely on this and, further, on the fact that the
>>> counter starts at zero?  If not, how else is user code supposed to match
>>> outgoing data to timestamps?
>>
>> That is correct. The per-socket counter is reset when
>> SOF_TIMESTAMPING_OPT_ID is set. On datagram sockets, it returns the
>> packet number since the reset. On stream sockets, it returns the byte
>> offset since the reset.
>>
>
> It might be worth tweaking the docs at some point to make this clearer.

Good point. The commit message is apparently more informative than the
actual documentation.

>>> Also, is it intentional that the payload data associated with the tx
>>> timestamp is (I think) the full outgoing packet including lower-layer
>>> headers?
>>
>> Absolutely not. I'll look into that right away. It doesn't on ACK, and
>> should certainly not expose this info in the other cases, either.
>
> Then I won't start trying to decode it :)

The datagram feature existed before I added the counter and stream
support, so returning the entire packet in that case is legacy
behavior, I suppose. I did not intend to expose network headers for
the new stream socket interface, though.

> TBH, all I looked at was the packet size, which matched the full
> link-layer packet.
>
> Also, the address returned by recvmsg appeared to be garbage instead
> of 0.0.0.0 (or something meaningful, whatever that would be).
>
>>
>>> And, finally, would it be possible to attach IP_PKTINFO to the looped
>>> timestamp?  That way I could finally update my fancy ping program to
>>> track which outgoing interface was used for a request.
>>
>> If socket option IP_PKTINFO is set, you want to receive in_pktinfo for
>> any packet that happens to be queued onto the error queue? Both
>> SKB_EXT_ERR(skb) and PKTINFO_SKB_CB(skb) use the control block to
>> store data that is later encoded in a cmsg, so there may not be enough
>> room to hold both. I'll take a look.
>
> I don't really care what the mechanism is, but it would be really nice
> if I could see what interface the send timestamp is associated with.

Okay. I'll see if I can cook something up.

> Also, thanks for this new feature.  It's great!

Thanks!

> --Andy
