From: Michael Chan <mchan.dev@gmail.com>
Subject: [RFC] TCP Multicast Extension
Date: Thu, 5 Nov 2009 10:12:21 -0800
Message-ID: <944511570911051012r5f70fa50y93be72ae3f9b633c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:47441 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbZKESMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 13:12:22 -0500
Received: by ywh40 with SMTP id 40so228605ywh.33
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2009 10:12:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am planning to implement a TCP extension named "Single-source
multicast optimization", proposed in

S. Liang and D. Cheriton "TCP-SMO: Extending TCP to Support
Medium-Scale Multicast Applications", Proc. IEEE Infocom 2002.

A sample use case of this extension would be a single data source
doing bulk transfer to a number of replication sites. In this case,
TCP-SMO provides for multicast of the bulk transfer and the
optimization of transport-level retransmissions using the conventional
and well-tested TCP implementation.

In a nutshell, a TCP multicast session with a single source (server)
consists of two parts: (1) an IP multicast session, and (2) a set of
ordinary TCP connections, one between the server and each multicast
client. Data is sent via IP multicast, while the individual TCP
connections are for retransmissions and client-to-server
communication.

The required changes to the kernel TCP implementation are as follows:

Server side:
1) Creating a TCP-SMO "master socket" that keeps track of statistics
of the unchanged, per-client TCP socket
2) Modifying connection establishment so when a new client connects,
the socket created is associated to the master socket
3) Modifying the ACK path so that clients' ACKs are delivered to
master socket for processing
4) Creating a multicast group associated with the master socket

Client side:
1) Add in ability to associate multicast traffic (from server) to the
TCP connection with server
2) Joining and leaving multicast groups with the TCP socket

Before any coding, I stumbled on the following issues and thought it'd
be best to learn from the experts:

1) Is someone already doing something similar in the kernel space?

2) The original implementation was for the 2.2 kernel and had a lot of
"#ifdef CONFIG_TCP_MULTICAST strewn across the different tcp-related
constructs, including the accept, init, recvmsg, sendmsg functions and
significant additions to struct sock. The 2.6 kernel put the
tcp-specific stuff into struct tcp_sock. Given that the kernel coding
style asked for reducing number of #ifdef's in non-header code, is it
considered acceptable practice to modify this struct and the numerous
tcp functions, or should a new struct tcp_smo_sock containing a
tcp_sock as the first member be a better alternative? From a design
perspective, it seems like defining a new struct is "cleaner". But
SMO, when enabled, really re-uses / modifies existing TCP behavior. It
isn't clear to me how code reuse can be achieved without some amount
of #ifdef's in the existing implementation.

3) My goal is to make as little changes as possible to the
implementation and to provide an easy way to enable SMO from
userspace. Therefore, I'm thinking of adding TCP-level socket options
for SMO-related operations. The alternative of a different
tcp_smo_sock struct (as explained above) seems to indicate changes to
the socket() system call as well, because I will need to change the
sock being allocated. So I really doubt that approach from the
viewpoint of easy user adoption.

4) Is this in fact a fool's errand since such an extension does not
conform to the networking subsystem's development practices and hence
won't ever get accepted?

Any comments are greatly appreciated!

Thanks,
Michael
