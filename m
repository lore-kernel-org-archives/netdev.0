From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Wed, 15 Oct 2014 23:34:59 -0400 (EDT)
Message-ID: <20141015.233459.1141284199701707266.davem@davemloft.net>
References: <543F0712.8080503@redhat.com>
	<20141015.195737.1429281929513331763.davem@davemloft.net>
	<CALCETrUW6yX8B=ANyxYqhwPbKkosbuBGXO8omTD6rGA1A1XhvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, torvalds@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org, tgraf@suug.ch
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbaJPDfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 23:35:01 -0400
In-Reply-To: <CALCETrUW6yX8B=ANyxYqhwPbKkosbuBGXO8omTD6rGA1A1XhvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 15 Oct 2014 16:58:39 -0700

> On Wed, Oct 15, 2014 at 4:57 PM, David Miller <davem@davemloft.net> wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Thu, 16 Oct 2014 01:45:22 +0200
>>
>>> On 10/15/2014 04:01 AM, David Miller wrote:
>>>> From: Andy Lutomirski <luto@amacapital.net>
>>>> Date: Tue, 14 Oct 2014 15:16:46 -0700
>>>>
>>>>> It's at least remotely possible that there's something that assumes
>>>>> that assumes that the availability of NETLINK_RX_RING implies
>>>>> NETLINK_TX_RING, which would be unfortunate.
>>>>
>>>> I already found one such case, nlmon :-/
>>>
>>> Hmm, can you elaborate? I currently don't think that nlmon cares
>>> actually.
>>
>> nlmon cares, openvswitch cares, etc:
> 
> It'll still work, just slower, right?
> 
> +    if (setsockopt(sock->fd, SOL_NETLINK, NETLINK_RX_RING, &req,
> sizeof(req)) < 0
> +        || setsockopt(sock->fd, SOL_NETLINK, NETLINK_TX_RING, &req,
> sizeof(req)) < 0) {
> +        VLOG_INFO("mmap netlink is not supported");
> +        return 0;
> +    }

So NETLINK_RX_RING succeeds but NETLINK_TX_RING fails, so now the
recvmsg() path will take the RX ring code path because this code
doesn't clean up and undo the setsockopt().

This is the common coding paradigm I've seen in all NETLINK_*_RING
uses.
