From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 10:28:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410291028.18536.jdmason@us.ibm.com>
References: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408> <20041029130817.GA12301@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>, jgarzik@pobox.com,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041029130817.GA12301@infradead.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 29 October 2004 08:08 am, Christoph Hellwig wrote:
> On Fri, Oct 29, 2004 at 05:50:45AM -0700, Venkatesan, Ganesh wrote:
> > This is a trade-off between space allocated via kmalloc and vmalloc. My
> > understanding is that kmalloc space is more limited than vmalloc. Is
> > this incorrect?
>
> Yes. kmalloc space is only limited by the amount of free memory you have
> in your system, vmalloc has very low absolute limits (down to 64MB in
> some configurations)..
>
> > With the original implementation that used kmalloc for all allocations
> > in the driver, I have noticed allocation failures when the ring sizes
> > were set to 4096.
>
> 4096 what?

When the Tx or Rx descriptor queues are set greater than 3000 descriptors on 
64bit systems, the amount of memory the driver tries to allocate for this 
queue is too large for kmalloc. See ixgb_setup_tx_resources() of ixgb_main.c 
(line 611).  The cause of the problem is that ixgb_buffer grows large on 
64bit systems because of unsigned long fields in the struct.

There seems to be 3 ways around this problem.  
1) change the unsigned long fields in ixgb_buffer to unsigned ints (this 
decreases the size of the struct enough to use kmalloc)
2) Modify the driver to move/remove one of the unsigned long fields (most 
likely time_stamp)
3) replace kmalloc with vmalloc

e1000 made a similar change recently, which was accepted after some 
discussion.

-- 
Jon Mason
jdmason@us.ibm.com
