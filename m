From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Thu, 25 Jul 2013 10:28:20 +0800
Message-ID: <CACVXFVN0eN9E9efr8UdqFz68-emHa2o-RQ0RYfazEq8f=qxkLQ@mail.gmail.com>
References: <1374311809-4155-1-git-send-email-freddy@asix.com.tw>
	<1374512879.4990.19.camel@edumazet-glaptop>
	<CANEJEGvPc56ePP=_bxfA4PZfsM3vw=MsRjbWwrFBC3eP-GtzZg@mail.gmail.com>
	<1374518312.1635.29.camel@bwh-desktop.uk.level5networks.com>
	<1374518841.4990.26.camel@edumazet-glaptop>
	<1374522471.1635.48.camel@bwh-desktop.uk.level5networks.com>
	<1374559827.4990.143.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Oliver Neukum <oliver@neukum.org>,
	Grant Grundler <grundler@google.com>,
	Freddy Xin <freddy@asix.com.tw>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	=?Big5?B?QVNJWCBMb3VpcyBbxKyrwrOwXQ==?= <louis@asix.com.tw>,
	Allan Chou <allan@asix.com.tw>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:49753 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab3GYC2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 22:28:21 -0400
In-Reply-To: <1374559827.4990.143.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 2:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-07-22 at 20:47 +0100, Ben Hutchings wrote:
>> On Mon, 2013-07-22 at 11:47 -0700, Eric Dumazet wrote:
>> > On Mon, 2013-07-22 at 19:38 +0100, Ben Hutchings wrote:
>> > > On Mon, 2013-07-22 at 11:29 -0700, Grant Grundler wrote:
>> > > > On Mon, Jul 22, 2013 at 10:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > > > ...
>> > > > > I guess that if a driver does not advertise NETIF_F_SG, this
>> > > > > skb_linearize() call is not needed : All frames reaching your xmit
>> > > > > function should already be linear
>> > > >
>> > > > As Ben Hutchings pointed out, hw_features is still setting this...but
>> > > > I'm not sure how that matters.
>> > > >
>> > > > ax88179_set_features() doesn't allow setting SG or TSO features.  But
>> > > > I expect it would be "not too difficult" to add such that ethtool
>> > > > could set those features after boot.
>> > > [...]
>> > >
>> > > It already can.  That's what putting feature flags in hw_features does.
>> >
>> > My original concern, that inspired this patch, was to remove SG support,
>> > as this driver does not have SG support at all.
>> >
>> > Linearize a full TSO packet needs order-5 allocations, thats likely to
>> > fail and lead to very slow TCP performance, because it will only rely on
>> > retransmits.
>>
>> The driver could set gso_max_size to reduce that problem.  But I rather
>> doubt that TSO followed by skb_linearize() significantly improves
>> throughput or CPU-efficiency.  (If the device has a 1G link but is
>> connected to the host through a USB 2.0 port, then USB is the bottleneck
>> and TSO could improve throughput a few percent.  But that's a silly
>> configuration.)
>>
>> The real solution would be for someone to add SG support to the usbnet
>> core.  Trying to support 1GbE with only linear skbs is not a great
>> idea... and it can only be a matter of time before there is USB ultra
>> speed (or whatever comes after 'super') with 10GbE devices...
>>
>
> This sounds a good idea.
>
> Is anybody working on adding SG to usbnet ?

It depends if size of sg buffer(except for last one) in the sg list can be
divided by usb endpoint's max packet size(512 or 1024), at least there
is the constraint:

http://git.kernel.org/cgit/linux/kernel/git/gregkh/usb.git/commit/?h=usb-next&id=10e232c597ac757e7f8600649f7e872e86de190f

I am wondering if network stack can meet that.  If not, it might be a
bit difficult
because lots of USB host controller don't support that, and driver may have
to support SG and non-SG at the same time for working well on all HCs.

Thanks,
-- 
Ming Lei
