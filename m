From: Gnome42 <gnome42@gmail.com>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Sat, 9 Sep 2006 13:39:53 -0400
Message-ID: <fa4052ef0609091039t65205ed3te10b5db571d20706@mail.gmail.com>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
	 <4501CA01.3050904@trash.net>
	 <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>
	 <4502C81E.600@trash.net>
	 <fa4052ef0609090735o6e17da23y75bd6f742a8a29be@mail.gmail.com>
	 <4502EA5C.5020101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:42628 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751336AbWIIRjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 13:39:54 -0400
Received: by py-out-1112.google.com with SMTP id n25so1387388pyg
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2006 10:39:54 -0700 (PDT)
To: "Patrick McHardy" <kaber@trash.net>
In-Reply-To: <4502EA5C.5020101@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/9/06, Patrick McHardy <kaber@trash.net> wrote:

> > src 34.34.36.1 dst 34.34.36.6
> >        proto esp spi 0x0dc3aba4(230927268) reqid 0(0x00000000) mode tunnel
> >        replay-window 4 seq 0x991250886 flag  (0x00000000)
> >        auth md5 0xfea9e3e8d324265d8b7e17ec42d69b15 (128 bits)
> >        enc aes 0x21ca0a9677ff0225acd0d3f4a9bdcf61 (128 bits)
> >        lifetime config:
> >          limit: soft (INF)(bytes), hard (INF)(bytes)
> >          limit: soft (INF)(packets), hard (INF)(packets)
> >          expire add: soft 23040(sec), hard 28800(sec)
> >          expire use: soft 0(sec), hard 0(sec)
> >        lifetime current:
> >          0(bytes), 0(packets)
> >          add 2006-09-09 10:21:41 use 2006-09-09 10:21:46
> >        stats:
> >          replay-window 0 replay 0 failed 30
>
>                                            ^^
> This seems to be the problem, the sequence-numbers are outside the valid
> window. I can't find anything that would cause this, please post a
> tcpdump of the packets so we can see which values get used.

On the responder:  tcpdump -n -i eth0 proto 50 or proto 51

13:27:30.416624 IP 34.34.36.1 > 34.34.36.6:
ESP(spi=0x09a205f0,seq=0x1), length 132
13:27:31.415752 IP 34.34.36.1 > 34.34.36.6:
ESP(spi=0x09a205f0,seq=0x2), length 132
13:27:32.415582 IP 34.34.36.1 > 34.34.36.6:
ESP(spi=0x09a205f0,seq=0x3), length 132
13:27:33.415390 IP 34.34.36.1 > 34.34.36.6:
ESP(spi=0x09a205f0,seq=0x4), length 132
13:27:34.415228 IP 34.34.36.1 > 34.34.36.6:
ESP(spi=0x09a205f0,seq=0x5), length 132
13:27:35.415054 IP 34.34.36.1 > 34.34.36.6:
ESP(spi=0x09a205f0,seq=0x6), length 132

and the  ip -s xfrm state  output:

These first two entries (X's and Y's) are from another working tunnel
on the firewall. I had shutdown this tunnel when I posted the previous
results.

src X.X.X.X dst Y.Y.Y.Y
        proto esp spi 0xb435a4c1(3023414465) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x00000023 flag  (0x00000000)
        auth md5 0x862b4e72af7910ceaa014f758294b965 (128 bits)
        enc des3_ede
0x328a552e490122c0eb74c966446cca0ee9df334ffbafc7c4 (192 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 483840(sec), hard 604800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          18619776(bytes), 50494(packets)
          add 2006-09-09 10:45:20 use 2006-09-09 10:45:21
        stats:
          replay-window 0 replay 0 failed 0
src Y.Y.Y.Y dst X.X.X.X
        proto esp spi 0x0bb67022(196505634) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x00000023 flag  (0x00000000)
        auth md5 0xdb7e6457c94cb90e2e5743afbf85517d (128 bits)
        enc des3_ede
0x263be9438dccf9497966e37b1082dec5d4bec2656b34d377 (192 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 483840(sec), hard 604800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          10811535(bytes), 27716(packets)
          add 2006-09-09 10:45:20 use 2006-09-09 10:45:21
        stats:
          replay-window 0 replay 0 failed 166
src 34.34.36.6 dst 34.34.36.1
        proto esp spi 0x079c9d34(127704372) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x3698599912 flag  (0x00000000)
        auth md5 0x6c995f0e7feda87c4ffae49697bdb773 (128 bits)
        enc aes 0x50a3ad275e4441844ed775357ef74bcd (128 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 23040(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 13:27:29 use -
        stats:
          replay-window 0 replay 0 failed 0
src 34.34.36.1 dst 34.34.36.6
        proto esp spi 0x09a205f0(161613296) reqid 0(0x00000000) mode tunnel
        replay-window 4 seq 0x3698599912 flag  (0x00000000)
        auth md5 0x5e607ebf5614c79c7eec3064d25fa2a9 (128 bits)
        enc aes 0x34d12010227216e2b3de254090c4fc40 (128 bits)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 23040(sec), hard 28800(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2006-09-09 13:27:29 use 2006-09-09 13:27:30
        stats:
          replay-window 0 replay 0 failed 399
