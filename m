From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 13 Sep 2002 15:04:39 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020913.150439.27187393.davem@redhat.com>
References: <20020912.161225.20790415.davem@redhat.com>
	<Pine.LNX.4.44.0209131553510.10203-100000@gp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, netdev@oss.sgi.com,
   pfeather@cs.unm.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com
In-Reply-To: <Pine.LNX.4.44.0209131553510.10203-100000@gp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: todd-lkml@osogrande.com
   Date: Fri, 13 Sep 2002 15:59:15 -0600 (MDT)
   
   not sure i understand what you're proposing

Cards in the future at 10gbit and faster are going to provide
facilities by which:

1) You register a IPV4 src_addr/dst_addr TCP src_port/dst_port cookie
   with the hardware when TCP connections are openned.

2) The card scans TCP packets arriving, if the cookie matches, it
   accumulated received data to fill full pages and wakes up the
   networking when either:

   a) full page has accumulated for a connection
   b) connection cookie mismatch
   c) configurable timer has expired

3) TCP ends up getting receive packets with skb->shinfo() fraglist
   containing the data portion in full struct page *'s
   This can be placed directly into the page cache via sys_receivefile
   generic code in mm/filemap.c or f.e. NFSD/NFS receive side
   processing.

   not also make the api for apps to allocate a buffer in userland that (for
   nics that support it) the nic can dma directly into?  it seems likely
   notification that the buffer was used would have to travel through the
   kernel, but it would be nice to save the interrupts altogether.
   
This is already doable with sys_sendfile() for send today.  The user
just does the following:

1) mmap()'s a file with MAP_SHARED to write the data
2) uses sys_sendfile() to send the data over the socket from that file
3) uses socket write space monitoring to determine if the portions of
   the shared area are reclaimable for new writes

BTW Apache could make this, I doubt it does currently.

The corrolary with sys_receivefile would be that the use:

1) mmap()'s a file with MAP_SHARED to write the data
2) uses sys_receivefile() to pull in the data from the socket to that file

There is no need to poll the receive socket space as the successful
return from sys_receivefile() is the "data got received successfully"
event.
   
   totally agreed.  this is a must for high-performance computing now (since 
   who wants to waste 80-100% of their CPU just running the network)?
   
If send side is your bottleneck and you think zerocopy sends of
user anonymous data might help, see the above since we can do it
today and you are free to experiment.

Franks a lot,
David S. Miller
davem@redhat.com
