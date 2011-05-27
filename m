From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 v2] af-packet:  Use existing netdev reference for
 bound sockets.
Date: Fri, 27 May 2011 22:08:41 +0200
Message-ID: <1306526921.2533.7.camel@edumazet-laptop>
References: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
	 <1306467745.2543.60.camel@edumazet-laptop>
	 <4DDF2463.3020001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59741 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206Ab1E0UIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 16:08:44 -0400
Received: by wwa36 with SMTP id 36so2197436wwa.1
        for <netdev@vger.kernel.org>; Fri, 27 May 2011 13:08:43 -0700 (PDT)
In-Reply-To: <4DDF2463.3020001@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 mai 2011 =C3=A0 21:11 -0700, Ben Greear a =C3=A9crit :
> On 05/26/2011 08:42 PM, Eric Dumazet wrote:
> > Le jeudi 26 mai 2011 =C3=A0 16:55 -0700, greearb@candelatech.com a =
=C3=A9crit :
>=20
> >>   out_free:
> >>   	kfree_skb(skb);
> >>   out_unlock:
> >> -	if (dev)
> >> +	if (dev&&  need_rls_dev)
> >>   		dev_put(dev);
> >>   out:
> >>   	return err;
> >
> > Hmmm, I wonder why you want this Ben.
> >
> > IMHO this is buggy, because we can sleep in this function.
> >
> > We must take a ref on device (its really cheap these days, now we h=
ave a
> > percpu device refcnt)
>=20
> Why must you take the reference?  And if we must, why isn't the
> current code that assigns the prot_hook.dev without taking a
> reference OK?
>=20

If we sleep, device can disappear under us.

The only way to not take a reference is to hold rcu_read_lock(), but
you're not allowed to sleep under rcu_read_lock().


> It seems a waste to do the lookup and free if we don't have to,
> and with thousands of devices, the lookup might take a reasonable
> amount of effort?

I understand you want to avoid the lookup, this part is fine for me, bu=
t
you need to take a reference on the device before eventual sleep.

Nowadays its a single "inc" instruction on x86, without even a lock
prefix (this on a percpu integer)



