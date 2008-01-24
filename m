From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9808] New: system hung with htb QoS
Date: Thu, 24 Jan 2008 06:11:57 -0800
Message-ID: <20080124061157.3512a308.akpm@linux-foundation.org>
References: <bug-9808-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bilias@edu.physics.uoc.gr, bugme-daemon@bugzilla.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53588 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751608AbYAXOMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 09:12:33 -0500
In-Reply-To: <bug-9808-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 24 Jan 2008 03:03:11 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=9808
> 
>            Summary: system hung with htb QoS
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23.9
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: bilias@edu.physics.uoc.gr
> 
> 
> Hi,
> 
> I've setup QoS on my ftp server to limit outgoing traffic. Apparently the
> server
> stops responding (no output no keyboard) in an unpredictable manner. Sometimes
> it 
> takes an hour, sometimes up to 4 days for the system to hung.
> 
> I have attached my QoS startup script, dmesg output,
> lspci -vvv, iptables that interact with QoS.
> 
> I'm also receiving this quite often:
> Jan 15 12:23:17 ftp kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit
> Hang
> Jan 15 12:23:17 ftp kernel:   Tx Queue             <0>
> Jan 15 12:23:17 ftp kernel:   TDH                  <2a>
> Jan 15 12:23:17 ftp kernel:   TDT                  <17>
> Jan 15 12:23:17 ftp kernel:   next_to_use          <17>
> Jan 15 12:23:17 ftp kernel:   next_to_clean        <2a>
> Jan 15 12:23:17 ftp kernel: buffer_info[next_to_clean]
> Jan 15 12:23:17 ftp kernel:   time_stamp           <5798144>
> Jan 15 12:23:17 ftp kernel:   next_to_watch        <2d>
> Jan 15 12:23:17 ftp kernel:   jiffies              <57988ef>
> Jan 15 12:23:17 ftp kernel:   next_to_watch.status <0>
> Jan 15 12:23:19 ftp kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit
> Hang
> 
> Today for the first time (after applying options to e1000 driver in
> modprobe.conf) I got a kernel panic:
> 
> BUG: unable to handle kernel paging request at virtual address a0379120
> EIP: 0060: [<c05db2dc>] Not Tainted VLI
> EIP is at ip_rcv+0x286/0x4ba
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> This is what I wrote on paper cause there wasn't logged anywhere.
> Usually it hungs without a kernel panic.
> 
> System in Fedoca Core 8 up2date
> 2.6.23.9-85.fc8PAE
> 2x Intel(R) Xeon(TM) CPU 3.20GHz
> 4G RAM
> 
> Without the QoS loaded system never hungs. It must be related to this. However
> the e1000 error I'm receiving must have to do with the e1000 driver. I've seen
> this bug in the past that's why I tried to apply the options in modprobe.conf
> 
> any help will be appreciated
> thanx in advance 
> 
> Giannis
> 
> QoS startup script:
> # default WAN limit
> LIMIT="80mbit"
> LOW_LIMIT="50mbit"
> 
> start() {
>         echo -n "Starting QoS: (WAN limit set to ${LIMIT})"
> tc qdisc del dev eth0 root    2> /dev/null > /dev/null
> tc qdisc del dev eth0 ingress 2> /dev/null > /dev/null
> ADD_CLASS="tc class add dev eth0 "
> ###### uplink
> # install root HTB, point default traffic to 1:25
> tc qdisc add dev eth0 root handle 1: htb  default 25
> 
> tc class add dev eth0 parent 1: classid 1:1 htb rate 1000mbit
> # class for outgoing SYN packets + Minimize-Delay TOS
> ${ADD_CLASS} parent 1:1 classid 1:11 htb rate 2mbit ceil 5mbit prio 1
> # class for internal LAN traffic
> ${ADD_CLASS} parent 1:1 classid 1:12 htb rate 500mbit ceil 800mbit prio 2
> # class for WAN traffic
> ${ADD_CLASS} parent 1:1 classid 1:2 htb rate ${LIMIT} ceil ${LIMIT} prio 3
> # class for WAN http traffic
> ${ADD_CLASS} parent 1:2 classid 1:24 htb rate 30mbit ceil ${LIMIT} prio 4
> # default class, rest WAN traffic
> ${ADD_CLASS} parent 1:2 classid 1:25 htb rate 20mbit ceil ${LIMIT} prio 5
> 
> tc filter add dev eth0 protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:11
> tc filter add dev eth0 protocol ip parent 1:0 prio 2 handle 2 fw flowid 1:12
> tc filter add dev eth0 protocol ip parent 1:0 prio 4 u32 \
>         match ip sport 80 0xffff flowid 1:24
> 
> tc qdisc add dev eth0 parent 1:11 handle 11: sfq perturb 10
> tc qdisc add dev eth0 parent 1:12 handle 12: sfq perturb 10
> tc qdisc add dev eth0 parent 1:24 handle 24: sfq perturb 10
> tc qdisc add dev eth0 parent 1:25 handle 25: sfq perturb 10
> 
>         echo
> }
> 
> stop() {
>         echo -n "Stopping QoS: "
>         tc qdisc del dev eth0 root    2> /dev/null > /dev/null
>         tc qdisc del dev eth0 ingress 2> /dev/null > /dev/null
>         echo
> }
> 
> -------------------
> QoS startup script: http://www.edu.physics.uoc.gr/~bilias/ftp/QoS
> dmesg: http://www.edu.physics.uoc.gr/~bilias/ftp/dmesg
> lspci -vvv: http://www.edu.physics.uoc.gr/~bilias/ftp/lspci
> iptables for QoS: http://www.edu.physics.uoc.gr/~bilias/ftp/iptables
> 
> modprobe.conf options for e1000: 
> options e1000 XsumRX=0 Speed=1000 Duplex=2 InterruptThrottleRate=0
> FlowControl=3 RxDescriptors=4096 TxDescriptors=4096 RxIntDelay=0 TxIntDelay=0
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
