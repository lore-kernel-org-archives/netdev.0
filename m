From: Fabienne Ducroquet <fabiduc@gmail.com>
Subject: Re: net/ipv4: commit d0733d2e29b breaks rtorrent
Date: Thu, 23 Jun 2011 01:02:39 +0200
Message-ID: <20110622230239.GA5009@localhost>
References: <20110622124045.GA3247@localhost>
 <20110622124727.GC19184@suse.de>
 <alpine.LNX.2.00.1106221508310.10066@nitsch.suse.de>
 <20110622145144.GA31734@localhost>
 <alpine.LNX.2.00.1106221654500.20275@nitsch.suse.de>
 <20110622085329.65c625de@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Reinhard Max <max@suse.de>, Marcus Meissner <meissner@suse.de>,
	sundell.software@gmail.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poutre.nerim.net ([62.4.16.124]:50380 "EHLO poutre.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756627Ab1FVXCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 19:02:41 -0400
Content-Disposition: inline
In-Reply-To: <20110622085329.65c625de@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 08:53:29AM -0700, Stephen Hemminger wrote:
> You can find code here http://libtorrent.rakshasa.no/
> but it is in C++ so there is an abnormally high indirection factor
> between reality of the bug and the code as written.

I had a look at the code, I found where bind is called, but it does not 
help: it is in libtorrent/src/net/socket_fd.cc:

	bool
	SocketFd::bind(const rak::socket_address& sa) {
	  check_valid();
	
	  return !::bind(m_fd, sa.c_sockaddr(), sa.length());
	}

check_valid() checks the validity of the socket FD.
It is called by the function:

	bool
	Listen::open(uint16_t first, uint16_t last, const rak::socket_address* bindAddress) {
	  close();

	  [ Checks that the range of the ports is OK, that the address 
	  is an inet or inet6 address, that the socket can be 
	  allocated.]

	  rak::socket_address sa;
	  sa.copy(*bindAddress, bindAddress->length());

	  for (uint16_t i = first; i <= last; ++i) {
	  sa.set_port(i);

	  if (get_fd().bind(sa) && get_fd().listen(50)) {
	     ...

in libtorrent/src/net/listen.cc. That function was called by:

	bool
	ConnectionManager::listen_open(port_type begin, port_type end) {
	  if (!m_listen->open(begin, end, rak::socket_address::cast_from(m_bindAddress)))
	    return false;
	
	  m_listenPort = m_listen->port();
	
	  return true;
	}

in libtorrent/src/torrent/connection_manager.cc, and it was itself 
called by Manager::listen_open() in rtorrent/core/manager.cc, which 
throws the error message I got because the call to

	torrent::connection_manager()->listen_open(portFirst, portLast)

fails.

So the question now is to find how the m_bindAddress used in 
ConnectionManager::listen_open is set, but I prefer not to do that right 
now.

> Did you try contacting the developer?

I've put him in the Cc: since the first message.

Fabienne
