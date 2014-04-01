From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] buffer overflow in isdn capi
Date: Tue, 1 Apr 2014 18:48:30 +0300
Message-ID: <20140401154830.GA16759@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19394 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbaDAPsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 11:48:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The command_2_index() function is buggy and leads to a buffer overflow.
Does anyone know how to fix this?

drivers/isdn/capi/capiutil.c
   403  static unsigned command_2_index(unsigned c, unsigned sc)
   404  {
   405          if (c & 0x80)
   406                  c = 0x9 + (c & 0x0f);
   407          else if (c <= 0x0f);
   408          else if (c == 0x41)
   409                  c = 0x9 + 0x1;
   410          else if (c == 0xff)
   411                  c = 0x00;
   412          return (sc & 3) * (0x9 + 0x9) + c;
   413  }

Imagine that we input c = 0x7f and sc = 0x3.  Then 3 * 18 + 127 = 181
and we return 181.

The other thing that stands out to me is that the last condition
"(c == 0xff)" is never true because then the first condition
"(c & 0x80)" would have been true already.

Here is how the function is used:

drivers/isdn/capi/capiutil.c
   564  /**
   565   * capi_message2cmsg() - disassemble CAPI 2.0 message into _cmsg structure
   566   * @cmsg:       _cmsg structure
   567   * @msg:        buffer for assembled message
   568   *
   569   * Return value: 0 for success
   570   */
   571  
   572  unsigned capi_message2cmsg(_cmsg *cmsg, u8 *msg)
   573  {
   574          memset(cmsg, 0, sizeof(_cmsg));
   575          cmsg->m = msg;
   576          cmsg->l = 8;
   577          cmsg->p = 0;
   578          byteTRcpy(cmsg->m + 4, &cmsg->Command);
   579          byteTRcpy(cmsg->m + 5, &cmsg->Subcommand);
   580          cmsg->par = cpars[command_2_index(cmsg->Command, cmsg->Subcommand)];
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
cpars = is a 79 element array.
cmsg->Command and cmsg->Subcommand come from skb->data so we can't trust
them.
181 is past the end of the 79 element array.

   581  
   582          message_2_pars(cmsg);
   583  
   584          wordTRcpy(msg + 0, &cmsg->l);
   585          wordTRcpy(cmsg->m + 2, &cmsg->ApplId);
   586          wordTRcpy(cmsg->m + 6, &cmsg->Messagenumber);
   587  
   588          return 0;
   589  }

regards,
dan carpenter
