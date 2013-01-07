From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V2] tcp: introduce raw access to experimental
 options
Date: Mon, 07 Jan 2013 08:44:11 -0800
Message-ID: <1357577051.6919.3171.camel@edumazet-glaptop>
References: <1357575210-52926-1-git-send-email-elelueck@linux.vnet.ibm.com>
	 <1357575210-52926-2-git-send-email-elelueck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ubacher@de.ibm.com,
	raspl@de.ibm.com, frankbla@de.ibm.com, samudrala@us.ibm.com
To: elelueck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:50712 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab3AGQoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:44:15 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so8708871dad.38
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 08:44:14 -0800 (PST)
In-Reply-To: <1357575210-52926-2-git-send-email-elelueck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 17:13 +0100, elelueck@linux.vnet.ibm.com wrote:
> From: Einar Lueck <elelueck@linux.vnet.ibm.com>
> 
> This patch adds means for raw acces to TCP expirimental options
> 253 and 254. The intention of this is to enable user space
> applications to implement communication behaviour that depends
> on experimental options. For that, new (set|get)sockopts are
> introduced:
> 
> TCP_EXPOPTS (get & set): TCP experimental options to be added to
> 			 packets
> TCP_RECV_EXPOPTS (get):  experimental options received with last
> 			 packet
> TCP_RECV_SYN_EXPOPTS (get): experimental options received with
> 			 SYN packet
> 
> Access to these options is allowed only with CAP_NET_RAW privilige.
> 
> TCP experimental options 253 and 254 configured via TCP_EXPOPTS on
> any TCP socket are appended to every packet that is sent as long
> as there is enough room left. If there is not enough room left they
> are silently dropped.
> 
> Listening sockets reply to SYN packets with SYN ACK packets containing
> TCP experimental options 253 and 254 as configured via TCP_EXPOPTS, too.
> If a TCP connection gets established the configured experimental options
> are the defaults for the new socket, too. Thus, a getsockopt on the
> resulting accept socket for TCP_EXPOPTS returns the same stuff configured
> on the listening socket.
> 
> As mentioned above, even after the 3whs is complete, experimental options
> are sent with every packet. To enable user space applications to distinguish
> between what has been advertized via SYN and what has been received with the
> last packet the aforementioned TCP_RECV_SYN_EXPOPTS and TCP_RECV_EXPOPTS are
> introduced.
> 
> Today, experimental option 253 (COOKIE) and 254 (FASTOPEN) are already
> exploited. For co-existence the following approach has been taken:
> 
> General remarks:
> * Interface to COOKIE and FASTOPEN stays the same
> Sender side:
> 1. COOKIE and FASTPATH code adds own options first (if applicable)
> 2. Finally, if enough room is left, TCP_EXPOPTS experimental options are
>    appended
> Receiver side:
> 1. ALL 253 and 254 experimental options are made available via
>    TCP_RECV(_SYN)_EXPOPTS
> 2. COOKIE and FASTOPEN code check if there is any option relevant for them
> 
> References:
> http://tools.ietf.org/html/draft-ietf-tcpm-experimental-options-02
> 
> Signed-off-by: Einar Lueck <elelueck@linux.vnet.ibm.com>
> ---
>  include/linux/tcp.h      |  23 +++++++++
>  include/net/tcp.h        |   3 ++
>  include/uapi/linux/tcp.h |   3 ++
>  net/ipv4/tcp.c           | 122 +++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_input.c     | 119 ++++++++++++++++++++++++++++++---------------
>  net/ipv4/tcp_ipv4.c      |  14 ++++++
>  net/ipv4/tcp_minisocks.c |  17 +++++++
>  net/ipv4/tcp_output.c    |  47 +++++++++++-------
>  8 files changed, 293 insertions(+), 55 deletions(-)

Thats a big addition, and for example doesn't help if the SYNACK should
include an option that is depending on the content of SYN message.

For TCP fastopen for example, the cookie we send to the client is not a
constant cookie.

Also TCP coalescing of TCP collapse will merge several skbs, so storing
"the last received options" in the socket is kind of not well defined
semantic.

It looks like you need to add hooks and kernel modules to fully use
experimental options, like congestion control modules.
