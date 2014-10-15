From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: dst_entry leak in ip_append_data()
Date: Wed, 15 Oct 2014 02:30:33 -0700
Message-ID: <1413365433.12304.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <543CAD2A.3070701@parallels.com>
	 <1413348385.12304.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543E1AAF.9050601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Vasily Averin <vvs@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61216 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbaJOJaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 05:30:35 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so1001939pab.4
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 02:30:35 -0700 (PDT)
In-Reply-To: <543E1AAF.9050601@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-15 at 10:56 +0400, Vasily Averin wrote:
> On 15.10.2014 08:46, Eric Dumazet wrote:
> > On Tue, 2014-10-14 at 08:57 +0400, Vasily Averin wrote:
> >> v2: adjust the indentation of the arguments __ip_append_data() call
> >>
> >> Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
> >>
> >> If sk_write_queue is empty ip_append_data() executes ip_setup_cork()
> >> that "steals" dst entry from rt to cork. Later it calls __ip_append_data()
> >> that creates skb and adds it to sk_write_queue.
> >>
> >> If skb was added successfully following ip_push_pending_frames() call
> >> reassign dst entries from cork to skb, and kfree_skb frees dst_entry.
> >>
> >> However nobody frees stolen dst_entry if skb was not added into sk_write_queue.
> > 
> > I thought this was done by ip_flush_pending_frames() ?
> 
> Take look at ip_send_unicast_reply():

So maybe the bug is here ?


> 
> ip_flush_pending_frames() is not called if skb was not added to sk_write_queue.
> And ip_rt_put() does not work, because dst entry was stolen in ip_setup_cork().
> 
> Probably it can happen in raw_sendmsg() and udp_sendmsg() too.

UDP & RAW do :

err = ip_append_data(...);
if (err)
    udp_flush_pending_frames(sk);


It seems you chose to add a test in fast path, with not even adding an
unlikely() clause, while it seems that we took care of all the cases but
missed a single one : ip_send_unicast_reply()

I am suggesting to fix this bug in another way.

Thanks.
