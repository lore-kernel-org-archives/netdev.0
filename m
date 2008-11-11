From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 12:43:44 +0100
Message-ID: <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
	 <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:36972 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbYKKLnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 06:43:46 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2685405fgg.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 03:43:44 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

>
>> I think we must not care about skb frags/device management to get
>> tpacket_hdr pointer back from skb. If it is changing tomorrow, we will
>> be in trouble.
> I'm a bit confused about the point you are trying to make here.  Could you please clarify?

I believe that a solution with an additional field in sk_buff struct
is preferable to a one which depends on sub-layer mechanism (frags
management).

> This would require a massive change in the kernel to add a feature that up till now no one has needed.  Certainly, I don't think it's wise to introduce such a wide-spread change when we could just as well accomplish it through other means.  Here are my problems with this approach:
>
> 1.  There's no need to actually pass the argument through the destructor - it could just be part of the skb (after all, since the callback only happens in one place, it's not like we could customize that argument - it would always be skb->destructor_arg).  That way whoever needs to use would use it,  but there's no need to change all existing destructor code.

Yes! give it as callback argument is not mandatory.

> 2.  Backing up this field isn't really possible since where would you place that backup?

Ex: Destructor arg points to a struct that contains previous
destructor function and destructor argument.
Those are restored and executed during new destructor.
Layer that replaces it, is in charge of the backup

>
> 3.  You're increasing the size of the structure for everyone, even if they have disabled PACKET_MMAP (and since no-one else uses this, it doesn't really make sense).  So if it is decided that the correct approach is to store the pointer in the skb, then we should continue doing what other protocols do in the situation where they need custom data in the skb and just add our own custom pointer surrounded by an #ifdef/#endif for PACKET_MMAP.

That's could be included into another "feature flag" which will be
enabled only when a feature as PACKET_MMAP needs it.

I'm suggesting a variable that sub-layers will guarantee as
skb->destructor. A variable that will be at least restored before
destructor callback call.

This can be used also for sock_w_free() destructor. Current code is
assuming that the socket destructor is always sock_w_free(), if
tomorrow, this callback is changed or removed, we will have to change
packet_mmap code (called in packet_skb_destruct()). Such mechanism
should make replacement of destructor/destructor arg more independent
toward layers.

Best regards,
Johann
