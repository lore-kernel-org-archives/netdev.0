From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] Bug in pskb_trim_rcsum()
Date: Mon, 17 Jul 2006 22:26:06 -0400
Message-ID: <1153189567.3226.3.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:24278 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751288AbWGRBge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 21:36:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 17 July 2006 08:17, Herbert Xu wrote:
> Wei Yongjun <yjwei@nanjing-fnst.com> wrote:
> >  So if I want to trim a skb, I think I must do a checksum even if
the
> > skb->ip_summed is CHECKSUM_UNNECESSARY.
>
> Nope.  CHECKSUM_UNNECESSARY means that the hardware has already
> verified the checksum to be correct for the given protocol.
> Trimming a packet does not affect it.

Yes, you are right. hardware has already verified the checksum to be
correct.
But I think hardware do this:
  1) calculate a checksum for the given protocol.(as the same as the
hardware which does not support verified the checksum)
  2) verified the checksum.(compare protocol checksum of packet with
calculated checksum)
If that is true, Trimming a packet also affect CHECKSUM_UNNECESSARY.

And in my test, UDP under IPv4 maybe do that.
My UDP packet is:

packet1:
 ___________________________________
| Source Port     | Dest Port       |
|_________________|_________________|
| Length = 16     | Checksum(*1)    |
|_________________|_________________|
|             payload24             |
|___________________________________|

correct is :
 ___________________________________
| Source Port     | Dest Port       |
|_________________|_________________|
| Length = 32     | Checksum        |
|_________________|_________________|
|             payload24             |
|___________________________________|

  Checksum(*1)  is the checksum of payload24, not only the first 8 byte
of payload24.

  When I send packet1 to echo-udp(target used e1000 inferface), echo-
reply can be reply. When I send packet1 to echo-udp(target used e100
inferface), echo-reply can not be reply.

  In e1000, when packet1 with checksum(*1) ,  skb->ip_summed is set to
CHECKSUM_UNNECESSARY. And when other, skb->ip_summed is set to
CHECKSUM_HW. So I think my guess is correct. Patch is necessary.


Regards

