From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: refcounting on dgram Unix sockets for poll(POLLOUT)
Date: Wed, 8 Dec 2010 21:01:00 +0000
Message-ID: <20101208210100.46c894dd@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:41368 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab0LHVC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 16:02:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When a connected datagram Unix socket is polled for POLLOUT events, the
poller is added in the wait_queue_head_t of the "server" socket:

net/unix/af_unix.c::unix_dgram_poll()
  other = unix_peer_get(sk);
  if (other) {
    if (unix_peer(other) != sk) {
      sock_poll_wait(file, &unix_sk(other)->peer_wait,
                     wait);
      ...

I wonder what prevent the "server" socket ("other") to be released
while the poller is still waiting for POLLOUT events.

There is a reference taken on the "server" socket when the client
connects:
net/unix/af_unix.c::unix_dgram_connect()
  other = unix_find_other(net, sunaddr, alen, sock->type,
            hash, &err);

But that reference could be released when the client socket
disconnects from another thread in one of the 3 possible locations:

1. unix_dgram_connect() when connecting to a different socket
     if (other != old_peer)
       unix_dgram_disconnected(sk, old_peer);
     sock_put(old_peer);

2. unix_dgram_sendmsg() when the server socket is SOCK_DEAD:
     unix_dgram_disconnected(sk, other);
     sock_put(other);

3. unix_release_sock() when the client socket is released:
     skpair = unix_peer(sk);
     if (skpair != NULL) {
       sock_put(skpair); /* It may now die */

I tried to release all the references to server_sockfd with
close(server_sockfd) on the server thread and with
connect(client_sockfd) to a different socket while client_sockfd is
being polled for POLLOUT events in a different thread, hoping to crash
the poller with the stack:
free_poll_entry()->remove_wait_queue()->spin_lock_irqsave()
But I didn't manage to crash the kernel.

Am I missing something? Is there another reference taken on
server_sockfd to protect the kernel from this scenario?

And btw, what is the test (unix_peer(other) != sk) in unix_dgram_poll()?

Alban
