From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] RX/close vcc race with
 solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 21:49:52 +0100
Message-ID: <1275943792.17903.5119.camel@macbook.infradead.org>
References: <201006071637.o57GbqWd002514@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44128 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab0FGUty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 16:49:54 -0400
In-Reply-To: <201006071637.o57GbqWd002514@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-07 at 12:37 -0400, Chas Williams (CONTRACTOR) wrote:
> i dont understand.  if you do a sock_hold() in find_vcc(), and then call
> vcc->push() you should be able to call vcc->push() and then sock_put(). 

Holding the reference doesn't stop the problem. The problem is

 vcc_release()
 --> vcc_destroy_socket()
   --> br2684_push(vcc, NULL)
         sets vcc->user_back = NULL
         (which it what causes the oops when try try to feed it any
          subsequent packets).

 Only _later_ does vcc_release() call sock_put().

It doesn't _matter_ that the tasklet is holding a reference on the
socket, because it's not the sk_free() which is causing the problem. 

Just making dev->ops->close() wait for the tasklet is perfectly
sufficient. That call happens from vcc_destroy_socket() before the call
to br2684_push(), and all is well.

-- 
dwmw2

