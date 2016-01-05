From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] skbuff: Fix skb checksum flag on skb pull
Date: Mon, 04 Jan 2016 22:04:40 -0800
Message-ID: <1451973880.8255.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442951873-4803-1-git-send-email-pshelar@nicira.com>
	 <20150924.140931.1967362456389755405.davem@davemloft.net>
	 <1451498745.8255.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160104.230804.2220774053197810472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org,
	willemdebruijn.kernel@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36157 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbcAEGEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 01:04:42 -0500
Received: by mail-pa0-f53.google.com with SMTP id yy13so117053844pab.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 22:04:42 -0800 (PST)
In-Reply-To: <20160104.230804.2220774053197810472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-04 at 23:08 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Dec 2015 13:05:45 -0500
> 
> > On Thu, 2015-09-24 at 14:09 -0700, David Miller wrote:
> >> From: Pravin B Shelar <pshelar@nicira.com>
> >> Date: Tue, 22 Sep 2015 12:57:53 -0700
> >> 
> >> > VXLAN device can receive skb with checksum partial. But the checksum
> >> > offset could be in outer header which is pulled on receive. This results
> >> > in negative checksum offset for the skb. Such skb can cause the assert
> >> > failure in skb_checksum_help(). Following patch fixes the bug by setting
> >> > checksum-none while pulling outer header.
> >> > 
> >> > Following is the kernel panic msg from old kernel hitting the bug.
> >>  ...
> >> > Reported-by: Anupam Chanda <achanda@vmware.com>
> >> > Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> >> 
> >> Applied, thanks.
> > 
> > 
> > It looks like we also should clear skb->csum ?
> > 
> > __skb_checksum_complete() definitely would be confused by garbage in
> > skb->csum
> 
> Pravin, please take a look at this.

This might be ok :

Apparently users are supposed to init skb->csum in this case, as in 

udp4_csum_init()
-> skb_checksum_init_zero_check()
  -> __skb_checksum_validate()

-> __skb_checksum_validate_complete
   skb->csum = psum;
