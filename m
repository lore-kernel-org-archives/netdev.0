From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Bug 70021 - Call to munmap() causes system to partially hang;
 power cycle needed to recover.
Date: Wed, 26 Feb 2014 22:18:26 +0100
Message-ID: <530E5A22.5050000@redhat.com>
References: <20140226130559.65415dd5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, karl@iwl.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbaBZVSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 16:18:32 -0500
In-Reply-To: <20140226130559.65415dd5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2014 10:05 PM, Stephen Hemminger wrote:
> This bug appears to have been stuck in MM bugzilla and never
> addressed...

Sorry, just noticed your email to netdev right now.

mlock() fix for THP that indirectly affects PF_PACKET sits in AM's tree=
:

   http://ozlabs.org/~akpm/mmotm/broken-out/mm-include-vm_mixedmap-flag=
-in-the-vm_special-list-to-avoid-munlocking.patch

Thanks,

Daniel

> https://bugzilla.kernel.org/show_bug.cgi?id=3D70021
>
>
> [reply] [=E2=88=92]  Private Description Karl Auerbach 2014-02-05 00:=
51:02 UTC
> Created attachment 124531 [details]
> This is a small program that triggers the fault.  It requires root pr=
ivilege to run.
>
> Before kernel 3.12.1 one could mmap() the RX and TX ring buffers for =
a network socket and reliably release them with munmap().
>
> Starting with kernel 3.12.1 and running through the latest kernel I t=
ested (3.1.14) this no longer works.  The call to munmap() never return=
s.
>
> Parts of the system may continue to operate, but the system can not b=
e shut down by normal means.  It takes a hardware reset or power cycle =
to recover.
>
> I've got a short program, extracted from something we've been running=
 for several years, that triggers the problem.
>
> I believe that every kernel from 3.12.1 and forward faults when this =
is run.
>
> This has been reported to the Fedora crew, and it was suggested that =
I kick this upstream.  So here I am.
>
> ---
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
> int                 rcode;
>
> void *              Mmap_Addr;
> size_t              Mmap_Size;
> size_t		        TXDataOffset;
>
> SOCKET              Socket;
>
> struct tpacket_req ring_req;
>
> Ether_Sz =3D 1518;
> Block_Sz =3D Ether_Sz;
> Block_Sz_Order =3D 2; // 16384 byte blocks
> Block_Cnt =3D 1000;
>
> Socket =3D socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
> if (Socket =3D=3D -1)
>    {
>    perror("socket failed");
>    return 1;
>    }
>
> Frame_Sz =3D TPACKET_ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN) + Ether_Sz)=
;
> TXDataOffset =3D TPACKET2_HDRLEN - sizeof(struct sockaddr_ll);
>
> Block_Sz =3D getpagesize() << Block_Sz_Order;
>
> Frames_Per_Block =3D Block_Sz / Frame_Sz;
> Frame_Cnt =3D Frames_Per_Block * Block_Cnt;
>
> RxMmap_Size =3D Block_Sz * Block_Cnt;
> TxMmap_Size =3D RxMmap_Size;
>
> Mmap_Size =3D RxMmap_Size + TxMmap_Size;
>
> // Establish receive ring
> // For convenience we will let it be the same size as the TX ring
> // The mmap size calculations, far above, assume that the
> // rings are the same size.
> ring_req.tp_block_nr =3D Block_Cnt;
> ring_req.tp_frame_size =3D Frame_Sz;
> ring_req.tp_block_size =3D Block_Sz;
> ring_req.tp_frame_nr =3D Frame_Cnt;
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
> ring_req.tp_block_nr =3D Block_Cnt;
> ring_req.tp_frame_size =3D Frame_Sz;
> ring_req.tp_block_size =3D Block_Sz;
> ring_req.tp_frame_nr =3D Frame_Cnt;
> if (setsockopt(Socket, SOL_PACKET, PACKET_TX_RING,
>                 (char *)&ring_req, sizeof(ring_req)) < 0)
>    {
>    perror("Setsockopt TX_RING failed");
>    close(Socket);
>    return -1;
>    }
>
> fprintf(stderr, "Calling mmap\n");
> Mmap_Addr =3D mmap(NIL, Mmap_Size, PROT_READ | PROT_WRITE,
>                   MAP_SHARED | MAP_LOCKED, Socket, 0);
>
> if (Mmap_Addr =3D=3D MAP_FAILED)
>    {
>    perror("mmap failed");
>    return 1;
>    }
>
> fprintf(stderr, "Calling munmap\n");
> if (Mmap_Addr !=3D MAP_FAILED)
>    {
>    if (munmap(Mmap_Addr, Mmap_Size) !=3D 0)
>       {
>       perror("munmap failed");
>       return 1;
>       }
>    }
>
> fprintf(stderr, "Closing socket\n");
> if (close(Socket) !=3D 0)
>    {
>    perror("close failed");
>    return 1;
>    }
>
> fprintf(stderr, "Program returning\n");
> return 0;
> }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
