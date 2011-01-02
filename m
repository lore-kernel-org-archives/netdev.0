From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 2 Jan 2011 20:55:15 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101022024200.11481@swampdragon.chaosbits.net>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Jan 2011, stefani@seibold.net wrote:

> From: Stefani Seibold <stefani@seibold.net>
> 
> Changelog:
> 31.12.2010 first proposal
> 01.01.2011 code cleanup and fixes suggest by Eric Dumazet
> 02.01.2011 kick away UDP-Lite support
>            change spin_lock_irq into spin_lock_bh
> 	   faster udpcp_release_sock
> 	   base is now linux-next
> 
> UDPCP is a communication protocol specified by the Open Base Station
> Architecture Initiative Special Interest Group (OBSAI SIG). The
> protocol is based on UDP and is designed to meet the needs of "Mobile
> Communcation Base Station" internal communications. It is widely used by
> the major networks infrastructure supplier.
> 
> The UDPCP communication service supports the following features:
> 
> -Connectionless communication for serial mode data transfer
> -Acknowledged and unacknowledged transfer modes
> -Retransmissions Algorithm
> -Checksum Algorithm using Adler32
> -Fragmentation of long messages (disassembly/reassembly) to match to the MTU
>  during transport:
> -Broadcasting and multicasting messages to multiple peers in unacknowledged
>   transfer mode
> 
> UDPCP supports application level messages up to 64 KBytes (limited by 16-bit
> packet data length field). Messages that are longer than the MTU will be
> fragmented to the MTU.
> 
> UDPCP provides a reliable transport service that will perform message
> retransmissions in case transport failures occur.
> 
> The code is also a nice example how to implement a UDP based protocol as
> a kernel socket modules.
> 
> Due the nature of UDPCP which has no sliding windows support, the latency has
> a huge impact. The perfomance increase by implementing as a kernel module is
> about the factor 10, because there are no context switches and data packets or
> ACKs will be handled in the interrupt service.
> 
> There are no side effects to the network subsystems so i ask for merge it
> into linux-next. Hope you like it.
> 
> The patch is against linux next-20101231
> 
> - Stefani
> 
> Signed-off-by: Stefani Seibold <stefani@seibold.net>

[...]
> +
> +#define VERSION	"0.71"

I personally don't think this makes much sense.
Version numbers for individual modules tend to not get updated as the code 
changes over the years, which make them rather meaningless.
Since this module depends on functionallity of the kernel which it is 
compiled with, the actual (meaningful) version of this code is that of the 
kernel tree being compiled that includes this code. Which again makes this 
specific version define meaningless.

So, why not save a few lines of code and get rid of this rather pointless 
thing?

[...]
> +static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
> +{
> +	struct udpcp_dest *dest;
> +
> +	dest = __find_dest(sk, addr, port);

Why not

static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
{
     struct udpcp_dest *dest =  __find_dest(sk, addr, port);

?


[...]
> + * Release a routing table entry if no packed will be assembled

Don't you mean "packet" rather than "packed" here?


[...]
> + * Return true it the passed skb socket buffer is the last in the list

I believe you mean "Return true if the passed ..."


[...]
> +static void udpcp_flush_err(struct sock *sk, struct udpcp_dest *dest)
> +{
> +	struct inet_sock *inet = inet_sk(sk);
> +	struct udpcp_sock *usk = udpcp_sk(sk);
> +
> +	if (!inet->recverr)
> +		skb_queue_purge(&dest->xmit);
> +	else {

CodingStyle would want this as

     if (!inet->recverr) {
             skb_queue_purge(&dest->xmit);
     } else {

If one branch needs {} then both should get them.


[...]
> +	if (!dest->xmit_last)
> +		_udpcp_xmit(sk, dest);
> +	else {
> +		skb = dest->xmit_wait;

Same comment as above.
There are more occurences of this, I'm not going to point them all out.


[...]
> +static inline void udpcp_release_sock(struct sock *sk)
> +{
> +	struct udpcp_sock *usk = udpcp_sk(sk);
> +
> +	while (usk->timeout)
> +		udpcp_handle_timeout(sk);
> +	release_sock(sk);
> +        check_timeout(sk);

The line above uses spaces for indentation. It should use one tab.


[...]
> +static unsigned int udpcp_tx_queue_len(struct sock *sk, struct udpcp_dest *dest)
> +{
> +	struct sk_buff *skb;
> +	unsigned int n;
> +
> +	n = 0;

Might as well save a few lines and make this

static unsigned int udpcp_tx_queue_len(struct sock *sk, struct udpcp_dest *dest)
{
     struct sk_buff *skb;
     unsigned int n = 0;


[...]
> +static unsigned int udpcp_rx_queue_len(struct sock *sk, struct udpcp_dest *dest)
> +{
> +	struct sk_buff *skb;
> +	unsigned int n;
> +
> +	n = 0;

Here as well
        unsigned int n = 0;



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
