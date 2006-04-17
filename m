From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Mon, 17 Apr 2006 17:35:04 +0200
Message-ID: <4443B5A8.9010604@trash.net>
References: <20060417093632.GA29057@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:7358 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751146AbWDQPhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 11:37:45 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060417093632.GA29057@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> When application is bound to group N and it is less than 32
> and has first bit set (I tested with 1, 3, 5) and kernel broadcasts
> events to group number 1, application will receive messages, even if
> 1. it was not subscribed to that group
> 2. it was bound to different group
> 
> Attached trivial test module and userspace program.
> make
> insmod nltest.ko
> ./nluser -g5
> 
> see the dmesg.
> Test module sends data to group number 1, but application is bound and
> subscribed to group 5, but still receives messages.
> 
> This issue happens due to the following check in do_one_broadcast():
> 
> if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
> 	    !test_bit(p->group - 1, nlk->groups))
> 
> nlk->groups is set at bind time to the userspace provided bind group.
> So in above case it will be 5.
> But above test_bit() is supposed to check subscribed groups, which are
> set using set_bit(users_group - 1, nlk->groups).
> So when kernelspace broadcasts to group 1 above test_bit() returns true
> and message is delivered to the wrong socket.
> 
> Attached patch removes nlk->groups[0] assignment at bind time since it
> is completely meaningless due to subscription introduction.
> nltest.c - simple test module which broadcasts events to group 1.
> nluser.c - userspace application which receives data from socket bound
> to specified group.

This seems to be a misunderstanding, subscribing to groups using bind()
is kept for compatibility and doesn't use group numbers but bitmasks.
