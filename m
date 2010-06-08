From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] RX/close vcc race with
 solos/atmtcp/usbatm/he
Date: Tue, 08 Jun 2010 17:25:26 +0100
Message-ID: <1276014326.22896.3.camel@macbook.infradead.org>
References: <201006081505.o58F5Pt5006703@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57220 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab0FHQZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 12:25:30 -0400
In-Reply-To: <201006081505.o58F5Pt5006703@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 11:05 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1275943792.17903.5119.camel@macbook.infradead.org>,David Woodhouse 
> writes:
> >On Mon, 2010-06-07 at 12:37 -0400, Chas Williams (CONTRACTOR) wrote:
> >> i dont understand.  if you do a sock_hold() in find_vcc(), and then call
> >> vcc->push() you should be able to call vcc->push() and then sock_put(). 
> >
> >Holding the reference doesn't stop the problem. The problem is
> >
> > vcc_release()
> > --> vcc_destroy_socket()
> >   --> br2684_push(vcc, NULL)
> >         sets vcc->user_back = NULL
> >         (which it what causes the oops when try try to feed it any
> >          subsequent packets).
> >
> > Only _later_ does vcc_release() call sock_put().
> 
> hmm... perhaps this routine needs to take the vcc_sklist_lock because
> it is going to modify the vcc.  or we need to use locking on the vcc
> itself. 

Or move the ->push(vcc, NULL) and anything else which destroys the
state, so that it happens later. Use a real socket destructor function
which will be called from sk_free() after the last sock_put().

> you took a reference to an object inside a hashed list and didnt do
> anything to prevent the object from leaving the hashed list. that is
> stil not correct IMHO.

Yeah yeah, but I fixed that already with the RCU-like approach of
synchronising with the tasklet on dev->ops->close(). So I don't _need_
the reference.

-- 
dwmw2

