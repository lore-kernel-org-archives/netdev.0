From: sudeep list <sudeep.list@gmail.com>
Subject: turning off tcp checksums.
Date: Fri, 28 Jan 2005 10:59:31 -0700
Message-ID: <d50018af05012809595096dafe@mail.gmail.com>
Reply-To: sudeep list <sudeep.list@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,

I am trying to conduct some throughput experiments using a modified
TcP/IP stack. One of the things that I would like to do is to turn off
the TcP checksum. The idea is that the application computes its own
checksum, and having tcp duplicate the effort with a weaker checksum
doesnt make sense. This still leaves the tcp header without any
checksum, but since this is a lab environment, I hope to get away with
it for now :-)

I guess this means, modifying the tcp egress path, tcp ingress, and
turning off the hardware checksum capability on the two ends. I think
I have figured out how to change the egress path, but have no clue
about the ingress path.

egress path
------------------
Modify the tcp_ioctl function in net/ipv4/tcp.c to add a command that
sets the value of sk->sk_route_caps = NETIF_F_NO_CSUM

This shall result in the following code path being executed in the
tcp_sendmsg function.
.
.
841       if (sk->sk_route_caps &
843 	         (NETIF_F_IP_CSUM | NETIF_F_NO_CSUM |
844              NETIF_F_HW_CSUM))
845 	      skb->ip_summed = CHECKSUM_HW;
..

which (I hope) shall result in turning off the checksum calculation in
downstream code.

Ingress Path
-------------------
On this path, I saw that its the driver routines that set the value of
skb->ip_summed. I guess I could also change my driver routine to set
the ip_summed value to CHECKSUM_HW but that appears too rash.
1) I suspect it will also turn off the ip header checksum
2) Its only for *some* sockets in my stack that I want to turn off the
checksum, not all.

may be I can find out the socket that the skb is destined for, and if
its for "my" socket I could set the value appropriately, but that
appears too ugly (and inefficient ?).

How do I go about doing this ? Does my tcp_sendmsg modification make
sense or are there better ways of doing this ?

regards
Sudeep
