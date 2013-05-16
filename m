From: Ricardo =?utf-8?b?VHViw61v?= <rtpardavila@gmail.com>
Subject: Re: Single socket with =?utf-8?b?VFhfUklORw==?= and =?utf-8?b?UlhfUklORw==?=
Date: Thu, 16 May 2013 11:01:17 +0000 (UTC)
Message-ID: <loom.20130516T125157-378@post.gmane.org>
References: <loom.20130515T144941-798@post.gmane.org> <20130515224452.7CAA6224C4@mail.nwl.cc> <loom.20130516T111446-437@post.gmane.org> <20130516104541.GB18282@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37267 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab3EPLBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 07:01:38 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UcvwF-00035h-6i
	for netdev@vger.kernel.org; Thu, 16 May 2013 13:01:35 +0200
Received: from toxo.com.uvigo.es ([193.146.38.146])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 13:01:35 +0200
Received: from rtpardavila by toxo.com.uvigo.es with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 13:01:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Sutter <phil <at> nwl.cc> writes:

> So you do not call init_ring() twice as one may imply when reading your
> first mail? Please provide a complete code sample.
> 

Yes, I call it twice. The problem is that if I call it twice with the same
socket_fd, the second time I call it I get the EBUSY error from kernel. I
have to use two different sockets (two different socket_fd's, therefore) in
order to workaround this issue.

The code I use for calling "init_ring" is the one below. If in function
"init_rings", instead of using two different sockets (rx_socket_fd and
tx_socket_fd), I use a single socket, I get the EBUSY error from kernel.

Hope this clarifies, Cardo.

>>>>>>>>>>>>>>>>> FULL CODE EXAMPLE

/* init_rings */
int init_rings(ll_socket_t *ll_socket)
{
  	
  // 1) initialize rx ring
  if ( ( ll_socket->rx_ring_buffer
	  = init_ring(ll_socket->rx_socket_fd, PACKET_RX_RING) ) == NULL )
  {
    handle_app_error("Could not set initialize RX ring.");
  }
	
  // 2) initialize tx ring
  if ( ( ll_socket->tx_ring_buffer
	= init_ring(ll_socket->tx_socket_fd, PACKET_TX_RING) ) == NULL )
  {
    handle_app_error("Could not set initialize TX ring.");
  }
	
  // 3) set destination address for both kernel rings
  if ( set_sockaddr_ll(ll_socket) < 0 )
  {
    handle_app_error("Could not set sockaddr_ll for TX/RX rings.");
  }
  	
  return(EX_OK);

}

/* init_ring */
void *init_ring(const int socket_fd, const int type)
{
  	
  void *ring = NULL;

  int ring_access_flags = PROT_READ | PROT_WRITE;
  tpacket_req_t *p = init_tpacket_req(FRAMES_PER_RING);
  int ring_len = ( p->tp_block_size ) * ( p->tp_block_nr );
  	
  if ( setsockopt(socket_fd, SOL_PACKET, type, p, LEN__TPACKET_REQ) < 0 )
  {
     handle_sys_error("Setting socket options for this ring");
  }

  // 3) open ring
  if ( ( ring = mmap(NULL, ring_len, ring_access_flags, MAP_SHARED,
  			socket_fd, 0) ) == NULL )
  {
    log_sys_error("mmap()ing error");
  }
	
  return(ring);
	
}

/* init_tpacket_req */
tpacket_req_t *init_tpacket_req(const int frames_per_ring)
{
	tpacket_req_t *t = new_tpacket_req();
  	t->tp_block_size = frames_per_ring * getpagesize();
  	t->tp_block_nr = 1;
  	t->tp_frame_size = getpagesize();
  	t->tp_frame_nr = frames_per_ring;
  	return(t); 	
}

>>>>>>>>>>>>>>>>>
