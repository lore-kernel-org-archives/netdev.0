From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 17:02:28 +0800
Message-ID: <1232701348.11429.170.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>
	 <200901231933.10101.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-iJ7pR5ZGKvuT2d2vXHGE"
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200901231933.10101.nickpiggin@yahoo.com.au>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iJ7pR5ZGKvuT2d2vXHGE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2009-01-23 at 19:33 +1100, Nick Piggin wrote:
> On Friday 23 January 2009 14:02:53 Zhang, Yanmin wrote:
> 
> > 1) If I start CPU_NUM clients and servers, SLUB's result is about 2% better
> > than SLQB's;
> 
> I'll have to look into this too. Could be evidence of the possible
> TLB improvement from using bigger pages and/or page-specific freelist,
> I suppose.
> 
> Do you have a scripted used to start netperf in that configuration?
See the attachment.

Steps to run testing:
1) compile netperf;
2) Change PROG_DIR to path/to/netperf/src;
3) ./start_netperf_udp_v4.sh 8 #Assume your machine has 8 logical cpus.


--=-iJ7pR5ZGKvuT2d2vXHGE
Content-Disposition: attachment; filename=start_netperf_udp_v4.sh
Content-Type: application/x-shellscript; name=start_netperf_udp_v4.sh
Content-Transfer-Encoding: 7bit

#!/bin/sh

PROG_DIR=/home/ymzhang/test/netperf/src
date=`date +%H%M%N`
#PROG_DIR=/root/netperf/netperf/src
client_num=$1
pin_cpu=$2

start_port_server=12384
start_port_client=15888

killall netserver
${PROG_DIR}/netserver
sleep 2

if [ ! -d result ]; then
	mkdir result
fi

all_result_files=""
for i in `seq 1 ${client_num}`; do
	if [ "${pin_cpu}" == "pin" ]; then
		pin_param="-T ${i} ${i}"
	fi
	result_file=result/netperf_${start_port_client}.${date}
	#./netperf -t UDP_STREAM -l 60 -H 127.0.0.1 -- -P 15895 12391 -s 32768 -S 32768 -m 4096
	#./netperf -t UDP_STREAM -l 60 -H 127.0.0.1 -i 50 3 -I 99 5 -- -P 12384 12888 -s 32768 -S 32768 -m 4096
	#${PROG_DIR}/netperf -p ${port_num} -t TCP_RR -l 60 -H 127.0.0.1 ${pin_param} -- -r 1,1 >${result_file} &
	${PROG_DIR}/netperf -t UDP_STREAM -l 60 -H 127.0.0.1 ${pin_param} -- -P ${start_port_client} ${start_port_server} -s 32768 -S 32768 -m 4096 >${result_file}  &
	sub_pid="${sub_pid} `echo $!`"
	port_num=$((${port_num}+1))
	all_result_files="${all_result_files} ${result_file}"
	start_port_server=$((${start_port_server}+1))
	start_port_client=$((${start_port_client}+1))
done;

wait ${sub_pid}
killall netserver

result="0"
for i in `echo ${all_result_files}`; do
	sub_result=`awk '/Throughput/ {getline; getline; getline; print " "$6}' ${i}`
	result=`echo "${result}+${sub_result}"|bc`
done;

echo $result


--=-iJ7pR5ZGKvuT2d2vXHGE--

