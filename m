From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 15:58:58 -0700
Message-ID: <d1c2719f0805121558m3ca01781y53e4fbd2ed451e34@mail.gmail.com>
References: <20080507.184311.196815718.davem@davemloft.net>
	 <d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
	 <d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
	 <20080512.152900.220913361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:27561 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463AbYELW7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:59:06 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m4CMwxjM001895
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 23:59:00 +0100
Received: from hs-out-0708.google.com (hscn78.prod.google.com [10.44.115.78])
	by zps36.corp.google.com with ESMTP id m4CMwwFP032121
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 15:58:59 -0700
Received: by hs-out-0708.google.com with SMTP id n78so1955016hsc.8
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 15:58:58 -0700 (PDT)
In-Reply-To: <20080512.152900.220913361.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2008 at 3:29 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>  Date: Mon, 12 May 2008 15:22:55 -0700
>
>
>  > I did a quick prototype based on your idea of adding an "in_flight"
>  > field to skb_shared_info to track how many in-flight clones in the
>  > host. I tested
>  > it quickly and it doesn't work. After some thought it was obvious why it
>  > won't work. It's because what the TCP stack needs is to track how
>  > many in-flight pkts are in the host, but your proposed patch increments
>  > "in_flight" once on the 1st __skb_clone() to be sent to the driver, but
>  > decrements "in_flight" TWICE, one for each of the clones to be freed.
>  > I did a quick hack to make it work for my limited test case but I haven't
>  > figured out an acceptable (non-hack) solution.
>
>  That's easy to fix, only set the in_flight pointer in the child clone
>  skb.  Thanks for figuring that out.

I must be missing something. All the clones share the same
"skb_shared_info", how does one only set in_flight in one clone but
not the other?

>
>
>  > Continued testing, I discovered the problem I described below where
>  > "in_flight" may point to a tp that has already been freed can not be
>  > addressed by zapping skb_shinfo(skb)->in_flight in sock_wfree(). The
>  > reason is that pkts may be acked and freed by TCP before driver freeing
>  > up its clone copy (e.g., due to driver lazy reclaim...) When that happens
>  > the "host_inflight" accounting will get messed up.
>
>  Simply notice, when we're about to decrement in_flight, that the data
>  reference is one.  You can take appropriate actions if so.
>

Jerry
