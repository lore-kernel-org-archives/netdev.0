From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 21 Sep 2015 15:36:41 -0700
Message-ID: <CALx6S349QY_U8KVtnwDc_yFMXdZ9h1WvnpjWU9FYPTNuQ0yt7w@mail.gmail.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
	<20150921122422.GA31092@oracle.com>
	<CALx6S34gmbEybQKmsL2=0wGh+LjktBLSimpOCrxWUyTYFFUhfA@mail.gmail.com>
	<20150921212624.GD3861@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38883 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186AbbIUWgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 18:36:42 -0400
Received: by igxx6 with SMTP id x6so67860199igx.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 15:36:41 -0700 (PDT)
In-Reply-To: <20150921212624.GD3861@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 2:26 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (09/21/15 10:33), Tom Herbert wrote:
>> >
>> > Some things that were not clear to me from the patch-set:
>> >
>> > The doc statses that we re-assemble packets the "stated length" -
>> > but how will the receiver know the "stated length"?
>>
>> BPF program returns the length of the next message. In my testing so
>> far I've been using HTTP/2 which defines a frame format with first 3
>> bytes being header length field . The BPF program (using LLVM/Clang--
>> thanks Alexei!) is just:
>
> Maybe I dont see something about the mux/demux here (I have to
> take a closer look at reserve_psock/unreserve_psock), but
> will every tcp segment have a 3 byte length in the payload?
>
No, there is no provision in TCP that application layer headers align
with TCP segments or that message boundaries are respected with TCP
segments. What we need to do, which you're probably doing for RDS, is
do message delineation on the stream as a sequence of:

1) Read protocol header to determine message length (BPF used here)
2) Read data up to the length of the message
3) Deliver message
4) Goto #1 (i.e. process next message in the stream).

> Not every TCP segment in the RDS-TCP case will have a RDS header,
> thus the comments before rds_send_xmit(), thus applying the bpf filter
> to a TCP segment holding some "from-the-middle" piece of the RDS dgram
> may not be possible
>
>> > the notes say one can "accept()" over a kcm socket- but "accept()"
>> > is itself a connection-oriented concept- one does not accept() on
>     :
>> The accept method is overloaded on KCM sockets to do the socket
>> cloning operation. This is unrelated to TCP semantics, connection
>> management is performed on TCP sockets (i.e. before being attached to
>> a KCM multiplexor).
>
> If possible,it might be better to use some other
> glibc-func/name/syscall/sockopt/whatever
> for this, rather than overloading accept().. feels like that would
> keep the semantics cleaner, and probably less likely to trip
> up on accept code in the kernel..
>
I'll a look at alternatives, but I sort of think this is okay since
the semantics of accept are defined per protocol (in this case the
"protocol" is KCM).

Thanks,
Tom

> --Sowmini
