From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Sun, 18 Aug 2013 14:11:31 -0700
Message-ID: <CAPshTCjB9S-Xc4MTs5XXLm6N=0-v_9gxC2SDwCzieTc4Py43fg@mail.gmail.com>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	<1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	<1363651672.21184.17.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	<CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
	<CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
	<1376766116.21329.9.camel@edumazet-glaptop>
	<CAPshTCh3CqrgasEvFG_Yy8NRHMp_rrQDqn7eRMD9NycmpxaWkQ@mail.gmail.com>
	<1376840262.21329.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dmitry Kravkov <dkravkov@gmail.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Uday Naik <uday@google.com>,
	Michael Dalton <mwdalton@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:37777 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab3HRVLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 17:11:32 -0400
Received: by mail-ve0-f173.google.com with SMTP id cy12so2595226veb.32
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 14:11:31 -0700 (PDT)
In-Reply-To: <1376840262.21329.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+mwdalton, uday

On Sun, Aug 18, 2013 at 8:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-08-18 at 04:55 -0700, Jerry Chu wrote:
>> On Sat, Aug 17, 2013 at 12:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Sat, 2013-08-17 at 21:52 +0300, Dmitry Kravkov wrote:
>> >
>> >>
>> >> Current bnx2x HW is not able to perform CSUM validation for
>> >> encapsulated packets, so in any case host needs to do that.
>> >> Today GRO/TPA feature depends on CSUM, but theoretically (i did not
>> >> investigate it) and probably HW can provide aggregated packets w/o
>> >> csum validation - this will save headers processing for host.
>> >
>> > I am not sure I understand this.
>> >
>> > Aggregation cannot be done if csums are not validated.
>>
>> Unless all the csums from aggregated pkts are also aggregated into one
>> (so that the host computes s/w csum on the large pkt and validates against
>> the aggregated csum...) There may be some performance benefit for doing
>> this but it may arguably weaken already weak 1's complement csum.
>
> To aggregate two packets, you first have to make sure the checksums of
> each packet are ok. If the hardware does not validate checksum, then it
> cannot aggregate packets.

It can if the csum validation is deferred. But this requires the stack code to
aggregate csum from individual pkt header, which can get ugly as one needs
to remove the header part from the individual csum first. It may also weaken
the already weak TCP csum as i mentioned previously. Also one corrupted
pkt will cause the whole GRO pkt to be thrown away. But I won't worry about
it for the data center environment where pkt corruption is rare.

>
> Sure, CHECKSUM_COMPLETE support would be nice, so that linux can perform
> aggregation without having to bring into cpu cache the whole frame.

I wish CHECKSUM_COMPLETE can be supported by the h/w - we are currently
running an older kernel w/o RSS for GRE support so all the GRE traffic between
two IPs hits the same NIC queue. With my GRO-GRE patch (to be upstreamed
later) I'm 20% below line rate (7.1Gbps) on 10GbE multi-TCP stream test because
RSS will saturate a single CPU that is handling softirq. The majority
of CPU cost
was from bcopy (~20%) followed by csum computation (4%). If I comment out the
csum validation in the GRO code then I hit line rate (9.1Gbps) right away on the
same test.

In order for me to saturate the line rate but without h/w CHECKSUM_COMPLETE
support, one other alternative is to back port the RSS for GRE support, which
seems a daunting task (if not please tell me). If I defer the csum
validation after
GRO then RPS will spread out traffic and the csum cost so we are no longer
bottlenecked on one CPU (and hopefully hit the line rate).

Jerry

>
>
>
