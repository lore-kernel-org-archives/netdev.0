From: =?UTF-8?Q?Martin_Djern=C3=A6s?= <mdjernaes@pulz8.com>
Subject: md5 on listening sockets
Date: Thu, 23 Jul 2009 16:38:59 +0200
Message-ID: <aa9682190907230738y23636cc5yd8b4e7a854f7b59c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:58527 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbZGWOjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 10:39:01 -0400
Received: by ewy26 with SMTP id 26so1036573ewy.37
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 07:39:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been looking at using the md5 keys on a listening socket as one
means of restricting access to the socket. When I specify an md5 key
(with or without a peer ip address in the option) any tcp connect from
another IP address will be accepted by this connection if the source
IP is not found in the "md5sig->keys4" array.

The question is if this is intentional - and if does anyone know why?

It does not look like this is the best option as md5 keys appear to be
ignored and new connections will be accepted without keys if the peer
is not aware of this. Since a correctly specified peer will always be
expected to provide an md5 key, this does not cause an issue for TCP
sessions where both sides configure a key - only if the client fail to
provide it and the client is an unknown/rogue client from the point of
the server.

In the code in tcp_ipv4.c I do see the following comment which I think
Rick Payne from AYR added:

/*
 * RFC2385 MD5 checksumming requires a mapping of
 * IP address->MD5 Key.
 * We need to maintain these in the sk structure.
 */

But besides the mention of the TCP psudo header (which can/will use
the ip address from the socket) I do not see any mention of this
mapping in the RFC.

This additional "destination ip" (or "peer ip") check cause us to
blindly accept incoming connections without md5 keys on them


Lookup is doing the following:

	for (i = 0; i < tp->md5sig_info->entries4; i++) {
		if (tp->md5sig_info->keys4[i].addr == addr)
			return &tp->md5sig_info->keys4[i].base;
	}
	return NULL;

When a listener receive a new connection from a sender who is not
using the md5 hash the TCP code will do:

tcp_v4_inbound_md5_hash()
..
	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
	hash_location = tcp_parse_md5sig_option(th);
..
	/* We've parsed the options - do we have a hash? */
	if (!hash_expected && !hash_location)
		return 0;

which in turn is causing tcp not to discard this peer:

tcp_v4_do_rcv()
..
	if (tcp_v4_inbound_md5_hash(sk, skb))
		goto discard;

I have tested this on 2.6.28-13 (stock Ubuntu) and traced the code on
2.6.32-RC4 and both looks like they have the same behavior.

I'm aware of the recently committed fix:
http://marc.info/?l=linux-netdev&m=124785861111892&w=4 by John
Dykstra, but I believe that since this is only on copy this should
make no difference here.

Regards,
Martin Djernaes
