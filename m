From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 12:21:15 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020813022115.GA11627@anakin.wychk.org>
References: <20020811232546.GA27168@anakin.wychk.org> <200208120128.FAA16791@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208120128.FAA16791@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Mon, Aug 12, 2002 at 05:28:38AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> >					     I wanted to know what 
> > is the "correct" behavior for connect() by default with signal().
> 
> This simply does not matter, that's answer.
> 
> Actually, it is not so easy to implement restartable connect().
> I think this is the only reason why it not restartable in some OSes.
> 


True, probably.

Solaris will not restart a connect() even with the SA_RESTART set
in sa_flags.


> BTW could you make the following experiments on the same OSes:
> connect() on nonblocking socket, then repeat the connect()
> until it returns EISCONN. I guess the behaviour also will be different.
> 
> 



In brief, it is what we expect. After we do a connect() on a
non-blocking socket, it returns -EINPROGRESS. On subsequent
attempts it returns -EALREADY, then after it is connected
it returns -EISCONN. This behavior is consistent in all operating
systems which I have tested, which include the following:

Digital UNIX (OSF1 4.0)
Solaris (SunOS 5.6)
Linux (2.4.18)



On a LAN, when we run the program on first try, it is usually possible
to see -EINPROGRESS, -EALREADY, then -EISCONN. On subsequent
runs it normally returns -EINPROGRESS, then -EISCONN. This 
behavior can be explained by arp interaction and is consistent
with what we expect. 

On a WAN link, we see it return -EINPROGRESS, -EALREADY, then
-EISCONN all of the time.

Not tested on BSD yet, but I expect the results to be consistent
with my current findings. I can post the results later if you 
want them.

This is all fine, but what is interesting is what follows aftewards.
It was noted in Richard Steven's UNIX Network Programming that there are
several ways which you could find out to see if the connection has
succeeded in the background. One way mentioned is to call a read()
with a length of 0. With this method, it implies that read() must return
an error for an in-progress socket, otherwise there would be no way to
distinguish between a in-progress socket or a completed socket. To test
this, we write a program to connect to a open TCP port on a remote machine
on the WAN (to maximize the delay).

We set the socket to non-blocking then we issue a TCP connect(). 
connect() will return immediately while the connection is attempted
in the background asynchroniously. After the return from connect() 
we immediately issue a read() with a length of 0, and we note the
return value from read, the errno (if applicable). Finally, we issue
a second connect() and we note the return value, and errno (if 
applicable).

This is what happens on Digital UNIX (OSF1 4.0):

read() returns 0 with an errno of 36. 36 on Digital UNIX corresponds to
-EINPROGRESS. The errno isn't from the read but from our first
connect(). On second connect(), it returns -1, with an errno of
-EALREADY.

On Solaris (SunOS 5.6):

read() returns -1 with an errno of ENOTCONN. On second connect() it
returns -1 with an errno of EALREADY.

On Linux (v 2.4.18):

read() returns 0 with an errno of 115. On Linux 115 corresponds to 
-EINPROGRESS. So as with Digital UNIX, the errno isn't from read but
from our first conect(). On second connect(), it returns -1 with
an errno of -EALREADY.


Is using write() instead of read() a better way? 

To do this, we change our previous program, instead of reading 0
bytes this time we issue a write() of 0 bytes.

On Solaris (SunOS 5.6):

write() returns -1 with an errno of -ENOTCONN.

On Digital UNIX (OSF1 4.0):

write() returns -1 with an errno of -ENOTCONN. We note that previously
a read() returned 0. This behavior is inconsistent. There is a bug in 
Digital UNIX.

On Linux (v 2.4.18):

write() returns 0.


We note that Solaris and Linux are consistent with their read() and write()
for a in-progress socket.

I guess the moral story is don't try to use read() or write() to test 
if a socket is connected or not. :-) It looks to me that issuing a 
second connect() and see if it returns -EISCONN is probably a more
portable way. Of course, following up on the previous discussion, one
must handle a -EALREADY from connect() as well.



> > it should be trivial to hand edit my prevoius patch posted.
> 
> Yes, of course. Though the first part of it also from the class
> "does not matter", it is worth to do this just for sanity.
> 

Yep. Though I would really like it if it conforms to what the rest of 
the Unices does with that behavior.

So, we can agree that the first part should be applied on the next
networking merge? :-)


	-- G.
