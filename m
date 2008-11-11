From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 09:38:13 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
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
 <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:13152 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbYKKRiW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 12:38:22 -0500
In-Reply-To: <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

> > 2.  Backing up this field isn't really possible since where would you
> place that backup?
> 
> Ex: Destructor arg points to a struct that contains previous
> destructor function and destructor argument.
> Those are restored and executed during new destructor.
> Layer that replaces it, is in charge of the backup
> >
> > 3.  You're increasing the size of the structure for everyone, even if
> they have disabled PACKET_MMAP (and since no-one else uses this, it
> doesn't really make sense).  So if it is decided that the correct
> approach is to store the pointer in the skb, then we should continue
> doing what other protocols do in the situation where they need custom
> data in the skb and just add our own custom pointer surrounded by an
> #ifdef/#endif for PACKET_MMAP.
> 
> That's could be included into another "feature flag" which will be
> enabled only when a feature as PACKET_MMAP needs it.
> 
> I'm suggesting a variable that sub-layers will guarantee as
> skb->destructor. A variable that will be at least restored before
> destructor callback call.
Again, I'm not convinced this is 100% feasible.  I understand, I think, what you're getting at.  If you want to use the field, you defined a structure like struct my_arg { void *old, ... my data ... }.  However, this isn't like C++ where the destructors for all layers are called.  There is only 1 destructor for the layer that created the skb (AFAIK) - all the layers simply increment their reference to it (which is decremented by a free).  Thus there's really no way to do what you want with minimal impact on existing code - the ideal behaviour would be to define a common struct (i.e. { void * olddata, void *thisdata }, that is filled with whatever data that layer needs when it increments the refcount and then have kfree_skb unwind the pointer as needed.  This would require a massive change 
 to the code though, increase the amount of memory usage unnecessarily, and be prone to memory leaks if it's not done carefully.
> 
> This can be used also for sock_w_free() destructor. Current code is
> assuming that the socket destructor is always sock_w_free(), if
> tomorrow, this callback is changed or removed, we will have to change
> packet_mmap code (called in packet_skb_destruct()). Such mechanism
> should make replacement of destructor/destructor arg more independent
> toward layers.
We're talking about skb destructors, not socket destructors.  sock_wfree is not a destructor - it releases the resources allocated to the skb back to the socket that the resources are from.

Also, from what I can tell, this is how the Linux kernel works - if someone's change breaks the code, they're responsible for fixing it.  Changing how sock_wfree is fairly significant enough that we don't need to worry about making it easier - it'll probably be so significant that there will be a lot of changes anyways.  It's also highly unlikely to happen I think.
