From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: Fix kernel panic while received AUTH chunk while
 enabled auth
Date: Tue, 05 Feb 2008 17:21:06 +0900
Message-ID: <47A81C72.8050207@cn.fujitsu.com>
References: <4794C51B.8040904@cn.fujitsu.com> <479A112D.5020201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:35375 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609AbYBEIW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 03:22:27 -0500
In-Reply-To: <479A112D.5020201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If STCP is started while /proc/sys/net/sctp/auth_enable is set 0 and 
association is established between endpoints. Then if 
/proc/sys/net/sctp/auth_enable is set 1, a received AUTH chunk will 
cause kernel panic.

Test as following:
step 1: echo 0> /proc/sys/net/sctp/auth_enable
step 2:

   SCTP client                  SCTP server
      INIT          --------->
                    <---------   INIT-ACK
      COOKIE-ECHO   --------->
                    <---------   COOKIE-ACK
step 3:
    echo 1> /proc/sys/net/sctp/auth_enable
step 4:
   SCTP client                  SCTP server
       AUTH        ----------->  Kernel Panic


This patch fix this probleam to treat AUTH chunk as unknow chunk if peer 
has initialized with no auth capable.

> Sorry for the delay.  Was on vacation without net access.
>
> Wei Yongjun wrote:
>>
>>
>> This patch fix this probleam to treat AUTH chunk as unknow chunk if 
>> peer has initialized with no auth capable.
>>
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>
>>

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

--- a/net/sctp/sm_statefuns.c	2008-01-21 00:03:25.000000000 -0500
+++ b/net/sctp/sm_statefuns.c	2008-01-21 05:14:08.000000000 -0500
@@ -3785,6 +3785,10 @@ sctp_disposition_t sctp_sf_eat_auth(cons
 	struct sctp_chunk *err_chunk;
 	sctp_ierror_t error;
 
+	/* Make sure that the peer has AUTH capable */
+	if (!asoc->peer.auth_capable)
+		return sctp_sf_unk_chunk(ep, asoc, type, arg, commands);
+
 	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
 				SCTP_NULL());




