From: Rick Jones <rick.jones2@hp.com>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 15:20:51 -0700
Message-ID: <4824CE43.8060203@hp.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>	<20080507.141521.193714938.davem@davemloft.net>	<482498D5.9060008@krogh.cc>	<20080509.143229.174354251.davem@davemloft.net> <4824C936.9000103@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:22013 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbYEIWU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:20:56 -0400
In-Reply-To: <4824C936.9000103@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> David Miller wrote:
> 
>> From: Jesper Krogh <jesper@krogh.cc>
>> Date: Fri, 09 May 2008 20:32:53 +0200
>>
>>> When it works I doesnt seem to be able to get it pass 500MB/s.
>>
>>
>> With this card you really need multiple cpus and multiple threads
>> sending data through the card in order to fill the 10Gb pipe.
>>
>> Single connections will not fill the pipe.
> 
> 
> The server is a Sun X4600 with 8 x dual-core CPU's, setup with 64
> NFS-threads. The other end of the fiber goes into a switch with gigabit
> ports connected to 48 dual-core cpus. The test was done doing a dd on a
> 4.5GB file from the server to /dev/null on the clients.
> 
> The number of contextswitches seems enourmous.. over 120.000 sometimes.
> When transmitting around the same amount of data (4xgigabit bonded with
> 802.3ad) 4x110MB/s the amount of contextswitches only reaches 3-4.000. I
> have no idea if this has any relevance.
> 
> Should this setup not be able to fill the pipe?

Into which slot was the Neptune inserted?  (sure will be nice to have 
Alex Chiang's pci slot id patch in mainline one of these days :)

Is that slot x4, x8, x16?

To which cpu(s) were the neptune's interrupts assigned? (grep <ethN> 
/proc/interrupts)

Is the irqbalanced running?

Were any of the 16 CPUs in the system saturated during the test? (top 
with all CPUs displayed)

Do you have/know of any diagrams showing the way the I/O slots are wired 
to the rest of the system?

Have you tried any tests without any filesystem involvement? A script 
like this (might need post-mailer fixup) might be interesting to run:

s2:~ # cat runemomniagg.sh
length=30
confidence="-i 30,30"
# comment the following to get proper aggregates
# rather than quick-and dirty
confidence=""
#edit these to match your clients
control_host[1]=192.168.2.205
control_host[2]=192.168.2.206
control_host[3]=192.168.2.207
control_host[4]=192.168.2.208
control_host[5]=192.168.2.209
control_host[6]=192.168.2.210
control_host[7]=192.168.2.211
control_host[8]=192.168.2.212
control_host[9]=192.168.2.201
control_host[10]=192.168.2.203
control_host[11]=192.168.2.204
control_host[12]=192.168.2.202
concurrent_sessions="1 2 3 4 5 6 7 8 9 10 11 12"
HDR="-P 1"
# -O means "human" -o means "csv"
CSV="-o"
#CSV="-O"

echo text you supply about interrupts
echo text you supply about the systems
uname -a
   echo TCP_STREAM to multiple systems
   for i in $concurrent_sessions; do j=1; echo $i concurrent streams; 
while [ $j -le $i ]; do netperf $HDR -t omni -c -C -H 
${control_host[$j]} -l $length $confidence -- $CSV -m 64K & HDR="-P 
0";j=`expr $j + 1`; done; wait; done

   echo TCP_MAERTS to multiple systems
   HDR="-P 1"
   for i in $concurrent_sessions; do j=1; echo $i concurrent streams; 
while [ $j -le $i ]; do netperf $HDR -t omni -c -C -H 
${control_host[$j]} -l $length $confidence -- $CSV -M ,64K & HDR="-P 
0";j=`expr $j + 1`; done; wait; done

   echo bidir TCP_RR MEGABITS to multiple systems
   HDR="-P 1"
   for i in $concurrent_sessions; do j=1; echo $i concurrent streams; 
while [ $j -le $i ]; do netperf $HDR  -t omni -f m -c -C -H 
${control_host[$j]} -l $length $confidence -- $CSV -s 1M -S 1M -r 64K -b 
12 & HDR="-P 0";j=`expr $j + 1`; done; wait; done

for burst in 0 1 4 16
  do
   echo TCP_RR to multiple systems burst of $burst
   HDR="-P 1"
   for i in $concurrent_sessions; do j=1; echo $i concurrent streams; 
while [ $j -le $i ]; do netperf $HDR -t omni -c -C -H 
${control_host[$j]} -l $length $confidence -- $CSV -r 1 -b $burst -D & 
HDR="-P 0";j=`expr $j + 1`; done; wait; done
  done

cat /proc/meminfo
cat /proc/cpuinfo


Which will run netperf "omni" tests and emit a _LOT_ of information. 
The concurrent tests run "properly" will be ~15 minutes a data point. 
The output is probably best viewed in a spreadsheet program.  It is 
possible to limit what netperf will emit by placing the names of the 
output items of interest into a file you pass in the test specific -o or 
-O options. The netperf omni tests are in the top of trunk at:

http://www.netperf.org/svn/netperf2/trunk/

via subversion.  The script presume your ./configure was a superset of:

./configure --enable-omni --enable-burst

You would want it installed on both your SUT and at least a subset of 
your LG's.

rick jones
