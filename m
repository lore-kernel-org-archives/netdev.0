From: Yuri Gribov <tetra2005@gmail.com>
Subject: [Bug-report][iproute2] Buffer overflow in inverttable
Date: Fri, 24 Mar 2017 08:35:46 +0000
Message-ID: <CAJOtW+6+WmruYfCFPuWp_H+HPaLpzrVYFt7-AS_OT6e52J1TnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:34762 "EHLO
        mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932790AbdCXIft (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 04:35:49 -0400
Received: by mail-yw0-f182.google.com with SMTP id p77so4738087ywg.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 01:35:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following code in inverttable in netem/maketable.c
    inverse = (short *)malloc(inversesize*sizeof(short));
    ...
    for (i=0; i < tablesize; ++i) {
        findex = ((double)i/(double)DISTTABLEGRANULARITY) - DISTTABLEDOMAIN;
        fvalue = (double)table[i]/(double)cumulative;
        inverseindex = (int)rint(fvalue*inversesize);
        ...
        inverse[inverseindex] = inversevalue;
writes value past the end of malloc buffer because fvalue evaluates to
1 for the last value of table.

AddressSanitizer report is
  ==18736==ERROR: AddressSanitizer: heap-buffer-overflow on address
0x62500000e900 at pc 0x000000401b09 bp 0x7ffe03fb04d0 sp
0x7ffe03fb04c0
  WRITE of size 2 at 0x62500000e900 thread T0
    #0 0x401b08 in inverttable (/build/iproute2-4.3.0/netem/maketable+0x401b08)
    #1 0x40216f in main (/build/iproute2-4.3.0/netem/maketable+0x40216f)
    #2 0x7ff1d736082f in __libc_start_main
(/lib/x86_64-linux-gnu/libc.so.6+0x2082f)
    #3 0x400fc8 in _start (/build/iproute2-4.3.0/netem/maketable+0x400fc8)
 0x62500000e900 is located 0 bytes to the right of 8192-byte region
[0x62500000c900,0x62500000e900)

  allocated by thread T0 here:
    #0 0x7ff1d7cf5f20 in __interceptor_malloc
(/usr/lib/x86_64-linux-gnu/libasan.so.3+0xc6f20)
    #1 0x401966 in inverttable (/build/iproute2-4.3.0/netem/maketable+0x401966)
    #2 0x40216f in main (/build/iproute2-4.3.0/netem/maketable+0x40216f)
    #3 0x7ff1d736082f in __libc_start_main
(/lib/x86_64-linux-gnu/libc.so.6+0x2082f)

Bug was found with AddressSanitizer and debian_pkg_test
(https://github.com/yugr/debian_pkg_test).

-Yury
