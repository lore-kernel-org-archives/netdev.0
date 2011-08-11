From: Andrei Popa <ierdnah@gmail.com>
Subject: 2.6.35.11 bridge drops fragmented packets
Date: Thu, 11 Aug 2011 15:43:04 +0300
Message-ID: <1313066585.14145.18.camel@ierdnac-hp>
Reply-To: ierdnah@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-NS8Ve71j/bvJZ444kPzb"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38340 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556Ab1HKMoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 08:44:37 -0400
Received: by fxh19 with SMTP id 19so1631202fxh.19
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 05:44:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NS8Ve71j/bvJZ444kPzb
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

We've got a problem with kernel 2.6.35.11 as it does not forward
fragmented packets on a bridge.
I've seen this thread
http://lkml.indiana.edu/hypermail/linux/kernel/0604.0/0201.html and I
thought to email you.

The command "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables"
fixes the problem.

The config from the kernel is attached.
The network configuration is as follows:
cisco, interace in mode trunk with allowed vlan 1501,299 -> linux ->
cisco, interface in mode trunk with allowed vlan 1501

The MTU on cisco and on linux interfaces is set to 1500.
Packets with size 1500 and no fragments are forwarded succesfully,
packets with size 1500 and fragments are not forwaded.
On linux it's a bond comprised of eth1.1501 and eth0.1501.
root@shaper_b2b_bucuresti:~# brctl show
bridge name     bridge id               STP enabled     interfaces
br1501          8000.0015170ae7b8       no              eth0.1501
                                                        eth1.1501
I cand see the fragmented packets arriving on eth0 and eth0.1501 but I
don't see them leaving on eth1 or eth1.1501.

Andrei


--=-NS8Ve71j/bvJZ444kPzb
Content-Disposition: attachment; filename="config"
Content-Type: text/x-patch; name="config"; charset="us-ascii"
Content-Transfer-Encoding: 7bit

*** General ***


owner     = itelecom
contact   = support@i-neo.ro
mailhost  = mail.itelecom.ro
sendmail  = /usr/lib/sendmail
imgcache  = /var/lib/smokeping/.simg
imgurl    = ../.simg
datadir   = /var/lib/smokeping
piddir    = /var/lib/smokeping
cgiurl    = http://89.39.188.34/cgi-perl/smokeping.pl
smokemail = /etc/smokemail.dist
# specify this to get syslog logging
syslogfacility = local0
# each probe is now run in its own process
# disable this to revert to the old behaviour
# concurrentprobes = no



#owner    = ineo
#contact  = support@i-neo.ro
#mailhost = mail.itelecom.ro
# NOTE: do not put the Image Cache below cgi-bin
# since all files under cgi-bin will be executed ... this is not
# good for images.
#imgcache = /var/lib/smokeping/.simg
#imgurl   = ../.simg
#datadir  = /var/lib/smokeping
#piddir  = /var/run/smokeping
#cgiurl   = http://89.39.188.34/cgi-perl/smokeping.pl
#smokemail = /etc/smokeping/smokemail
#tmail = /etc/smokeping/tmail
#sendmail = /usr/lib/sendmail
        # specify this to get syslog logging
#syslogfacility = local0
# each probe is now run in its own process
# disable this to revert to the old behaviour
# concurrentprobes = no

*** Alerts ***
to = alert@i-neo.ro
from = smokeping@itelecom.ro

+someloss
type = loss
# in percent
pattern = >0%,*12*,>0%,*12*,>0%
comment = loss 3 times  in a row

+rtt_dns
type = rtt
# in milliseconds
pattern = >1
comment = dns rtt up

+startloss
type = loss
# in percent
pattern = ==S,>0%,>0%,>0%
comment = loss at startup


*** Database ***

step     = 300
pings    = 20

# consfn mrhb steps total

AVERAGE  0.5   1  1008
AVERAGE  0.5  12  4320
    MIN  0.5  12  4320
    MAX  0.5  12  4320
AVERAGE  0.5 144   720
    MAX  0.5 144   720
    MIN  0.5 144   720

*** Presentation ***

template = /etc/smokeping/basepage.html

+ overview

width = 600
height = 50
range = 10h

+ detail

width = 600
height = 200
unison_tolerance = 2

"Last 3 Hours"    3h
"Last 30 Hours"   30h
"Last 10 Days"    10d
"Last 400 Days"   400d

#+ hierarchies
#++ owner
#title = Host Owner
#++ location
#title = Location

*** Probes ***

+ FPing

binary = /usr/sbin/fping

+ DNS

binary = /usr/bin/dig
lookup = yahoo.com
pings = 5
step = 180


*** Slaves ***
secrets= /etc/smokeping/smokeping_secrets
+boomer
display_name=boomer
color=0000ff

+slave2
display_name=another
color=00ff00

*** Targets ***

probe = FPing

menu = Top
title = Network Latency Grapher
remark = Welcome to the SmokePing website of xxx Company. \
         Here you will learn all about the latency of our network.

menuextra = <a target='_blank' href='http://89.39.188.34/smokeping/tr.html{HOST}' class='{CLASS}' \
    onclick="window.open(this.href,this.target, \
    'width=800,height=500,toolbar=no,location=no,status=no,scrollbars=no'); \
    return false;">[Trace]</a>


+ services
menu = Service Latency
title = Service Latency (DNS, HTTP)

++ DNS
probe = DNS
menu = DNS Latency
title = DNS Latency

+++ ns1
host = ns1.itelecom.ro
alerts = rtt_dns,someloss

+ Extern

menu = Extern
title = Extern

++ NTT

menu = NTT
title = NTT(213.198.82.177)
host = 213.198.82.177

++ NTT_test1

menu = NTT_test1
title = NTT_test1(213.198.76.29)
host = 213.198.76.29
alerts = someloss

++ NTT_test2

menu = NTT_test2
title = NTT_test2(62.73.178.85)
host = 62.73.178.85
alerts = someloss

++ LEVEL3_interconect

menu = LEVEL3_interconect
title = LEVEL3(212.162.45.133)
host = 212.162.45.133
alerts = someloss

++ WWWLEVEL3

menu = WWWLEVEL3
title = WWWLEVEL3(4.68.95.11)
host = 4.68.95.11
alerts = someloss

++ GTSCE

menu = GTSCE
title = GTSCE(195.39.208.77)
host = 195.39.208.77
alerts = someloss

++ GBLX

menu = GBLX
title = GBLX(207.218.55.80)
host = 207.218.55.80
alerts = someloss

++ wwwyahoo

menu =wwwYahoo
title = www.yahoo.com
host = 87.248.122.122
alerts = someloss

++ yahoo

menu =Yahoo
title = yahoo.com
host = 67.195.160.76
alerts = someloss

++ www_yahoo

menu =www_Yahoo
title = www.yahoo.com
host = 87.248.122.122
alerts = someloss

++ kernel

menu = ftp.kernel.org
title = ftp.kernel.org
host = 130.239.17.4
alerts = someloss

++ google

menu = www.google.com
title = www.google.com
host = 209.85.135.103
alerts = someloss

++ facebook

menu = www.facebook.com
title = www.facebook.com
host = 69.63.189.11
alerts = someloss

+ Metro

menu = Metro
title = Metro

++ interlan

menu = www.interlan.ro
title = www.interlan.ro
host = 86.104.125.235
alerts = someloss

++ k

menu = www.k.ro
title = www.k.ro
host = 194.102.255.23
alerts = someloss

++ astral

menu = astral.ro
title = astral.ro
host = 193.230.240.28
alerts = someloss

++ lgastralnet

menu = lg.astralnet.ro
title = lg.astralnet.ro
host = 194.102.255.35
alerts = someloss

++ ilink

menu = www.ilink.ro
title = www.ilink.ro
host = 86.55.0.10
alerts = someloss

++ rdsnet

menu = www.rdsnet.ro
title = www.rdsnet.ro
host = 81.196.12.33
alerts = someloss

++ rds1_bucuresti

menu = www.home.ro
title = www.home.ro
host = 81.196.20.130
alerts = someloss

++ rds2_oradea

menu = www.rdsor.ro
title = www.rdsor.ro
host = 193.231.238.4

++ rds3_constanta

menu = CaffeDelMar.ro
title = CaffeDelMar.ro
host = 86.122.57.68

++ romtelecom

menu = www.romtelecom.ro
title = www.romtelecom.ro
host = 86.35.15.233

++ mediasat

menu = www.mediasat.ro
title = www.mediasat.ro
host = 81.180.226.176

++ ines

menu = www.ines.ro
title = www.ines.ro
host = 80.86.96.15

++ newcom

menu = www.newcom.ro
title = www.newcom.ro
host = 89.165.199.15
alerts = someloss

+ Clienti

menu = Clienti
title = Clienti

++ PCPLANET_client

menu = PCPLANET_client
title = PCPLANET_client
host = 93.115.98.30



--=-NS8Ve71j/bvJZ444kPzb--

