From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Thu, 24 Nov 2016 14:42:38 +1100
Message-ID: <20161124144238.7dce65bf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jarod Wilson <jarod@redhat.com>,
        Erik Arfvidson <erik.arfvidson@unisys.com>,
        David Kershner <david.kershner@unisys.com>
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in:

  drivers/staging/unisys/include/iochannel.h

between commit:

  d0c2c9973ecd ("net: use core MTU range checking in virt drivers")

from the net-next tree and commit:

  b18f9c676f93 ("staging: unisys: include: fix pound defines")

from the staging tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/staging/unisys/include/iochannel.h
index 9081b3f8779c,c43da782f37e..000000000000
--- a/drivers/staging/unisys/include/iochannel.h
+++ b/drivers/staging/unisys/include/iochannel.h
@@@ -113,10 -117,12 +117,10 @@@ enum net_types 
  
  };
  
- #define		ETH_MIN_DATA_SIZE 46	/* minimum eth data size */
- #define		ETH_MIN_PACKET_SIZE (ETH_HLEN + ETH_MIN_DATA_SIZE)
 -#define ETH_HEADER_SIZE 14	/* size of ethernet header */
 -
+ #define ETH_MIN_DATA_SIZE 46	/* minimum eth data size */
 -#define ETH_MIN_PACKET_SIZE (ETH_HEADER_SIZE + ETH_MIN_DATA_SIZE)
++#define ETH_MIN_PACKET_SIZE (ETH_HLEN + ETH_MIN_DATA_SIZE)
  
- #define		VISOR_ETH_MAX_MTU 16384	/* maximum data size */
 -#define ETH_MAX_MTU 16384	/* maximum data size */
++#define VISOR_ETH_MAX_MTU 16384	/* maximum data size */
  
  #ifndef MAX_MACADDR_LEN
  #define MAX_MACADDR_LEN 6	/* number of bytes in MAC address */
@@@ -286,9 -304,9 +302,9 @@@ struct net_pkt_xmt 
  	int len;	/* full length of data in the packet */
  	int num_frags;	/* number of fragments in frags containing data */
  	struct phys_info frags[MAX_PHYS_INFO];	/* physical page information */
 -	char ethhdr[ETH_HEADER_SIZE];	/* the ethernet header  */
 +	char ethhdr[ETH_HLEN];	/* the ethernet header  */
  	struct {
- 		/* these are needed for csum at uisnic end */
+ 		/* These are needed for csum at uisnic end */
  		u8 valid;	/* 1 = struct is valid - else ignore */
  		u8 hrawoffv;	/* 1 = hwrafoff is valid */
  		u8 nhrawoffv;	/* 1 = nhwrafoff is valid */
@@@ -321,29 -341,41 +339,41 @@@ struct net_pkt_xmtdone 
   */
  #define RCVPOST_BUF_SIZE 4032
  #define MAX_NET_RCV_CHAIN \
 -	((ETH_MAX_MTU + ETH_HEADER_SIZE + RCVPOST_BUF_SIZE - 1) \
 +	((VISOR_ETH_MAX_MTU + ETH_HLEN + RCVPOST_BUF_SIZE - 1) \
  	/ RCVPOST_BUF_SIZE)
  
+ /*
+  * rcv buf size must be large enough to include ethernet data len + ethernet
+  * header len - we are choosing 2K because it is guaranteed to be describable.
+  */
  struct net_pkt_rcvpost {
- 	    /* rcv buf size must be large enough to include ethernet data len +
- 	     * ethernet header len - we are choosing 2K because it is guaranteed
- 	     * to be describable
- 	     */
- 	    struct phys_info frag;	/* physical page information for the */
- 					/* single fragment 2K rcv buf */
- 	    u64 unique_num;
- 	    /* unique_num ensure that receive posts are returned to */
- 	    /* the Adapter which we sent them originally. */
+ 	/* Physical page information for the single fragment 2K rcv buf */
+ 	struct phys_info frag;
+ 
+ 	/*
+ 	 * Ensures that receive posts are returned to the adapter which we sent
+ 	 * them from originally.
+ 	 */
+ 	u64 unique_num;
+ 
  } __packed;
  
+ /*
+  * The number of rcvbuf that can be chained is based on max mtu and size of each
+  * rcvbuf.
+  */
  struct net_pkt_rcv {
- 	/* the number of receive buffers that can be chained  */
- 	/* is based on max mtu and size of each rcv buf */
- 	u32 rcv_done_len;	/* length of received data */
- 	u8 numrcvbufs;		/* number of receive buffers that contain the */
- 	/* incoming data; guest end MUST chain these together. */
- 	void *rcvbuf[MAX_NET_RCV_CHAIN];	/* list of chained rcvbufs */
- 	/* each entry is a receive buffer provided by NET_RCV_POST. */
+ 	u32 rcv_done_len; /* length of received data */
+ 
+ 	/*
+ 	 * numrcvbufs: contain the incoming data; guest side MUST chain these
+ 	 * together.
+ 	 */
+ 	u8 numrcvbufs;
+ 
+ 	void *rcvbuf[MAX_NET_RCV_CHAIN]; /* list of chained rcvbufs */
+ 
+ 	/* Each entry is a receive buffer provided by NET_RCV_POST. */
  	/* NOTE: first rcvbuf in the chain will also be provided in net.buf. */
  	u64 unique_num;
  	u32 rcvs_dropped_delta;
