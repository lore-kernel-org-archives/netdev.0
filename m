From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 00:25:38 +0200
Message-ID: <20150921222538.GA31246@pox.localdomain>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/21/15 at 07:51am, Eric Dumazet wrote:
> The important part here is that we rehash an item, so we need to make
> sure to maintain consistent ->next field, and need to prevent compiler
> from using ->next as a temporary variable.
> 
> ptr->next = 1UL | ((base + offset) << 1);
> 
> Is dangerous because compiler could issue :
> 
> ptr->next = (base + offset);
> 
> ptr->next <<= 1;
> 
> ptr->next += 1UL;
> 
> Frankly, all this looks like an oversight in this code.
> 
> Not sure why the NULLS value is even recomputed.

The hash of the chain is part of the NULLS value. Since the
entry might have been moved to a different chain, the NULLS
value must be recalculated to contain the proper hash.

However, nobody is using the hash today as far as I can
see so we could as well just remove it and use the base
value only for the nulls marker.
