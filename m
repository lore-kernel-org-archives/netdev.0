From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 18:00:37 -0700
Message-ID: <44482EB5.9030605@hp.com>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>	<20060420213305.GK26746@pb15.lixom.net> <20060420.172742.132879746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:15249 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932193AbWDUBAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 21:00:40 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060420.172742.132879746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Unfortunately, many benchmarks just do raw bandwidth tests sending to
> a receiver that just doesn't even look at the data.  They just return
> from recvmsg() and loop back into it.  This is not what applications
> using networking actually do, so it's important to make sure we look
> intelligently at any benchmarks done and do not fall into the trap of
> saying "even without cache warming it made things faster" when in fact
> the tested receiver did not touch the data at all so was a false test.

FWIW, netperf can be configured to access the buffers it gives to send() 
or gets from recv().  A ./configure --enable-dirty in TOT:

http://www.netperf.org/svn/netperf2/trunk

will enable two global options:

  -k dirty,clean # bytes to dirty, bytes to read clean on netperf side

  -K dirty,clean # as above, on netserver side.

And in such a netperf the test banner will include the string "dirty 
data" (alas the default output will not say how much :)

In say a TCP_STREAM test -k will affect what is done with a buffer 
before send() is called, and -K will affect what is done with a buffer 
_before_ recv() is called with that buffer.

-k N will cause the first N bytes of the buffer to be dirtied, and the 
next N bytes to be read clean

-k N, will cause the first N bytes of the buffer to be dirtied

-k ,N will cause the first N bytes of the buffer to be read clean

-k M,N will cause the first M bytes to be dirtied, the next N bytes to 
be read clean

Actually, that brings-up a question - presently, and for reasons that 
are lost to me in the mists of time - netperf will "access" the buffer 
before it calls recv().  I'm wondering if that should be changed to an 
access of the buffer after it calls recv()?

And I suspect related to all this is whether or not one should alter the 
size of the buffer ring being used by netperf, which by default is the 
SO_*BUF size divided by the send_size (or recv_size) plus one buffers - 
the -W option can control that.

rick jones
