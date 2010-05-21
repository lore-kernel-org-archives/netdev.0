From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 22:49:44 -0700 (PDT)
Message-ID: <20100520.224944.102694876.davem@davemloft.net>
References: <20100520172918.GA17613@shamino.rdu.redhat.com>
	<20100520231630.GA22593@gondor.apana.org.au>
	<20100521003939.GA2223@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37600
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754702Ab0EUFtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 01:49:35 -0400
In-Reply-To: <20100521003939.GA2223@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 20 May 2010 20:39:39 -0400

> On Fri, May 21, 2010 at 09:16:30AM +1000, Herbert Xu wrote:
>> On Thu, May 20, 2010 at 01:29:18PM -0400, Neil Horman wrote:
>> >
>> > So, I'm testing this patch out now, and unfotunately it doesn't seem to be
>> > working.  Every frame seems to be holding a classid of 0.  Trying to figure out
>> > why now.
>> 
>> Not very surprising since tun.c doesn't go through the normal
>> socket interface.  I'll send a additional patch for that.
>> 
> I don't think thats it.  I think its a chicken and egg situation.  I think the
> problem is that tasks can't be assigned to cgroups until their created, and in
> that time a sock can be created.  Its a natural race.  If you create a socket
> before you assign it to a cgroup, that socket retains a classid of zero.  I'm
> going to try modify the patch to update sockets owned by tasks when the cgroup
> is assigned.

Neil, you must not be using Herbert's most recent patch.

Either that or you haven't even read it.

Herbert's most recent patch doesn't create this chicken and egg
problem you mention because it explicitly watches for cgroupid changes
at all socket I/O operations including sendmsg() and sendmsg().  And
if it sees a different cgroupid at a socket I/O call, it updates the
cgroupid value in the socket.

So you very much can change the cgroup of the process mid-socket
ownership and it will work.

The only problem is, as Herbert stated, tun.  Because it does it's
networking I/O directly by calling netif_receive_skb() so it won't
hit any of Herbert's cgroup check points.
