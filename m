From: Andrej Ota <andrej@ota.si>
Subject: Re: unable to handle kernel NULL pointer dereference in
 =?UTF-8?Q?skb=5Fdequeue?=
Date: Fri, 03 Dec 2010 15:37:18 +0100
Message-ID: <aa43945b38cee751a8231084866b074d@192.168.253.23>
References: <0fe401cb92e7$85ba2260$912e6720$@si> <1291381791.2897.250.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <gvs@zemos.net>,
	Rami Rosen <ramirose@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291381791.2897.250.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Patch that works for me is below. Now I only hope I haven't
>> (re)introduced a memory leak...

> Problem comes from commit 55c95e738da85 (fix return value of
> __pppoe_xmit() method)
> 
> I am not sure patch is OK


Me neither. That's why I wrote "works for me". All I dare say is that it
works better than current code and is probably no worse than it was before
above mentioned commit. Apart from that, there is no point in having return
value for __pppoe_xmit if return value isn't needed.

Easiest way of triggering this BUG is by terminating PPPoE on the server
side, which then hits "if (!dev) { goto abort; }". This in turn calls
"kfree_skb(skb); return 0;" which returns to pppoe_rcv_core which then
goto-s to "abort_put" which again calls "kfree_skb(skb)". Voila the bug.

I don't know how to trigger "if (skb_cow_head(skb, ..." to see if I have
just caused another BUG. However, if I read file comments at the top, I see
a comment from 19/07/01 stating that I have to delete original skb if code
succeeds and never delete it on failure. About the skb copy mentioned in
the same comment, I don't know. 2001 was many commits ago.

Andrej Ota.
