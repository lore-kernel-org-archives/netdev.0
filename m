From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Thu, 09 May 2013 02:51:18 +0200
Message-ID: <518AF306.8020307@redhat.com>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com> <CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com> <518968DF.9070008@redhat.com> <CAAsGZS5SrH7vJ=dd+2JkpAF7RS1UGv09kU+nCjw-qXhDV7SZTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183Ab3EIAvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 20:51:38 -0400
In-Reply-To: <CAAsGZS5SrH7vJ=dd+2JkpAF7RS1UGv09kU+nCjw-qXhDV7SZTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2013 10:32 PM, chetan loke wrote:
> On Tue, May 7, 2013 at 4:49 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
  [...]
>> So what's the point? If people see a WARN() in their kernel log they go
>> and complain on netdev that AF_PACKET is broken although its their
>> application?
>
> It's not complaining. Its called bug-reporting. Exactly, by removing
> the WARN you deprived the user from fixing him/her buggy application.

I'm sorry Chetan, I still don't see the justification. If the user does
crap, he'll get an -EINVAL when trying to setup an {R,T}X_RING wrongly.
How he access frames in his application and give them back to the kernel,
he will get from some docs. Do you really think that such users who write
crappy applications will care to look into the Linux kernel source code
to locate the warning and know that this might be in relation to their
code? Rather, in best case, they might send a bug report to netdev where
you have to tell them that it's not a kernel bug, but a bug in their user
space application.

Fact is, we currently do *not* warn him in case of TPACKET_V1 or TPACKET_V2
either, and yet it works for users! Neither do we warn in case of an
RX_RING nor TX_RING. So we *cannot* have double standards here, either we
do not warn at all or we do warn in *every* case. (What would give
justification to only WARN in TPACKET_V3 but not in TPACKET_V1 and
TPACKET_V2 while they all are based on the same underlying technology?)

And personally, I think the first case is more sane. Imho, the kernel is
not responsible to do *bug reports* to the user in this scenario. It makes
sense when you have syscalls and return an -EINVAL with possible cause
explanations in man pages, but we don't have this here. I think it doesn't
make sense to trigger a WARN instead, i.e. because it can also be triggered
maliciously/on purpose from user space. So the man-page of packet(7) would
then need a description saying that mis-usage will lead to kernel warnings?

Having that said, I also think that in af_packet.c's packet_set_ring() the
WARN with "Tx-ring is not supported." is too much and a simple -EINVAL or
better -EOPNOTSUPP or the like would have been sufficient. Currently we have
a WARN + -EINVAL for that case. But anyway, that's just a side note ...

If you think differently, then please go ahead and and put WARNs all over
the place for all other TPACKET versions as well and also for netlink's
mmap that is based on af_packet's mmap, which went in in 3.10, and also
document it in the man-page. I don't think this is reasonable.

Thanks,

Daniel
