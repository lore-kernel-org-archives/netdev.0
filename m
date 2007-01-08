From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.20-rc4
Date: Sun, 07 Jan 2007 17:11:23 -0800 (PST)
Message-ID: <20070107.171123.43392648.davem@davemloft.net>
References: <1168216304.12025.10.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965284AbXAHBLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jan 2007 20:11:23 -0500
To: marcel@holtmann.org
In-Reply-To: <1168216304.12025.10.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 08 Jan 2007 01:31:44 +0100

> Commit: 2b2e64be763c5e64d4ae4a061825b18decf1edf7 
> Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:33 +0100 
> 
>     [Bluetooth] Fix uninitialized return value for RFCOMM sendmsg()
>     
>     When calling send() with a zero length parameter on a RFCOMM socket
>     it returns a positive value. In this rare case the variable err is
>     used uninitialized and unfortunately its value is returned.
>     
>     Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

You can't fix this bug like that.

If sendmsg() sends any bytes, it should return the number of
bytes sent even if an error occurs mid-stream.

With this change, you'll now return the error instead of
the number of bytes sent.  That's what the new "sent = err"
assignment does.

You have to do sendmsg() with those semantics, or else you lose
information in that the user can never know how many bytes were
actually sent successfully.  Losing the error after successfully sent
bytes is OK, if the error persists the user will get it when it
recalls sendmsg() to push the rest of the remaining bytes out.

The original code tried to do it right.

If the bug is that 'err' is uninitialized, why try to fix this
by being fancy, just initialize it :-)
