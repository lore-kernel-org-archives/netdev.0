From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: OpenWRT wrong adjustment of fq_codel defaults (Was: [Codel]
 fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 01:47:30 +0300
Message-ID: <CACiydbLYFg7wgxdnzGGo1+_PSG=348x1c23nj96W8t6QhGKt_Q@mail.gmail.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
	<1462125592.5535.194.camel@edumazet-glaptop3.roam.corp.google.com>
	<865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
	<1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
	<C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
	<1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
	<1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
	<1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
	<1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
	<1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160506114243.4eb4f95e@redhat.com>
	<572DBC21.10209@darbyshire-bryant.me.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Dave Taht <dave.taht@gmail.com>,
	make-wifi-fast@lists.bufferbloat.net,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	ath10k <ath10k@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
	Jonathan Morton <chromatix99@gmail.com>
To: Kevin Darbyshire-Bryant <kevin@darbyshire-bryant.me.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35119 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbcEOWrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 18:47:31 -0400
Received: by mail-oi0-f43.google.com with SMTP id x19so244379399oix.2
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 15:47:30 -0700 (PDT)
In-Reply-To: <572DBC21.10209@darbyshire-bryant.me.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 May 2016 at 12:57, Kevin Darbyshire-Bryant
<kevin@darbyshire-bryant.me.uk> wrote:
>
>
> On 06/05/16 10:42, Jesper Dangaard Brouer wrote:
>> Hi Felix,
>>
>> This is an important fix for OpenWRT, please read!
>>
>> OpenWRT changed the default fq_codel sch->limit from 10240 to 1024,
>> without also adjusting q->flows_cnt.  Eric explains below that you must
>> also adjust the buckets (q->flows_cnt) for this not to break. (Just
>> adjust it to 128)
>>
>> Problematic OpenWRT commit in question:
>>  http://git.openwrt.org/?p=openwrt.git;a=patch;h=12cd6578084e
>>  12cd6578084e ("kernel: revert fq_codel quantum override to prevent it from causing too much cpu load with higher speed (#21326)")
> I 'pull requested' this to the lede-staging tree on github.
> https://github.com/lede-project/staging/pull/11
>
> One way or another Felix & co should see the change :-)

If you would follow the white rabbit, you would see that it doesn't help

>>
>>
>> I also highly recommend you cherry-pick this very recent commit:
>>  net-next: 9d18562a2278 ("fq_codel: add batch ability to fq_codel_drop()")
>>  https://git.kernel.org/davem/net-next/c/9d18562a227
>>
>> This should fix very high CPU usage in-case fq_codel goes into drop mode.
>> The problem is that drop mode was considered rare, and implementation
>> wise it was chosen to be more expensive (to save cycles on normal mode).
>> Unfortunately is it easy to trigger with an UDP flood. Drop mode is
>> especially expensive for smaller devices, as it scans a 4K big array,
>> thus 64 cache misses for small devices!
>>
>> The fix is to allow drop-mode to bulk-drop more packets when entering
>> drop-mode (default 64 bulk drop).  That way we don't suddenly
>> experience a significantly higher processing cost per packet, but
>> instead can amortize this.
> I haven't done the above cherry-pick patch & backport patch creation for
> 4.4/4.1/3.18 yet - maybe if $dayjob permits time and no one else beats
> me to it :-)
>
> Kevin
>
