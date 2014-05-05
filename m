From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Mon, 5 May 2014 11:42:00 -0700
Message-ID: <CA+ZOOTNQJ59VrFhrtGT7EzhL7u0FnupuwOLqv-rJ0jQi2CP8Jg@mail.gmail.com>
References: <1398969880-8007-1-git-send-email-chema@google.com>
	<20140502.174928.1555908531689473830.davem@davemloft.net>
	<CA+ZOOTP88BJ-keuR5NznCgbDVPyzugWkdsVYjKkk5yGOBbkddQ@mail.gmail.com>
	<20140502.225252.1865694187680020950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:53999 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbaEESmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 14:42:01 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so8595538iec.1
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 11:42:00 -0700 (PDT)
In-Reply-To: <20140502.225252.1865694187680020950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 2, 2014 at 7:52 PM, David Miller <davem@davemloft.net> wrote:
>> Once you get the L3 proto and noff/toff, you get everything. The
>> rationale of adding toff/noff is that it's very similar to poff, which
>> we already have.
>
> But you're implementation is calling a function to do all of that work
> already, just to get only the transport header and then throwing away
> all of the other useful bits that function is calculating, so you'll
> end up doing it twice which is wasted work.
The problem here is that (classic) BPF works only with 2 registers. We
need at least 2 fields to get a valid point in the packet, namely the
offset and the protocol of the inner-most header (either L3 or L4).
The idea of this patch is to run the flow dissector twice, once to get
the protocol type, and a second to get the offset (this patch
implements the offset part of the L4 header). This is 2 calls, but it
provides flow dissection inside BPF.

I guess we could have this call return 2 values, one in A, the other
in X. This is strange in BPF, but we could do it (and then the user
should probably push one of the values right away if she wants to use
it later). Does it sound good?

> We can probably add an extension to AF_PACKET which provides the flow
> key at the end of the tpacket3_hdr if a certain socket option is set.
>
> That would provide the transport header as well as a side effect, and
> be much more powerful and efficient than this particular BPF
> instruction.
I'm not sure whether I follow this. The goal is to be able to access
the inner-most headers inside BPF, not in userland by calling
getsockopt().

-Chema
