From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some issues
Date: Wed, 02 Sep 2015 17:56:36 +0200
Message-ID: <55E71C34.1080504@iogearbox.net>
References: <20150814085807.GA30443@gmail.com> <55CDBC84.8020605@iogearbox.net> <55CDC51D.1060204@iogearbox.net> <20150817.140222.1763422851882964859.davem@davemloft.net> <55D492CC.6010602@iogearbox.net> <20150902000400.GA14821@gmail.com> <55E6C5AE.4060308@iogearbox.net> <20150902113553.GA3282@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58853 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbbIBP4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 11:56:39 -0400
In-Reply-To: <20150902113553.GA3282@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2015 01:35 PM, Ken-ichirou MATSUZAWA wrote:
> Thank you for the reply.
>
> On Wed, Sep 02, 2015 at 11:47:26AM +0200, Daniel Borkmann wrote:
>> On 09/02/2015 02:04 AM, Ken-ichirou MATSUZAWA wrote:
>>> Talking about skb_copy path, original skb's shared info is accessed
>>> only in copy_skb_header, to get gso related field. As a result of
>>
>> It's still not correct. The thing is you can neither call skb_copy() nor
>> skb_clone() on netlink mmaped skbs. For example, skb_copy_bits() would
>
> I am sorry for the lack of explanation.
> And I am afraid I misunderstand...
>
> Updated pointers to its data area in a mmaped netlink skb is only
> its tail. Head, data and end will not be updated. skb_copy() calls
>
>      int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
>
> as its argument, "offset" is always 0 and "len" is skb->len. In
> skb_copy_bits() both "start" and "copy" are skb->len, which means
> "len - copy" is always 0 so that retuns 0 before accessing shared
> info.
>
> I don't know the situation is intended or not, it seems that
> skb_copy() for a mmaped skb will not access its shared info.

Okay, right, since it's all linear, but ...

> After that, copy_skb_header() will set newly allocate skb's (wrong)
> gso fields, I asked we should clear it or not.

... here still we access skb_shinfo() from the mmap'ed skb, which we
are simply not allowed (despite whether resetting fields later on as
you suggest or not), for two reasons: I think (will start experimenting
more with it tomorrow), you would get an out of bounds access here in
case the skb->data is the last slot in the ring buffer and reaches
exactly to the ring buffer end. And (despite that), it's also hard
to maintain - the next one adding a new shared info member will very
likely oversee this special case in netlink here, thus the issue would
then simply be reintroduced over and over.

Thanks,
Daniel
