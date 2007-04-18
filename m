From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETLINK] Don't attach callback to a going-away netlink socket
Date: Wed, 18 Apr 2007 10:50:42 +0200
Message-ID: <4625DBE2.5090402@trash.net>
References: <4625D3D2.9030507@sw.ru> <20070418081707.GA29267@2ka.mipt.ru> <4625D637.2040308@trash.net> <20070418084206.GA4241@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@sw.ru>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	devel@openvz.org, Kirill Korotaev <dev@openvz.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54084 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030682AbXDRIvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 04:51:01 -0400
In-Reply-To: <20070418084206.GA4241@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Wed, Apr 18, 2007 at 10:26:31AM +0200, Patrick McHardy (kaber@trash.net) wrote:
> 
>>>Out of curiosity, why not to fix a netlink_dump_start() to remove
>>>callback in error path, since in 'no-error' path it removes it in
>>>netlink_dump().
>>
>>
>>It already does (netlink_destroy_callback), but that doesn't help
>>with this race though since without this patch we don't enter the
>>error path.
> 
> 
> I thought that with releasing a socket, which will have a callback
> attached only results in a leak of the callback? In that case we can
> just free it in dump() just like it is done in no-error path already.
> Or do I miss something additional?


That would only work if there is nothing to dump (cb->dump returns 0).
Otherwise it is not freed.

>>The problem is asynchronous processing of the dump request in the
>>context of a different process. Process requests a dump, message
>>is queued and process returns from sendmsg since some other process
>>is already processing the queue. Then the process closes the socket,
>>resulting in netlink_release being called. When the dump request
>>is finally processed the race Pavel described might happen. This
>>can only happen for netlink families that use mutex_try_lock for
>>queue processing of course.
> 
> 
> Doesn't it called from ->sk_data_ready() which is synchronous with
> respect to sendmsg, not sure about conntrack though, but it looks so?


Yes, but for kernel sockets we end up calling the input function,
which when mutex_trylock is used returns immediately when some
other process is already processing the queue, so the requesting
process might close the socket before the request is processed.

