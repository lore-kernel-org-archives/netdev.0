From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [bug report] buffer overflow in isdn capi
Date: Wed, 02 Apr 2014 18:46:38 +0200
Message-ID: <533C3EEE.6020004@linux-pingi.de>
References: <20140401154830.GA16759@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:60920 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbaDBQqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:46:42 -0400
In-Reply-To: <20140401154830.GA16759@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

thanks for spotting this, really a bad thing.
Fortunately it is only a local issue, the messages from the ISDN bus
are translated in valid command/subcommand pairs in the controller
firmware, so even if you send random data on the D-channel
it should not result in a buffer overflow.
But of course a local user could send wrong messages to the kernel
via the /dev/capi20 device which then may let to the described out
of bound access.

Am 01.04.2014 17:48, schrieb Dan Carpenter:
> The command_2_index() function is buggy and leads to a buffer overflow.
> Does anyone know how to fix this?
> 

I think I have an idea, I will post a proposal soon.

> drivers/isdn/capi/capiutil.c
>    403  static unsigned command_2_index(unsigned c, unsigned sc)
>    404  {
>    405          if (c & 0x80)
>    406                  c = 0x9 + (c & 0x0f);
>    407          else if (c <= 0x0f);
>    408          else if (c == 0x41)
>    409                  c = 0x9 + 0x1;
>    410          else if (c == 0xff)
>    411                  c = 0x00;
>    412          return (sc & 3) * (0x9 + 0x9) + c;
>    413  }
> 
> Imagine that we input c = 0x7f and sc = 0x3.  Then 3 * 18 + 127 = 181
> and we return 181.

Yes need to check the array size at least, but this is not enough.

> 
> The other thing that stands out to me is that the last condition
> "(c == 0xff)" is never true because then the first condition
> "(c & 0x80)" would have been true already.

Yes this should be the first check or a nested if in the current first
check. command FF is the MANUFACTURER command and normally not
implemented at all.

> 
> Here is how the function is used:
> 
> drivers/isdn/capi/capiutil.c
>    564  /**
>    565   * capi_message2cmsg() - disassemble CAPI 2.0 message into _cmsg structure
>    566   * @cmsg:       _cmsg structure
>    567   * @msg:        buffer for assembled message
>    568   *
>    569   * Return value: 0 for success
>    570   */
>    571  
>    572  unsigned capi_message2cmsg(_cmsg *cmsg, u8 *msg)
>    573  {
>    574          memset(cmsg, 0, sizeof(_cmsg));
>    575          cmsg->m = msg;
>    576          cmsg->l = 8;
>    577          cmsg->p = 0;
>    578          byteTRcpy(cmsg->m + 4, &cmsg->Command);
>    579          byteTRcpy(cmsg->m + 5, &cmsg->Subcommand);
>    580          cmsg->par = cpars[command_2_index(cmsg->Command, cmsg->Subcommand)];
>                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> cpars = is a 79 element array.
> cmsg->Command and cmsg->Subcommand come from skb->data so we can't trust
> them.
> 181 is past the end of the 79 element array.

correct and this is not the only issue here. If you pass a value which
is not a valid command, but will result in a index inside the array
boundaries, it will result in  cmsg->par = NULL, which is also not
handled properly in the parser functions.
