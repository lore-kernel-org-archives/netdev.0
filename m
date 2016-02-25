From: Heikki Hannikainen <hessu@hes.iki.fi>
Subject: Sending short raw packets using sendmsg() broke
Date: Thu, 25 Feb 2016 21:36:07 +0200 (EET)
Message-ID: <alpine.DEB.2.10.1602252105250.32432@jazz.he.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Alan Cox <alan@linux.intel.com>
To: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.fi ([85.188.1.20]:34216 "EHLO jazz.he.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933114AbcBYToc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 14:44:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Commit 9c7077622dd9174 added a check, ll_header_truncated(), which 
requires that a packet transmitted using sendmsg() with PF_PACKET, 
SOCK_RAW must be longer than dev->hard_header_len.

https://github.com/torvalds/linux/commit/9c7077622dd9174
https://github.com/torvalds/linux/blob/master/net/packet/af_packet.c#L2329

The bug that popped up is that an application (aprx) can no longer send 
short AX.25 packets using sendmsg(). Packets shorter than 77 bytes fail 
this check in ll_header_truncated(). With older kernels, no problem. AX.25 
(and some other protocols) have variable-length headers (somewhere between 
21 and 77 bytes in this case).

hard_header_len is set in drivers/net/hamradio/mkiss.c to 
AX25_KISS_HEADER_LEN + AX25_MAX_HEADER_LEN + 3 which works out to be 
(1+17+7*8+3)=77.

https://github.com/torvalds/linux/blob/master/drivers/net/hamradio/mkiss.c#L845

I guessed that we could probably set hard_header_len to be the minimum 
length of the packet header (AX25_KISS_HEADER_LEN + AX25_HEADER_LEN + 3) 
to make things work again, but I first asked Alan Cox for an opinion, and 
he says hard_header_len is set correctly to be the worst-case maximum 
header length, and that the ll_header_truncated commit should be reverted 
instead, since it doesn't take variable-length headers into account.

  - Hessu


---------- Forwarded message ----------
From: Heikki Hannikainen <hessu@hes.iki.fi>
To: Aprx software <aprx-software@googlegroups.com>
Date: Thu, 25 Feb 2016 11:22:05 +0200 (EET)
Subject: Re: packet size is too short Kernel Error with Aprx


Hi,

I spent a bit of time trying to understand what's happening. As described by 
others, if the packet being transmitted is short, the newer Linux kernels drop 
it, saying this in the kernel log (dmesg):

[405809.774704] aprx: packet size is too short (59 <= 77)

The check in the kernel is here:

https://github.com/torvalds/linux/blob/master/net/packet/af_packet.c#L2329

The check requires that the packet is longer than dev->hard_header_len. 
hard_header_len is set in linux drivers/net/hamradio/mkiss.c to 
AX25_KISS_HEADER_LEN + AX25_MAX_HEADER_LEN + 3 which works out to be 
(1+17+7*8+3)=77:

#define AX25_MAX_DIGIS                  8
#define AX25_HEADER_LEN                 17
#define AX25_ADDR_LEN                   7
#define AX25_DIGI_HEADER_LEN            (AX25_MAX_DIGIS * AX25_ADDR_LEN)
#define AX25_MAX_HEADER_LEN             (AX25_HEADER_LEN + 
AX25_DIGI_HEADER_LEN)

https://github.com/torvalds/linux/blob/master/drivers/net/hamradio/mkiss.c#L845

aprx uses the sendmsg() system call to send raw, variable-length-header AX25 
frames, and those may well be shorter than 77 bytes, if there are not many 
digipeaters in the path and the packet payload is short (not a bad idea on a 
1200 bit/s channel).

https://github.com/PhirePhly/aprx/blob/master/netax25.c#L758

It may be that hard_header_len should be set in mkiss.c to AX25_KISS_HEADER_LEN 
+ AX25_HEADER_LEN + 3 instead, if I understood this right. From 
include/linux/netdevice.h:

  *      @hard_header_len: Hardware header length, which means that this is the
  *                        minimum size of a packet.

As was pointed out, you *can* use the ax25-tools beacon program to transmit 
short packets! beacon does not use sendmsg(), it generates a pair of struct 
full_sockaddr_ax25 using libax25 ax25_aton() for source call and destination 
call+digipeater path, calls bind() to set the source call and then sends it 
with sendto(), simplified:

s = socket(AF_AX25, SOCK_DGRAM, 0);
len = ax25_aton(sourcecall, &src);
bind(s, (struct sockaddr *)&src, len);
dlen = ax25_aton(addr, &dest);
sendto(s, message, strlen(message), 0, (struct sockaddr *)&dest, dlen);

I didn't yet figure out why that works, maybe the sendto() of an AX25 datagram 
does not go through that hard_header_len check.

If I understood things right (I'm not entirely sure about the kernel sendmsg() 
code path yet), there are two things that could be done here:

- get the kernel fixed for supporting short raw AX.25 packet transmission again
- in the mean while, change aprx to call bind() and sendto() for every packet 
instead of a single sendmsg() - slightly unoptimal, but at 1200 bit/s and a few 
packets per second, who is going to notice...

   - Hessu, OH7LZB
