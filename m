From: Pavel Emelianov <xemul@sw.ru>
Subject: Re: [PATCH] Don't attach callback to a going-away netlink socket
Date: Mon, 16 Apr 2007 15:58:10 +0400
Message-ID: <462364D2.6010700@sw.ru>
References: <46236082.3000101@sw.ru> <46236102.2080706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	devel@openvz.org, Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:7629 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbXDPLxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 07:53:43 -0400
In-Reply-To: <46236102.2080706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> From: Denis Lunev <den@openvz.org>
>>
>> There is a race between netlink_dump_start() and netlink_release()
>> that can lead to the situation when a netlink socket with non-zero
>> callback is freed.
> 
> 
> Can you describe the race in more detail please?
> 
> 

Here it is:

CPU1:                           CPU2
netlink_release():              netlink_dump_start():

                                sk = netlink_lookup(); /* OK */

netlink_remove();

spin_lock(&nlk->cb_lock);
if (nlk->cb) { /* false */
  ...
}
spin_unlock(&nlk->cb_lock);

                                spin_lock(&nlk->cb_lock);
                                if (nlk->cb) { /* false */
                                         ...
                                }
                                nlk->cb = cb;
                                spin_unlock(&nlk->cb_lock);
                                ...
sock_orphan(sk);
/*
 * proceed with releasing
 * the socket
 */

The proposal it to make sock_orphan before detaching the callback
in netlink_release() and to check for the sock to be SOCK_DEAD in
netlink_dump_start() before setting a new callback.
