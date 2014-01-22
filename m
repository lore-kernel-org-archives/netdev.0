From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: packet mmap related oops (with reproducer)
Date: Wed, 22 Jan 2014 23:45:49 +0100
Message-ID: <52E04A1D.8080803@redhat.com>
References: <bug-1054537-176318@bugzilla.redhat.com> <bug-1054537-176318-JYaNmE5vAr@bugzilla.redhat.com> <20140122223920.GA18162@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michel Lespinasse <walken@google.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755804AbaAVWqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 17:46:00 -0500
In-Reply-To: <20140122223920.GA18162@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 01/22/2014 11:39 PM, Dave Jones wrote:
> We had a Fedora user report this bug, with a reproducer (below).
>
> On Fri, Jan 17, 2014 at 06:52:06AM +0000, bugzilla@redhat.com wrote:
>   > https://bugzilla.redhat.com/show_bug.cgi?id=1054537
>   >
>   >
>   >
>   > --- Comment #2 from Karl Auerbach <karl@iwl.com> ---
>   >   --> https://bugzilla.redhat.com/attachment.cgi?id=851413
>   > Simple program to cause this kernel issue
>   >
>   > This is a C program that must be run with root privilege.  It runs fine on
>   > older kernels but causes a kernel problem on the most recent one.
>   >
>   > The code creates a raw socket with transmit and receive ring buffers.
>   >
>   > The rings are then made visible via mmap().
>   >
>   > When munmap() is called things go awry.
>   >
>   > The code in this example was quickly lifted from a larger body of code that has
>   > been running for several years.

It looks to be THP related, you can also use the Linux kernel
selftest suite for networking to trigger that, I've reported
it here:

   https://lkml.org/lkml/2014/1/10/427

Vlastimil seems to have proposed some possibilities, but it
seems discussion stalled for now.

Cheers,

Daniel

> #include <assert.h>
> #include <errno.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <stdarg.h>
> #include <unistd.h>
>
> #include <arpa/inet.h>
> #include <sys/ioctl.h>
> #include <sys/mman.h>
> #include <sys/socket.h>
> #include <sys/un.h>
> #include <sys/user.h>
>
> #include <features.h>    /* for the glibc version number */
> #include <net/ethernet.h>
> #include <linux/if_packet.h>
> #include <linux/if_ether.h>
>
> #include <net/if.h>
> #include <netinet/in.h>
> #include <sys/ioctl.h>
> #include <sys/types.h>
> #include <linux/if_tun.h>
>
> #define NIL   0
>
> typedef int SOCKET;
>
> int main(int argc, char *argv)
> {
> size_t              RxMmap_Size;
> size_t              TxMmap_Size;
> unsigned int        Ether_Sz;
> unsigned int        Block_Sz_Order;
> unsigned int        Block_Sz;
> unsigned int        Block_Cnt;
> unsigned int        Frame_Sz;
> unsigned int        Frame_Cnt;
> unsigned int        Frames_Per_Block;
>
> void *              Mmap_Addr;
> size_t              Mmap_Size;
> size_t		    TXDataOffset;
>
> SOCKET              Socket;
>
> struct tpacket_req ring_req;
>
> Ether_Sz = 1518;
> Block_Sz = Ether_Sz;
> Block_Sz_Order = 2; // 16384 byte blocks
> Block_Cnt = 1000;
>
> Socket = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
> if (Socket == -1)
>    {
>    perror("socket failed");
>    return 1;
>    }
>
> Frame_Sz = TPACKET_ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN) + Ether_Sz);
> TXDataOffset = TPACKET2_HDRLEN - sizeof(struct sockaddr_ll);
>
> Block_Sz = getpagesize() << Block_Sz_Order;
>
> Frames_Per_Block = Block_Sz / Frame_Sz;
> Frame_Cnt = Frames_Per_Block * Block_Cnt;
>
> RxMmap_Size = Block_Sz * Block_Cnt;
> TxMmap_Size = RxMmap_Size;
>
> Mmap_Size = RxMmap_Size + TxMmap_Size;
>
> // Establish receive ring
> // For convenience we will let it be the same size as the TX ring
> // The mmap size calculations, far above, assume that the
> // rings are the same size.
> ring_req.tp_block_nr = Block_Cnt;
> ring_req.tp_frame_size = Frame_Sz;
> ring_req.tp_block_size = Block_Sz;
> ring_req.tp_frame_nr = Frame_Cnt;
> if (setsockopt(Socket, SOL_PACKET, PACKET_RX_RING,
>                 (char *)&ring_req, sizeof(ring_req)) < 0)
>    {
>    perror("Setsockopt RX_RING failed");
>    close(Socket);
>    return -1;
>    }
>
> // Establish transmit ring
> // For convenience we will let it be the same size as the RX ring
> // The mmap size calculations, far above, assume that the
> // rings are the same size.
> ring_req.tp_block_nr = Block_Cnt;
> ring_req.tp_frame_size = Frame_Sz;
> ring_req.tp_block_size = Block_Sz;
> ring_req.tp_frame_nr = Frame_Cnt;
> if (setsockopt(Socket, SOL_PACKET, PACKET_TX_RING,
>                 (char *)&ring_req, sizeof(ring_req)) < 0)
>    {
>    perror("Setsockopt TX_RING failed");
>    close(Socket);
>    return -1;
>    }
>
> Mmap_Addr = mmap(NIL, Mmap_Size, PROT_READ | PROT_WRITE,
>                   MAP_SHARED | MAP_LOCKED, Socket, 0);
>
> if (Mmap_Addr == MAP_FAILED)
>    {
>    perror("mmap failed");
>    return 1;
>    }
>
> if (Mmap_Addr != MAP_FAILED)
>    {
>    (void)munmap(Mmap_Addr, Mmap_Size);
>    }
>
> close(Socket);
> return 0;
> }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
