From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 89201] New: sendto changes buffer used by recvfrom of
 other proccesses
Date: Wed, 3 Dec 2014 08:32:41 -0800
Message-ID: <20141203083241.7e2f77bf@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34757 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbaLCQc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 11:32:59 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so15828882pab.26
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 08:32:59 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id hc10sm23434823pbd.78.2014.12.03.08.32.57
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Dec 2014 08:32:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 3 Dec 2014 05:51:34 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 89201] New: sendto changes buffer used by recvfrom of other proccesses


https://bugzilla.kernel.org/show_bug.cgi?id=89201

            Bug ID: 89201
           Summary: sendto changes buffer used by recvfrom of other
                    proccesses
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4.0-perf-ga6edd5e
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: tuxmind.bug@gmail.com
        Regression: No

hi,
i found a bug with recvfrom/sendto.

the affected kernel is the android one, sources can be found there:
https://android.googlesource.com/kernel/msm/+/android-msm-mako-3.4-kitkat-mr2

configuration:
https://android.googlesource.com/kernel/msm/+/android-msm-mako-3.4-kitkat-mr2/arch/arm/configs/mako_defconfig

description:
when a process call recvfrom on a PF_PACKET/SOCK_RAW socket when another
process
call sendto/write on a socket that use the same interface, the ethernet address
is weird.

recvfrom returns the following ethernet header:

UU:XX:00:00:00:00:AA:AA:03:00:00:00:YY:ZZ

instead of

UU:XX:VV:VV:VV:VV:HH:HH:HH:HH:HH:HH:YY:ZZ

where:

  HH:HH:HH:HH:HH:HH is the source MAC address
  UU:XX:VV:VV:VV:VV is the destination MAC address
  YY:ZZ is the ethernet type

i think that recvfrom save the user buffer pointer somewhere because
perform some 'long' work on the buffer ( like using a printf to debug this
problem ) increase the error rate from 2/9480 bad headers to about 779/4301.

i already opened various bug reports and questions.

external references:
 
http://stackoverflow.com/questions/27251904/recvfrom-read-wrong-ethernet-address-from-raw-socket
  https://code.google.com/p/android/issues/detail?id=81370

step to reproduce:

sample program: http://pastebin.com/kkjUrft9
( you have to change the hardcoded ip address )

  > gcc -g -o -DSENDER main.c -o sender
  > gcc -g -o main.c -o receiver
  > ./receiver wlan0 &
  > ./sender wlan0
  > Ctrl+C ( SIGINT ) after a while
  > fg
  > Ctrl+C ( SIGINT )

you should see the amount of sniffed packets and the amount of bad ones.

commenting out the fprintf/fflush calls drastically reduce bad packets count.

thanks in advance for any help.

-- 
You are receiving this mail because:
You are the assignee for the bug.
