From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 11:41:12 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410291141.12330.jdmason@us.ibm.com>
References: <468F3FDA28AA87429AD807992E22D07E031286C0@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Christoph Hellwig" <hch@infradead.org>, <jgarzik@pobox.com>,
        "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E031286C0@orsmsx408>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 29 October 2004 10:35 am, Venkatesan, Ganesh wrote:
> >There seems to be 3 ways around this problem.
> >1) change the unsigned long fields in ixgb_buffer to unsigned ints
>
> (this
>
> >decreases the size of the struct enough to use kmalloc)
>
> PATCH netdev-2.6 6/10 does this.

Problem with patch 6/10.

--- netdev-2.6/drivers/net/ixgb/ixgb.h  2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb.h      2004-10-15 13:15:51.000000000 
-0700
@@ -105,9 +105,9 @@ struct ixgb_adapter;
 struct ixgb_buffer {
        struct sk_buff *skb;
        uint64_t dma;
-       unsigned long length;
+       uint16_t length;
        unsigned long time_stamp;
-       unsigned int next_to_watch;
+       uint16_t next_to_watch;
 };

Since the 2 16bit fields are not contigious, they will take up 32bits each.  
This ballons the struct to still be too large.  By moving thse 2 fields next 
to one another, this fixes the problem and makes the struct small enough to 
use kmalloc for up to 4096 descriptors.  

The patch below removes the need for patch 7/10 (and I have verified this).

--- ixgb.h.orig 2004-10-29 11:36:06.757879120 -0700
+++ ixgb.h      2004-10-29 11:35:51.065001784 -0700
@@ -123,8 +123,8 @@ struct ixgb_adapter;
 struct ixgb_buffer {
        struct sk_buff *skb;
        uint64_t dma;
-       uint16_t length;
        unsigned long time_stamp;
+       uint16_t length;
        uint16_t next_to_watch;
 };


-- 
Jon Mason
jdmason@us.ibm.com
