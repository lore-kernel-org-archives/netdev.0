From: "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu>
Subject: udp_recvmsg: possible bug causing infinite hang?
Date: Sat, 9 Oct 2004 18:38:58 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.44.0410091824350.14026-100000@falcon.csc.calpoly.edu>
References: <Pine.LNX.4.44.0303270917290.29072-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0303270917290.29072-100000@home.transmeta.com>
List-Id: netdev.vger.kernel.org

I've encountered a hang condition during testing that only appeared when
we upgraded from Redhat EL 3 Update 2 to Redhat EL 3 Update 3.  After
looking at the differences, it appears to be caused by a change to
udp_recvmsg that also appears to have filtered back into the main kernel
tree, so it is possible that more people would be affected by this than
just redhat users.  Anyway, here is the scenario:

User space code sends a datagram on a blocking socket, and then calls
select() or poll() to wait for the reply.  When that pops with a non-error
condition (so we _know_ there is data to be read), recvfrom() is called.
Now, assume that somewhere along the way (it doesn't really matter where)
the UDP packet is corrupted.  Also, assume that no further inbound
datagrams are destined for this socket.  The new udp_recvmsg() will get
down to the bottom, and then will go to the try_again label, where it will
block forever in skb_recv_datagram() waiting for a datagram that will
never come.

The old code used to not have this try_again case, and so would always
just return immediately.

While this is a general problem for any program that uses UDP and relies
on the fact that select popped to insure that recvfrom won't hang, the
place where we always see it is in the DNS lookup portion of glibc.  The
send_dg() function is what actually hangs.

My questions are:

1.  Why was the code changed in this way?
2.  Is this a bug?  It seems so to me, because select (or poll)
specifically says there is data to read, and then it hangs when we try to
read it.  But, without the context of #1, it is hard to make this
determination.

Thanks,

Chad

