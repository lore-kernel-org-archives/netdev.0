From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 23 May 2013 00:05:22 +0300
Message-ID: <20130522210522.GA2800@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18583 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756929Ab3EVVFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 17:05:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Chen Gang,

The patch f39479363e03: "drivers/isdn: checkng length to be sure not
memory overflow" from Mar 7, 2013, leads to the following static checker
warning:

"drivers/isdn/i4l/isdn_tty.c:969 isdn_tty_send_msg()
	 error: buffer overflow 'cmd.parm.cmsg.para' 50 <= 73"

drivers/isdn/i4l/isdn_tty.c
   905          l = min(strlen(msg), sizeof(cmd.parm) - sizeof(cmd.parm.cmsg)
   906                  + sizeof(cmd.parm.cmsg.para) - 2);
   907  

[ snip ]

   963                  cmd.parm.cmsg.Length = l + 14;
   964                  cmd.parm.cmsg.Command = CAPI_MANUFACTURER;
   965                  cmd.parm.cmsg.Subcommand = CAPI_REQ;
   966                  cmd.parm.cmsg.adr.Controller = info->isdn_driver + 1;
   967                  cmd.parm.cmsg.para[0] = l + 1;
   968                  strncpy(&cmd.parm.cmsg.para[1], msg, l);
   969                  cmd.parm.cmsg.para[l + 1] = 0xd;
                                          ^^^^^^^
"l" is more than sizeof(cmd.parm.cmsg.para) here so it is an overflow.
As far as I can see the correct limit should be:

		l = min(strlen(msg), sizeof(cmd.parm.cmsg.para) - 2);

The "- 2" is so that ".cmsg.para[l + 1] = 0xd" does not overflow.

regards,
dan carpenter
