From: Casey Carter <Casey@Carter.net>
Subject: Re: Strange UDP binding behavior (SO_BINDTODEVICE)
Date: Mon, 06 Oct 2003 17:50:53 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F81F1CD.8050803@Carter.net>
References: <20031005130154.5bd9d182.kevin@pheared.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-ha@lists.linux-ha.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kevin Dwyer <kevin@pheared.net>
In-Reply-To: <20031005130154.5bd9d182.kevin@pheared.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kevin Dwyer wrote:

>Hello,
>
>We have come across something that may be a bug, unless this behavior
>was intentional.
>
>The problem can be simulated by creating a socket, setting
>SO_BINDTODEVICE, and binding to a port.  Then, in a separate process we
>attempt to bind to the same port but without the SO_BINDTODEVICE option.
>The expected behavior is to get EINVAL because the port is already
>bound by a prior call.  However, it succeeds, and the second process
>steals the first process' packets.
>
>The likely code in question resides in net/ipv4/udp.c:
>
>        for (sk2 = udp_hash[snum & (UDP_HTABLE_SIZE - 1)];
>             sk2 != NULL;
>             sk2 = sk2->next) {
>                if (sk2->num == snum &&
>                    sk2 != sk &&
>                    sk2->bound_dev_if == sk->bound_dev_if &&
>                    (!sk2->rcv_saddr ||
>                     !sk->rcv_saddr ||
>                     sk2->rcv_saddr == sk->rcv_saddr) &&
>                    (!sk2->reuse || !sk->reuse))
>                        goto fail;
>        }
>
>The condition (sk2->bound_dev_if == sk->bound_dev_if) will fail because
>sk2->bound_dev_if will be the ifindex of the interface we bound to, and
>sk->bound_dev_if will be 0, since we didn't bind to a specific
>interface.
>
>Lars Ellenberg suggests something like:
>|       (!sk2->bound_dev_if ||
>|        !sk->bound_dev_if ||
>|        sk2->bound_dev_if == sk->bound_dev_if) &&
>
>Which on its face appears to clear the bug.  I don't see any obvious
>downsides to it either, but this is why I'm here.
>
>So, is this intentional or a bug?
>
>Thanks.
>
>  
>
This is not a bug, it's a feature!  It is possible to use multiple 
sockets with the same port number bound to different interfaces (where 
"no interface" is one possible choice).  The UDP packet delivery code 
favors the socket that is bound to the interface through which packets 
are received. So, if I am only interested in packets for port 6666 on 
eth1, then I am prioritized ahead of the socket bound to "no interface" 
port 6666.  The only way you can "steal" packets is to create sockets 
and SO_BINDTODEVICE them "below" another process's non-interface-bound 
socket.  This is a clear security issue, and is the main reason for 
restricting SO_BINDEVICE to users with CAP_NET_ADMIN.

-- 
Casey Carter
Casey@Carter.net
ccarter@cs.uiuc.edu
AIM: cartec69
