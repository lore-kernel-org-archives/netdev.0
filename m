From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 13:02:42 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020814030242.GA30872@anakin.wychk.org>
References: <20020813235103.GA28432@anakin.wychk.org> <200208140036.EAA22833@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208140036.EAA22833@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

> 
> I asked you not to do this. This is pathological case, and return
> value from this presents only academic interest.
> 
> 


Burk.  Sorry for that error.


> > We find the errno after the first connect is indeed EINPROGRESS. A 
> > read with 0 length returns -1, with an errno of 134. That corresponds
> > to ENOTCONN on Solaris.
> 
> F.e. if Solaris behaves in this way on normal not-nil read/write,
> it is fatally buggy. I do not understand why it works after this,
> just by plain luck.
> 
> read/write on not-yet-connected socket can only block (when blocking)
> or return EAGAIN otherwise. Well, or complete sucessfully.
>


Ok, let's try again.

Same OS, same conditions same program used, but this time we read and
write with a count of 1.


OSF1 4.0:

It seems even with a non-nil write it is very anti-social and returns
different error codes.

For read it returns -EWOULDBLOCK, while for write it returns -ENOTCONN.
On OSF1, the errno EWOULDBLOCK is the same as EAGAIN.

It looks like for socket reads and writes, OSF1 does the sanity
checks for read and write in a different order. This is a bug.


SunOS 5.6:

-ENOTCONN for both a read and write of 1 byte count.



Linux 2.4.18:

-EAGAIN in both read and write of one byte.



As you said that the fact that Solaris works at all with those semantics
is pure luck, so we try to understand it a bit better. We modify the program
further, and after the connection succeeds, we read some data and we print it
out.

For the write case, we use a simple `echo' server and write some data to
the server and read back from it, and see that it is ok. We sleep for a 
amount of time between the second connect call and the read / write call
to give it ample time for the 3 way handshake to complete. As a control
the same tests is done across all 3 operating systems.


We first start the server and telnet to it and make sure that it works
alright. We verify that this is true. We also start the server on the 
same computer to rule out endianness problems.


SunOS 5.6:

read case is ok.
write case is ok.

OSF1 4.0:

read case is ok.
write case is ok.

Linux 2.4.18:

read case is ok.
write case is ok.


So SunOS with -ENOTCONN semantics work. So does OSF1, but we note write
returns -ENOTCONN.

So if you say that it is indeed a bug, then both SunOS and OSF1 are
lucky.

But now that we have determined that is is not portable to use a read or 
a write to test if a non-blocking socket is connected or not, I'd like 
to hear your reasons why a read or a write returning -ENOTCONN is a
buggy behavior.



	-- G.
	
