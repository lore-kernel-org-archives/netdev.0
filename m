From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fw: [Bug 18822] New: TCP Communications gets blocked, then
 resetted
Date: Tue, 21 Sep 2010 12:54:02 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009211216160.26447@wel-95.cs.helsinki.fi>
References: <20100920090451.4ef28f91@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57575 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab0IUJyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 05:54:05 -0400
In-Reply-To: <20100920090451.4ef28f91@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Sep 2010, Stephen Hemminger wrote:

> Begin forwarded message:
> 
> Date: Mon, 20 Sep 2010 10:39:47 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 18822] New: TCP Communications gets blocked, then resetted
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=18822
> 
>            Summary: TCP Communications gets blocked, then resetted
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32-24-generic #43-Ubuntu
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: dc6iq@gmx.de
>         Regression: No
> 
> 
> Created an attachment (id=30682)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=30682)
> both machine dumps
> 
> having a freshly installed bacula server i could never get a backup from my
> working machine done to the bacula server.
> 
> The Connection transmits approximately 3 GiB, then locks up and resets the
> connection.
> 
> Transmission gets stuck at a certain point, then the bacula server does not
> reply to retransmitted packets on IPV4 stack. Retry Count on disks machine (my
> working machine) raises up to 13, then the Connection is gone. bacula server
> tries to send a Push packet (after KeepAlive timer runs out), and get the final
> RST packet from disks, because the connection is gone.
> 
> In the Attachment you will find the tcpdumps from both machines, actually the
> sending machine dropped some packets in the dump.

If you didn't already, try with -w directly into a binary file and then 
post process to textual input with -r.

> It might be a possible help: disks is running an 64 bit kernel whereas bacula
> is running 32 bit. I haven't looked into the option bits very well but it looks
> like there is a problem hidden:
> 
> last ack being ok:
> 09:32:56.142876 IP bacula.elkenet.bacula-sd > disks.elkenet.50766: Flags [.],
> ack 2005754588, win 9582, options [nop,nop,TS val 21825875 ecr 4530083], length
> 0
> next ack packet:
> 09:32:56.144763 IP bacula.elkenet.bacula-sd > disks.elkenet.50766: Flags [.],
> ack 2005773412, win 9308, options [nop,nop,TS val 21825876 ecr
> 4530083,nop,nop,sack 1 {2005774860:2005776308}], length 0

...I fail to understand to what problem you're trying to point here with 
these two ACKs. Could you elaborate please (if you had something specific 
in mind)?

I went throught the logs... I cannot go through all the checking done 
because tcpdump without enough -v's hides the sequence numbers for pure 
ACKs (09:32:56.150182 shows only the ack seqno, not the other seqno which 
also is used by the validator), I think you need at least -vvv to show 
them nowadays. The last new data segment at 09:32:56.150132 was still 
received as it is reported in SACK, only the retransmissions that 
follow are discarded.

> root@disks:~# uname -a
> Linux disks 2.6.32-24-generic #43-Ubuntu SMP Thu Sep 16 14:58:24 UTC 2010
> x86_64 GNU/Linux
> 
> root@bacula:~# uname -a
> Linux bacula 2.6.32-24-generic-pae #43-Ubuntu SMP Thu Sep 16 15:30:27 UTC 2010
> i686 GNU/Linux
> 
> Doing a 20GB backup on a debian server works fine
> 
> server:~# uname -a
> Linux server 2.6.32-5-486 #1 Sat Sep 18 01:43:00 UTC 2010 i686 GNU/Linux
> 
> Doing a 26 GB backup from a 32 bit Ubuntu works fine as well. Maybe its a 64
> bit issue...
> 
> root@elke:~# uname -a
> Linux elke 2.6.32-24-generic #43-Ubuntu SMP Thu Sep 16 14:17:33 UTC 2010 i686
> GNU/Linux

Hmm, some ubuntu magic in these kernels.

> If any further input is required, just let me know...

MIBs might immediately tell what caused the segments between 
09:32:56.150310 and 09:46:30.970140 to be discarded (e.g., take before 
and after snapshots of /proc/net/netstat and /proc/net/snmp and see what 
did increase).

Any TSO enabled?

-- 
 i.
