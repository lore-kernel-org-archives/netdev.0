From: Chris Friesen <chris.friesen@genband.com>
Subject: [BUG]  TIPC handling of -ERESTARTSYS in connect()
Date: Thu, 30 Aug 2012 09:20:47 -0600
Message-ID: <503F84CF.208@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, ying.xue@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og101.obsmtp.com ([64.18.2.155]:44275 "EHLO
	exprod7og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab2H3PVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:21:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I'm seeing some behaviour that looks unintentional in the TIPC connect() call.
I'm running TIPC 1.7.7.  My userspace code (stripped of error handling) looks
like this:

	int sd = socket (AF_TIPC, SOCK_SEQPACKET,0);
	connect(sd,(struct sockaddr*)&topsrv,sizeof(topsrv));

where topsrv is the address of the TIPC topology server.  The thing that's weird
is that intermittently we get a EISCONN error on the connect call.

Looking at the TIPC connect() code, I think what is happening is that
wait_event_interruptible_timeout() is being interrupted by a signal and returns
-ERESTARTSYS.  This sets sock->state to SS_DISCONNECTING and exits.  Userspace
sees the ERESTARTSYS and retries the syscall, then we hit the
"sock->state != SS_UNCONNECTED" check and exit with -EISCONN.

I think current mainline is susceptible to this as well.

I'm not sure what the proper fix would be--can we detect coming back in that we were
waiting for a message and just skip down to the wait_event_interruptible_timeout()
call?

Chris


-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
