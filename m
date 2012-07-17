From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [RFC] tcp: TSQ - do not always throttle.
Date: Tue, 17 Jul 2012 15:10:54 +0200
Message-ID: <1342530654.2626.563.camel@edumazet-glaptop>
References: <20120717120358.16611.98190.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36724 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab2GQNK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:10:59 -0400
Received: by eekc13 with SMTP id c13so148382eek.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:10:58 -0700 (PDT)
In-Reply-To: <20120717120358.16611.98190.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 17:33 +0530, Krishna Kumar wrote:
> Do not throttle if sysctl_tcp_limit_output_bytes==0.
> 
> Maybe it is better to throttle earlier in the loop, after
> calling tcp_init_tso_segs().
> 

I wonder why, and why you put this question in a changelog instead of
outside of it...

Idea was to avoid setting TSQ_THROTTLED if we break out the loop.


About disabling TSQ, my initial intent was to instead use a negative
sysctl_tcp_limit_output_bytes value.

Thats why I have in tcp_transmit_skb() :

skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
		  tcp_wfree : sock_wfree;

So I suggest you change the tcp_write_xmit(() test to a single unsigned
compare :

if (atomic_read(&sk->sk_wmem_alloc) >=
    (unsigned) sysctl_tcp_limit_output_bytes) {

Also use :

skb->destructor = (sysctl_tcp_limit_output_bytes >= 0) ?
  tcp_wfree : sock_wfree;

and document the 'negative value disables TSQ' in
Documentation/networking/ip-sysctl.txt
