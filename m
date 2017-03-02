From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 194723] connect() to localhost stalls after 4.9 -> 4.10
 upgrade
Date: Thu, 2 Mar 2017 10:32:49 -0800
Message-ID: <20170302103249.671ef5a5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34477 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdCBSdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 13:33:52 -0500
Received: by mail-pg0-f47.google.com with SMTP id 16so553718pga.1
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 10:32:51 -0800 (PST)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id p77sm14392903pfj.99.2017.03.02.10.32.50
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Mar 2017 10:32:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 01 Mar 2017 12:04:45 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 194723] connect() to localhost stalls after 4.9 -> 4.10 upgrade


https://bugzilla.kernel.org/show_bug.cgi?id=194723

--- Comment #2 from Lutz Vieweg (lvml@5t9.de) ---
Using tcpdump I found that when the connect() stalls, the initial SYN packet
appears at the "lo" interface, and is re-sent multiple times, but no ACK packet
is ever returned.

Error case with linux-4.10:

> 12:57:25.685640 IP 127.0.0.1.44074 > 127.0.0.1.dnp-sec: Flags [S], seq
> 1952288470, win 43690, options [mss 65495,sackOK,TS val 1942998659 ecr
> 0,nop,wscale 7], length 0
> 12:57:26.728890 IP 127.0.0.1.44074 > 127.0.0.1.dnp-sec: Flags [S], seq
> 1952288470, win 43690, options [mss 65495,sackOK,TS val 1942999703 ecr
> 0,nop,wscale 7], length 0
> 12:57:28.776935 IP 127.0.0.1.44074 > 127.0.0.1.dnp-sec: Flags [S], seq
> 1952288470, win 43690, options [mss 65495,sackOK,TS val 1943001751 ecr
> 0,nop,wscale 7], length 0  
...

Normal case:

> 13:01:43.037135 IP 127.0.0.1.44362 > 127.0.0.1.dnp-sec: Flags [S], seq
> 3181010757, win 43690, options [mss 65495,sackOK,TS val 3314900273 ecr
> 0,nop,wscale 7], length 0
> 13:01:43.037171 IP 127.0.0.1.dnp-sec > 127.0.0.1.44362: Flags [S.], seq
> 1934682061, ack 3181010758, win 43690, options [mss 65495,sackOK,TS val
> 2947413993 ecr 3314900273,nop,wscale 7], length 0
> 13:01:43.037196 IP 127.0.0.1.44362 > 127.0.0.1.dnp-sec: Flags [.], ack 1, win
> 342, options [nop,nop,TS val 3314900273 ecr 2947413993], length 0  


According to strace, the listening process does not even leave the select()
call it uses to wait for incoming connections to accept in the error case.

-- 
You are receiving this mail because:
You are the assignee for the bug.
