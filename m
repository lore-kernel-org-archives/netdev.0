From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: mmap RX_RING socket issue 32b application running on 64b kernel.
Date: Wed, 7 Nov 2012 18:58:55 +0100
Message-ID: <CAMJ=MEfeMDC3H2bjKz9XA4072Vo7U17108N4bK77q0GvUEF09w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43739 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab2KGR7Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 12:59:16 -0500
Received: by mail-ob0-f174.google.com with SMTP id uo13so1871735obb.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 09:59:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have an application using raw Ethernet sockets in combination with
the mmaped RX_RING.
The application is running on a Cavium MIPS processor (64bit) and the
application code is compiled with the N32 ABI.

Since the ring buffer is shared between the Linux kernel and the
application there is a conflict in the way the data is presented.
Each buffer in the ring has a header that has following structure:
(File http://lxr.free-electrons.com/source/include/linux/if_packet.h )
103 struct tpacket_hdr {
104         unsigned long   tp_status;
105         unsigned int    tp_len;
106         unsigned int    tp_snaplen;
107         unsigned short  tp_mac;
108         unsigned short  tp_net;
109         unsigned int    tp_sec;
110         unsigned int    tp_usec;
111 };

The status field indicates that the buffer belongs to the kernel or to
the user. Note that an unsigned long is used to represent the field.
In the kernel the long is 64 bit while in application space the long
is only 32bit, so the bits do not match.

After adapting the code to take this into account my program works well=
=2E
In my test program I have defined a new struct where I change the
=93unsigned long=94 into an =93unsigned long long=94:

struct tpacket_hdr_64 {
  unsigned long long tp_status;
  unsigned int tp_len;
  unsigned int tp_snaplen;
  unsigned short tp_mac;
  unsigned short tp_net;
  unsigned int tp_sec;
  unsigned int tp_usec;
};

In my opinion this is not a correct solution. It should be solved
somewhere in the include file I used so that it is transparent for the
application.
Please comment.

---
Ronny
