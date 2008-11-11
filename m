From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 18:50:05 +0100
Message-ID: <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:35459 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbYKKRuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 12:50:07 -0500
Received: by fg-out-1718.google.com with SMTP id 19so87351fgg.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 09:50:05 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> Again, I'm not convinced this is 100% feasible.  I understand, I think, what you're getting at.  If you want to use the field, you defined a structure like struct my_arg { void *old, ... my data ... }.  However, this isn't like C++ where the destructors for all layers are called.  There is only 1 destructor for the layer that created the skb (AFAIK) - all the layers simply increment their reference to it (which is decremented by a free).  Thus there's really no way to do what you want with minimal impact on existing code - the ideal behaviour would be to define a common struct (i.e. { void * olddata, void *thisdata }, that is filled with whatever data that layer needs when it increments the refcount and then have kfree_skb unwind the pointer as needed.  This would require a massive chang
 e to the code though, increase the amount of memory usage unnecessarily, and be prone to memory leaks if it's not done carefully.

You say "There is only 1 destructor for the layer that created the skb
(AFAIK)", why not a "There is only 1 destructor argument for the layer
that created the skb (AFAIK)"?
Where is the impact? only a void * destructor_arg that only the
creator of skb is allowed to use. Moreover it can be put under feature
flag.

>>
>> This can be used also for sock_w_free() destructor. Current code is
>> assuming that the socket destructor is always sock_w_free(), if
>> tomorrow, this callback is changed or removed, we will have to change
>> packet_mmap code (called in packet_skb_destruct()). Such mechanism
>> should make replacement of destructor/destructor arg more independent
>> toward layers.
> We're talking about skb destructors, not socket destructors.  sock_wfree is not a destructor - it releases the resources allocated to the skb back to the socket that the resources are from.
I agree, I'm just talking about destructor/destructor_arg pair.

>
> Also, from what I can tell, this is how the Linux kernel works - if someone's change breaks the code, they're responsible for fixing it.  Changing how sock_wfree is fairly significant enough that we don't need to worry about making it easier - it'll probably be so significant that there will be a lot of changes anyways.  It's also highly unlikely to happen I think.

I don't want to break this code. Just add a variable in sk_buff that
can be used as the destructor is ! kind of CB[] that is not
overwritten by sub layer ! or at least backuped.

Thanks,
Johann




-- 
Johann Baudy
johaahn@gmail.com
