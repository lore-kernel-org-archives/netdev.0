From: Dave Hansen <haveblue@us.ibm.com>
Subject: TCP stalling problems dissipated in 2.5.63
Date: Thu, 27 Feb 2003 01:02:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E5DD427.2070801@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been complaining about these problems for a bit, so I thought I'd
share some good news.

http://marc.theaimsgroup.com/?l=linux-netdev&m=104169568212878&w=2
http://marc.theaimsgroup.com/?t=104343403700001&r=1&w=2

I decided to spend some time tracking down the TCP stalls that I was
still seeing with the e1000 on 2.5.59 (probably not the e1000's fault,
just the only cards I see it on).  I pulled out my trusty old test that
I've been using for a few weeks to replicate the problem.  Anyway, I
can't get it to occur any more.  The real test will be to see if Specweb
still triggers it, but my Specweb machine is a smoldering pile of slag
right now.

I have a 4-way PIII-Xeon and an 8-way PIII-Xeon plugged into the same
copper gigabit switch.  The 4-way runs 4 copies of http-bench.sh, which
I've included below.  It basically asks the server for a list of files
(from a cgi script), then fetches them sequentially.   The _sustained_
data rate is 750 Mb/sec with peaks of ~790 Mb/sec.  The server runs
Apache 2.0.43.

During this time, the client is about 80% CPU saturated (shell scripts,
what do you expect?), but the server is a much different story.  vmstat
shows ~1% user time, and only 5-6% kernel.  The rest is idle!  I have
readprofile from a short slice, because oprofile doesn't work on these
machines.

   126 tcp_write_xmit                             0.1703
   128 kfree                                      1.2800
   131 __kfree_skb                                0.6550
   132 ip_rcv                                     0.1303
   142 qdisc_restart                              0.3550
   150 tcp_transmit_skb                           0.1053
   156 schedule                                   0.1566
   161 e1000_clean_rx_irq                         0.1720
   169 kmalloc                                    1.2426
   189 skb_clone                                  0.4500
   215 alloc_skb                                  0.4594
   233 do_generic_mapping_read                    0.2709
   240 tcp_v4_rcv                                 0.1268
   294 e1000_intr                                 3.1957
   311 e1000_clean_tx_irq                         0.7266
   353 e1000_xmit_frame                           0.2229
   370 do_tcp_sendpages                           0.1370
   408 skb_release_data                           2.6154
127279 poll_idle                                1515.2262
134275 total                                      0.0829

httpd-bench.sh:
#!/bin/sh
SERVER=10.1.1.96
rm -f file_list 2> /dev/null
wget -O file_list http://$SERVER/ls.pl
cat file_list | \
awk '{print "http://'$SERVER'/" $0}' | \
xargs --max-procs=1 --max-args=20 wget -O /dev/null --progress=dot 2>&1
| grep \'" saved " \
| awk -f speedavg.awk

ls.pl from the server (yeah, yeah, I know it's not perl, but I didn't
feel like adding another handler)
#!/bin/sh
echo 'Content-type: text/html'
echo
find file_set -type f -size +100k

-- 
Dave Hansen
haveblue@us.ibm.com
