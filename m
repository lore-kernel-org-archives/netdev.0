From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 03 May 2013 07:14:15 -0700
Message-ID: <1367590455.29805.30.camel@edumazet-glaptop>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <20130501115103.58e40f37@kryten>
	 <1367375060.11020.24.camel@edumazet-glaptop>
	 <20130501035425.GD5221@bubble.grove.modra.org>
	 <1367384672.11020.34.camel@edumazet-glaptop>
	 <20130503013136.GN5221@bubble.grove.modra.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anton Blanchard <anton@samba.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>
To: Alan Modra <amodra@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56602 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690Ab3ECOOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 10:14:23 -0400
Received: by mail-pa0-f52.google.com with SMTP id bg2so945462pad.25
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 07:14:22 -0700 (PDT)
In-Reply-To: <20130503013136.GN5221@bubble.grove.modra.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 11:01 +0930, Alan Modra wrote:
> On Tue, Apr 30, 2013 at 10:04:32PM -0700, Eric Dumazet wrote:
> > These kind of errors are pretty hard to find, its a pity to spend time
> > on them.
> 
> Well, yes.  From the first comment in gcc PR52080.  "For the following
> testcase we generate a 8 byte RMW cycle on IA64 which causes locking
> problems in the linux kernel btrfs filesystem."
> 
> Did someone fix btrfs, but not check other kernel locks?  Having now
> hit the same problem again, have you checked that other kernel locks
> don't have adjacent bit fields in the same 64-bit word?  And comment
> the struct to ensure someone doesn't optimize those unsigned chars
> back to bit fields.

Not only spinlock, but atomic_t followed by bit fields.

BTW, if a spinlock is followed by bit fields, but bit fields
only changed when this spinlock is held, there is no problem, unless
spinlock is a ticket spinlock.

In af_unix, bug happens because the bit fields were changed without
spinlock being held (another global spinlock is used instead)

(ppc64 doesnt use ticket spinlocks yet)
