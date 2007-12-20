From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix function put_cmsg() which may cause usr
 application memory overflow
Date: Thu, 20 Dec 2007 14:39:56 -0800 (PST)
Message-ID: <20071220.143956.103295054.davem@davemloft.net>
References: <4767665D.20300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44469
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763556AbXLTWj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:39:56 -0500
In-Reply-To: <4767665D.20300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 18 Dec 2007 15:19:09 +0900

> When used function put_cmsg() to copy kernel information to user 
> application memory, if the memory length given by user application is 
> not enough, by the bad length calculate of msg.msg_controllen, 
> put_cmsg() function may cause the msg.msg_controllen to be a large 
> value, such as 0xFFFFFFF0, so the following put_cmsg() can also write 
> data to usr application memory even usr has no valid memory to store 
> this. This may cause usr application memory overflow.
 ...
> The same promble exists in put_cmsg_compat(). This patch can fix this 
> problem.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Thank you for fixing this bug, patch applied.

put_cmsg() is a confusing function, it takes a while to understand
what it is trying to accomplish.  And this explains why this bug
lived for so long.

Each CMSG entry has to be aligned, but put_cmsg() will allow to
put the full final message into the CMSG area if there is enough
room to fit the message without the added alignment.

So, with Wei's fix, we now have:

	int cmlen = CMSG_LEN(len);
 ...
	if (msg->msg_controllen < cmlen) {
		msg->msg_flags |= MSG_CTRUNC;
		cmlen = msg->msg_controllen;
	}
 ...
	if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
		goto out;
	if (copy_to_user(CMSG_DATA(cm), data, cmlen - sizeof(struct cmsghdr)))
		goto out;
	cmlen = CMSG_SPACE(len);
	if (msg->msg_controllen < cmlen)
		cmlen = msg->msg_controllen;
	msg->msg_control += cmlen;
	msg->msg_controllen -= cmlen;
 ...

which I think finally implements the intended behavior
accurately.
