From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 13:42:06 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030617.134206.133917056.davem@redhat.com>
References: <OF296D6F92.1C7252A9-ON85256D48.00713BCF@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: garzik@pobox.com, shemminger@osdl.org, Valdis.Kletnieks@vt.edu,
	stekloff@us.ibm.com, lkessler@us.ibm.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: girouard@us.ibm.com
In-Reply-To: <OF296D6F92.1C7252A9-ON85256D48.00713BCF@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Janice Girouard <girouard@us.ibm.com>
   Date: Tue, 17 Jun 2003 15:40:48 -0500
   
   From:  David S. Miller" <davem@redhat.com>
         Date: 06/17/2003 03:27 PM
   
         On RX, clever RX buffer management is what we need.
   
   What RX buffer management are you proposing?  I'm having a hard time
   understanding how  you'll get rid of the copy without support from the
   card.
   
Sigh... someone write store email down somewhere for the next time
someone asks about this.

The "one true way (tm)" works like this:

1) Chip has a "flow cache", LRU based, managed like routing caches
    in many production router implementations.  Difference is
    that it merely does flow watching.

    Flow entries are keyed on saddr/daddr/sport/dport.  Flow misses
    kill the oldest entry, and replace it with the new one.

    Entries are only created in response to full sized data
    packets.

2) The receive buffering is segmented into small (256 byte) and
    PAGE sized buffers.  IP/TCP/whatever headers (determined using
    a simply programmable header parser logic, so you can do things
    like RPC etc. headers for NFS) are put into the "small" buffers,
    data portions for matching flows get accumulated into the PAGE
    sized buffers.

    It is implied that the card's flow cache keeps track of the
    pointers into page it is currently trying to fill for that
    flow.

So the first time you see a flow, you add a entry and grab a page
buffer and stick the data part into the page buffer and the
TCP/IP/etc. headers into a "small" buffer.  You defer a configurable
amount of time waiting for more TCP data packets (a packet train)
to accumulate more into the PAGE buffer for that flow.

Such receive buffers are presented to the stack as a linked list
of packets, with some indicator that together their data parts are
filling a page.

Things like "sys_receivefile()" and NFS flip these things into the
filesystem page cache.

I'm surprised this isn't evident to more people...
