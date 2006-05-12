From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: OOPS in forcedeth
Date: Fri, 12 May 2006 21:58:37 +0200
Message-ID: <200605122158.41329.carlos@cmartin.tk>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart39571876.BnNGr5YXN7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 124.red-82-159-197.user.auna.net ([82.159.197.124]:21436 "EHLO
	indy.cmartin.tk") by vger.kernel.org with ESMTP id S1751369AbWELT6a
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 15:58:30 -0400
Received: from kiopa.cmartin.tk (kiopa [10.0.0.15])
	by indy.cmartin.tk (Postfix) with ESMTP id 2B0E223026
	for <netdev@vger.kernel.org>; Fri, 12 May 2006 21:56:54 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart39571876.BnNGr5YXN7
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I just saw this last night when my desktop was shutting down. Not all=20
the OOPS was outputted, but I've found where it happens.

in forcedeth.c:1583 we see:
		pci_unmap_single(np->pci_dev, np->rx_dma[i],
				np->rx_skbuff[i]->end-np->rx_skbuff[i]->data,
				PCI_DMA_FROMDEVICE);

The assembler output is:

        movslq  %r12d,%rcx      # i, i
        xorl    %edi, %edi      # tmp226
        movq    320(%rbp,%rcx,8), %rax  # <variable>.rx_skbuff, D.20431
        movq    1344(%rbp,%rcx,8), %rsi # <variable>.rx_dma, addr
OOPS--->movq    216(%rax), %rdx # <variable>.end, <variable>.end
        subq    200(%rax), %rdx # <variable>.data, <variable>.end
        movq    256(%rbp), %rax # <variable>.pci_dev, hwdev
        testq   %rax, %rax      # hwdev
        leaq    112(%rax), %rcx #, tmp225
        movq    dma_ops(%rip), %rax     # dma_ops, dma_ops
        cmovne  %rcx, %rdi      # tmp225,, tmp226
        movl    $2, %ecx        #,
        call    *40(%rax)       # <variable>.unmap_single

 Which I think comes from dereferencing np->rx_skbuff[i]. I've not found=20
a reproducible way of doing this, and I've at times come back to my=20
room to find out that this computer has been forcibly shut down.

 I'm not familiar with this code. I hope someone here understands how=20
this can happen. I'll try to find a way to reproduce this meanwhile.

   cmn
=2D-=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |

--nextPart39571876.BnNGr5YXN7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQBEZOjxEVXxXOiy6a4RAqRgAJ9lWYYbO6O224l+jwtYL+kSwzH5RgCgiOEv
zFi6iFKOmR+CAauDUdursBA=
=vAs1
-----END PGP SIGNATURE-----

--nextPart39571876.BnNGr5YXN7--
