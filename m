From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] RX/close vcc race with solos/atmtcp/usbatm/he
Date: Tue, 08 Jun 2010 11:05:25 -0400
Message-ID: <201006081505.o58F5Pt5006703@thirdoffive.cmf.nrl.navy.mil>
References: <1275943792.17903.5119.camel@macbook.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:35832 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab0FHPKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 11:10:48 -0400
In-reply-to: <1275943792.17903.5119.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1275943792.17903.5119.camel@macbook.infradead.org>,David Woodhouse 
writes:
>On Mon, 2010-06-07 at 12:37 -0400, Chas Williams (CONTRACTOR) wrote:
>> i dont understand.  if you do a sock_hold() in find_vcc(), and then call
>> vcc->push() you should be able to call vcc->push() and then sock_put(). 
>
>Holding the reference doesn't stop the problem. The problem is
>
> vcc_release()
> --> vcc_destroy_socket()
>   --> br2684_push(vcc, NULL)
>         sets vcc->user_back = NULL
>         (which it what causes the oops when try try to feed it any
>          subsequent packets).
>
> Only _later_ does vcc_release() call sock_put().

hmm... perhaps this routine needs to take the vcc_sklist_lock because
it is going to modify the vcc.  or we need to use locking on the vcc
itself.  it seems like the lock in vcc_remove_socket() just needs move
up one routine to encompass this whole 'closing'  operation.  the vcc
is going away.  we dont want people to be able to find it and use it.
it is not enough to just flip the flags on the vcc obviously.

you took a reference to an object inside a hashed list and didnt do
anything to prevent the object from leaving the hashed list. that is
stil not correct IMHO.
