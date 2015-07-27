From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 102051] New: Unexpected TCP behavior
Date: Mon, 27 Jul 2015 14:02:18 -0700
Message-ID: <20150727140218.095729a9@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35565 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbbG0VCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:02:08 -0400
Received: by pdrg1 with SMTP id g1so57888165pdr.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:02:08 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id si3sm31292802pac.5.2015.07.27.14.02.07
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 14:02:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 27 Jul 2015 20:06:07 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 102051] New: Unexpected TCP behavior


https://bugzilla.kernel.org/show_bug.cgi?id=102051

            Bug ID: 102051
           Summary: Unexpected TCP behavior
           Product: Networking
           Version: 2.5
    Kernel Version: 3.19
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: low
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: vremetic@gmail.com
        Regression: No

While running nmap against localhost I started to see open ports in the dynamic
range (>1024). Kind of odd, knowing netstat and ss did not show any listeners
on the port.

With tcpdump, I confirmed system was returning S/ACK for ports that did not
have a listener enabled. The "issue" or feature only occurs if source port
matches the destination port.

# netstat -nap | grep 5000
#

$ nc localhost -p 5000 5000
a
a

# tcpdump -i lo port 5000
14:28:18.059708 IP 127.0.0.1.5000 > 127.0.0.1.5000: Flags [S], seq 2005295207,
win 43690, options [mss 65495,sackOK,TS val 4481790 ecr 0,nop,wscale 7], length
0
14:28:18.059721 IP 127.0.0.1.5000 > 127.0.0.1.5000: Flags [S.], seq 2005295207,
ack 2005295208, win 43690, options [mss 65495,sackOK,TS val 4481790 ecr
4481790,nop,wscale 7], length 0
14:28:18.059729 IP 127.0.0.1.5000 > 127.0.0.1.5000: Flags [.], ack 2005295208,
win 342, options [nop,nop,TS val 4481790 ecr 4481790], length 0
14:28:19.121392 IP 127.0.0.1.5000 > 127.0.0.1.5000: Flags [P.], seq
2005295208:2005295210, ack 2005295208, win 342, options [nop,nop,TS val 4482056
ecr 4481790], length 2
14:28:19.121407 IP 127.0.0.1.5000 > 127.0.0.1.5000: Flags [.], ack 2005295210,
win 342, options [nop,nop,TS val 4482056 ecr 4482056], length 0

# hping3 -S 127.0.0.1 -p 5000 -s 5000
HPING 127.0.0.1 (lo 127.0.0.1): S set, 40 headers + 0 data bytes 
len=40 ip=127.0.0.1 ttl=64 id=2036 sport=5000 flags=S seq=0 win=512 rtt=3.8 ms 
           << SYN
DUP! len=52 ip=127.0.0.1 ttl=64 DF id=670 sport=5000 flags=A seq=0 win=342
rtt=3.8 ms      << SYN/ACK
len=40 ip=127.0.0.1 ttl=64 DF id=43435 sport=5000 flags=RA seq=1 win=0 rtt=3.7
ms

I confirmed it with nmap, nc, and hping3; granted they build on same c
libraries, so I am not even sure if this should be filed as a kernel bug (or
even a bug);
just did not expect to see this behavior // 

Expected to see a RST instead.

-- 
You are receiving this mail because:
You are the assignee for the bug.
