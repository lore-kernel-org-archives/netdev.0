From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] macvtap: Let TUNSETOFFLOAD actually
 controll offload features.
Date: Wed, 19 Jun 2013 08:46:09 -0700
Message-ID: <1371656769.3252.320.camel@edumazet-glaptop>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com>
	  <1371653272-11703-2-git-send-email-vyasevic@redhat.com>
	 <1371655038.3252.312.camel@edumazet-glaptop> <51C1CDBC.4040003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	jasowang@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:39315 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756632Ab3FSPqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 11:46:15 -0400
Received: by mail-ee0-f50.google.com with SMTP id d49so3341316eek.9
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 08:46:14 -0700 (PDT)
In-Reply-To: <51C1CDBC.4040003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 11:26 -0400, Vlad Yasevich wrote:

> I think I do since vlan pointer may change even when I am holding
> rtnl.  rtnl is needed to change features.  rcu is needed to get
> the vlan pointer.
> 
> > (A BH handler will not change q->vlan )
> 
> No, but the _bh rcu calls seem to be used when dereferencing q->vlan.
> I am not sure the reason for that...

You mix the reader/fast path, properly using RCU,
and the writer path, using macvtap_lock ( a spinlock ).

That's clear sign you missed something.

> 
> >
> > BTW, it looks like ->vlan is protected by macvtap_lock
> 
> Right.  This is why I use rcu to get vlan.  rtnl is needed to avoid
> asserts in the feature change code.

The management should be allowed to sleep, and rcu_read_lock_bh()
disallows that.

Maybe some driver callback will really sleep and crash after your patch.

vi +69 drivers/net/macvtap.c

/*
 * RCU usage:
 * The macvtap_queue and the macvlan_dev are loosely coupled, the
 * pointers from one to the other can only be read while rcu_read_lock
 * or macvtap_lock is held.

Your patch does not respect the rules of this driver.

macvtap_lock is always acquired from process context, without any need
for _bh variant.

Quite frankly, I would switch this driver to use a mutex for
macvtap_lock. 

And simply remove it, as RTNL is most probably already owned.
