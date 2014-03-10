From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Mon, 10 Mar 2014 15:30:01 -0400 (EDT)
Message-ID: <20140310.153001.1202621819107314058.davem@davemloft.net>
References: <7457128.6VP2v68V93@x2>
	<87wqg8zfj4.fsf@xmission.com>
	<1394232722.17779.57.camel@flatline.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, sgrubb@redhat.com, rgb@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-audit@redhat.com, akpm@linux-foundation.org
To: eparis@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394232722.17779.57.camel@flatline.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Fri, 07 Mar 2014 17:52:02 -0500

> The second user Eric patched, audit_send_list(), can grow without bound.
> The number of skb's is going to be the size of the number of audit rules
> that root loaded.  We run the list of rules, generate an skb per rule,
> and add all of them to an skb_buff_head.  We then pass the skb_buff_head
> to a kthread so that current will be able to read/drain the socket.
> There really is no limit to how big the skb_buff_head could possibly
> grow.  This doesn't necessarily absolutely have to be lossless but it
> can actually quite reasonably be a whole lot of data that needs to get
> sent.  I know of no way to deliver unbounded lengths of data to the
> current task via netlink without blocking on more space in the socket.
> Even if the socket rmem was MAX_INT, how can we deliver more?  The rule
> size is unbounded.  How do I get an unbounded amount of data onto this
> side of the socket when I have to generate it all during the request...

This is what netlink dumps  are for.  It is how we are able to dump
routing tables with millions of routes to userspace.

By using normal netlink requests and netlink_unicast() for this, you
are ignoring an entire mechanism in netlink designed specifically to
handle this kind of situation.

Netlink dumps track state and build one or more SKBs (as necessary),
one by one, to form the reply.  It implements flow control, state
tracking for iteration, optimized SKB sizing and allocation, etc.
