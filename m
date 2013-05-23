From: Chen Gang <gang.chen@asianux.com>
Subject: Re: drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 23 May 2013 09:24:06 +0800
Message-ID: <519D6FB6.7090003@asianux.com>
References: <20130522210522.GA2800@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:4178 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756946Ab3EWBY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 21:24:58 -0400
In-Reply-To: <20130522210522.GA2800@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2013 05:05 AM, Dan Carpenter wrote:
> The patch f39479363e03: "drivers/isdn: checkng length to be sure not
> memory overflow" from Mar 7, 2013, leads to the following static checker
> warning:
> 
> "drivers/isdn/i4l/isdn_tty.c:969 isdn_tty_send_msg()
> 	 error: buffer overflow 'cmd.parm.cmsg.para' 50 <= 73"
> 
> drivers/isdn/i4l/isdn_tty.c
>    905          l = min(strlen(msg), sizeof(cmd.parm) - sizeof(cmd.parm.cmsg)
>    906                  + sizeof(cmd.parm.cmsg.para) - 2);
>    907  
> 
> [ snip ]
> 
>    963                  cmd.parm.cmsg.Length = l + 14;
>    964                  cmd.parm.cmsg.Command = CAPI_MANUFACTURER;
>    965                  cmd.parm.cmsg.Subcommand = CAPI_REQ;
>    966                  cmd.parm.cmsg.adr.Controller = info->isdn_driver + 1;
>    967                  cmd.parm.cmsg.para[0] = l + 1;
>    968                  strncpy(&cmd.parm.cmsg.para[1], msg, l);
>    969                  cmd.parm.cmsg.para[l + 1] = 0xd;
>                                           ^^^^^^^
> "l" is more than sizeof(cmd.parm.cmsg.para) here so it is an overflow.
> As far as I can see the correct limit should be:
> 
> 		l = min(strlen(msg), sizeof(cmd.parm.cmsg.para) - 2);
> 
> The "- 2" is so that ".cmsg.para[l + 1] = 0xd" does not overflow.


'cmd.parm' is a union in "include/linux/isdnif.h", so if length is more
than 'sizeof(cmd.parm.cmsg.para) - 2', but still within the 'cmd.parm',
it will be still OK (can not cause memory over flow).

The patch tries to keep original API no touch, and only fix the bug
(try not to decrease the original real valid buffer length).

Excuse me, the patch comments is not with standard format, so may cause
the readers misunderstanding.


Thanks.

------------------------------comments begin--------------------------------------

commit f39479363e0361c8bb4397481c01a7c3a1a3c8ac
Author: Chen Gang <gang.chen@asianux.com>
Date:   Thu Mar 7 18:25:41 2013 +0000

    drivers/isdn: checkng length to be sure not memory overflow
    
    sizeof (cmd.parm.cmsg.para) is 50 (MAX_CAPI_PARA_LEN).
      sizeof (cmd.parm) is 80+, but less than 100.
      strlen(msg) may be more than 80+ (Modem-Commandbuffer, less than 255).
        isdn_tty_send_msg is called by isdn_tty_parse_at
        the relative parameter is m->mdmcmd (atemu *m)
        the relative command may be "+M..."
    
      so need check the length to be sure not memory overflow.
        cmd.parm is a union, and need keep original valid buffer length no touch
    
    Signed-off-by: Chen Gang <gang.chen@asianux.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

------------------------------comments end--------------------------------------



-- 
Chen Gang

Asianux Corporation
