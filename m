From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 43901] New: Packet Dropping when attach TBF to PRIO qdisc
Date: Wed, 27 Jun 2012 08:27:43 -0700
Message-ID: <20120627082743.140de031@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55700 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108Ab2F0P1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 11:27:54 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 499D714102B1
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 08:27:53 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id X27RUGEcMF7t for <netdev@vger.kernel.org>;
	Wed, 27 Jun 2012 08:27:52 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 08B69141014A
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 08:27:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 27 Jun 2012 12:14:28 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 43901] New: Packet Dropping when attach TBF to PRIO qdisc


https://bugzilla.kernel.org/show_bug.cgi?id=43901

           Summary: Packet Dropping when attach TBF to PRIO qdisc
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4.4
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: lucas.bocchi@gmail.com
        Regression: No


Created an attachment (id=74371)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=74371)
Kernel config file

Friends

When I do a upgrade in one server kernel with 2.6.32.5 kernel to actual 3.4.4
kernel, my TBF qdisc attached to a PRIO qdisc stops to work.

The first classes won't have any heavy traffic to justify the starvation of
another classes, but packets are dropped with 

See some information about the bug
Gnu C                  4.7
Gnu make               3.81
binutils               2.22
util-linux             2.20.1
mount                  support
module-init-tools      8
e2fsprogs              1.42.4
PPP                    2.4.5
Linux C Library        2.13
Dynamic linker (ldd)   2.13
Procps                 3.3.2
Net-tools              1.60
Kbd                    1.15.3
Sh-utils               8.13
Modules Loaded         sch_tbf xt_mark xt_mac xt_state xt_connmark cls_fw
cls_u32 sch_prio sha1_ssse3 sha1_generic arc4 ecb ppp_mppe ppp_async crc_ccitt
ppp_generic slhc xt_tcpudp ipt_MASQUERADE iptable_mangle iptable_nat nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_filter ip_tables x_tables
nfsd exportfs nfs nfs_acl auth_rpcgss lockd sunrpc ipv6 loop snd_hda_codec_via
iTCO_wdt snd_hda_intel snd_hda_codec acpi_cpufreq mperf freq_table coretemp
intel_agp intel_gtt rng_core snd_pcm evdev rtc_cmos i2c_i801 snd_page_alloc
i2c_core pcspkr snd_timer processor snd microcode soundcore button ext3 mbcache
jbd sr_mod cdrom ata_generic sd_mod pata_acpi usb_storage uas ata_piix thermal
thermal_sys uhci_hcd libata scsi_mod r8169 mii piix ide_pci_generic ide_core
ehci_hcd


The TC commands
tc qdisc del dev eth0 root
tc qdisc add dev eth0 root handle 01:0 prio bands 5 priomap 4 4 4 4 4 4 4 4 4 4
4 4 4 4 4 4
tc qdisc add dev eth0 parent 01:01 handle 11:0 pfifo limit 100
tc qdisc add dev eth0 parent 01:02 handle 12:0 pfifo limit 100
tc qdisc add dev eth0 parent 01:03 handle 13:0 pfifo limit 100
tc qdisc add dev eth0 parent 01:04 handle 14:0 tbf rate 3Mbit latency 2s burst
10k
tc qdisc add dev eth0 parent 01:05 handle 15:0 tbf rate 3Mbit latency 2s burst
10k


tc filter add dev eth0 parent 01:00 prio 1 u32 match u8 64 0xff at 8 flowid 1:1
tc filter add dev eth0 parent 01:00 prio 1 u32 match ip protocol 6 0xff match
u8 0x10 0xff at nexthdr+13 flowid 1:1
tc filter add dev eth0 parent 01:00 prio 1 u32 match ip protocol 6 0xff match
u8 0x05 0x0f at 0 match u16 0x0000 0xffc0 at 2 match u8 0x10 0xff at 33 flowid
1:1
tc filter add dev eth0 parent 01:00 prio 2 protocol ip u32 match ip protocol 1
0xff flowid 1:1
tc filter add dev eth0 parent 01:00 prio 3 protocol ip u32 match ip dst
172.16.0.250 flowid 1:2
tc filter add dev eth0 parent 01:00 prio 3 protocol ip u32 match ip dst
172.16.0.58 flowid 1:2
tc filter add dev eth0 parent 01:00 prio 4 protocol ip u32 match ip sport 8291
0xffff flowid 1:3
tc filter add dev eth0 parent 01:00 prio 5 protocol ip handle 1 fw flowid 1:4

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
