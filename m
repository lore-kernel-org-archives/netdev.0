From: "Wolfpaw - Dale Corse" <admin@wolfpaw.net>
Subject: RE: Linux 2.4.27 SECURITY BUG - TCP Local andREMOTE(verified)Denial of Service Attack
Date: Sun, 12 Sep 2004 13:36:15 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002b01c498ff$c4619b30$0200a8c0@wolf>
References: <02be01c498fd$3b63a370$0300a8c0@s>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <peter@mysql.com>, <netdev@oss.sgi.com>, <kaukasoi@elektroni.ee.tut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <02be01c498fd$3b63a370$0300a8c0@s>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Sul, 2004-09-12 at 19:52, Wolfpaw - Dale Corse wrote:
> > > > A) Why are the timeouts so long?
> > > 
> > > So you don't get random corruption
> > 
> > Hmm. I'll take your word for it, I'm not quite grasping it, but you
> > know quite a bit more about it then I do :) I would have 
> thought once 
> > a close is sent, the data has all been received and/or sent 
> anyway, so 
> > what would corrupt?
> 
> It has all arrived at least once. However you don't know if a 
> retransmitted packet took a long trip round the world and 
> popped out later. When that happens you need to be sure you 
> can tell old and new apart. The TIME_WAIT state is basically 
> "don't use this identical set of port/address data for long 
> enough to be sure any prior use has exited the internet in 
> its entirety.

That makes sense :)

> 
> > It _appears_ that when we close a socket (ie with 
> mysql_close) on the
> > client side, the client side closes the FD properly (though Mysql
> 
> socket != fd. If you close an fd and open you may get the 
> same fd but its a different socket. If its getting stuck 
> closing could you have another copy of the fd left open 
> somewhere or have passed it to a process you forked (thats a 
> classic nasty to track down error) ?

The way it generally works, is the daemon opens quite a few
sql connections for different reasons. It stores all of them
in a linked list (a somewhat implementation of persistent
connections, since the c API doesn't provide for it)

Every 60 seconds, the list is scanned for "unused" sql
connections, and calls mysql_close on them. The instance
of the actual list entry is not deleted until the next
run to give things 60 seconds to clear up. The issue
we were having is this..

Mysql connection: descriptor 3 (from mysql.net.fd)
Mysql connection closed (desc 3) (goes into CLOSE_WAIT now)
New connection (outbound) for regular proxy on Desc 3
  (this was created by a call to socket, and then connect)

Now the only way to get mysql to actually CLOSE the connection,
is go call close(mysql.net.fd) before destroying the structure.
This would have the effect of clearing the CLOSE_WAIT entry
from the netstat table, but it would also close the active
connection that was made with socket/connect (they have the
same FD). This is why I said they are being reused .. Our
software (being the client) has requested the connection closed,
and mysql hasn't closed it (unsure why.. Maybe data from the db
query still sitting on the SQL side?), so it then reuses what it
thinks is a clean FD, and it ends up needing to be closed AGAIN
to stop the other bug..

The other bug being, if I simply leave them, in a short time, MySQL
is saying "too many connections", and we can't query any data from
it. This also occurs with FIFO sockets (such as /tmp/mysql.sock)
wherein the connection simply sits as "ESTABLISHED".

I have been unable to find any sort of "flush" command to issue to
the SQL server on the socket, to tell it that I am done with whatever
data it has pulled out of the DB. This is obviously an SQL bug.

I assumed it an OS bug, mostly because the "socket" that used to
belong to the FD is still open at least on one side, I was thinking
this needs to be checked for somehow. What do you think?

> 
> > doesn't), and then if we call connect (which it does a lot, being a
> > proxy
> > server) it will reuse that FD. At this point, the Mysql 
> side still hasn't
> > closed it, and it is sitting in CLOSE_WAIT, where it 
> remains forever,
> since
> > it is in use by the client side elsewhere already. Should 
> connect be 
> > checking the "list of not connected, but state other then 
> CLOSED" list 
> > before it decides to use a particular FD? Or is this behavior 
> > intentional?
> 
> Sockets are two way at the TCP layer. "close" really means 
> "have finished sending". When both ends have finished sending 
> the connection is complete but not before. Thus if Mysql 
> daemon says "I am done" but you have open references to the 
> handle then it will stay open one way still.

So something needs to trigger a "flush" of the left over data
on the SQL side before closing the connection - yes?

Again - thank you for your input :)
D.
