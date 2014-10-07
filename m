From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Mon, 06 Oct 2014 18:52:15 -0700
Message-ID: <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
	 <20140929092833.6c2cb7e9@urahara>
	 <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>
	 <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"rmody@brocade.com" <rmody@brocade.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Wheeler <netdev@lists.ewheeler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:61632 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbaJGBwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 21:52:18 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so6291680pab.20
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 18:52:18 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 18:57 -0700, Eric Wheeler wrote:
> This patch fixes an order:2 memory allocation error backtrace by 
> guaranteeing that memory is available during simultaneous high memory 
> pressure and packet rates when using 9k jumbo frames.
> 
> Tests between two systems (one patched, one not) succeeded with ~1TB of 
> data transferred over DRBD.  As expected, the unpatched host gave 
> warn_alloc_failed's, and the patched host worked correctly.  This patch 
> increases kernel memory usage by 32 order-2 allocation when this module is 
> loaded (512k on x86) which should be negligible on hosts that use 10GbE 
> cards.

This is highly suspect to me.

Most likely yet another truesize lie.

At a first glance, bnad_cq_setup_skb_frags() is buggy here :

skb->truesize += totlen;

With this kind of lies, system can OOM very fast.
