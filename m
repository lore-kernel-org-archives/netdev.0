From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: care and feeding of netperf (Re: Mainline kernel OLTP
	performance update)
Date: Sat, 24 Jan 2009 11:03:00 +0800
Message-ID: <1232766180.11429.202.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>
	 <200901231933.10101.nickpiggin@yahoo.com.au>
	 <1232701348.11429.170.camel@ymzhang>  <497A0F27.3030801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
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
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:39004 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752108AbZAXDDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 22:03:18 -0500
In-Reply-To: <497A0F27.3030801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-23 at 10:40 -0800, Rick Jones wrote:
> > 3) ./start_netperf_udp_v4.sh 8 #Assume your machine has 8 logical cpus.
> 
> Some comments on the script:
Thanks. I wanted to run the testing to get result quickly as long as
the result has no big fluctuation.

> 
> > #!/bin/sh
> > 
> > PROG_DIR=/home/ymzhang/test/netperf/src
> > date=`date +%H%M%N`
> > #PROG_DIR=/root/netperf/netperf/src
> > client_num=$1
> > pin_cpu=$2
> > 
> > start_port_server=12384
> > start_port_client=15888
> > 
> > killall netserver
> > ${PROG_DIR}/netserver
> > sleep 2
> 
> Any particular reason for killing-off the netserver daemon?
I'm not sure if prior running might leave any impact on later running, so
just kill netserver.

> 
> > if [ ! -d result ]; then
> >         mkdir result
> > fi
> > 
> > all_result_files=""
> > for i in `seq 1 ${client_num}`; do
> >         if [ "${pin_cpu}" == "pin" ]; then
> >                 pin_param="-T ${i} ${i}"
> 
> The -T option takes arguments of the form:
> 
> N   - bind both netperf and netserver to core N
> N,  - bind only netperf to core N, float netserver
>   ,M - float netperf, bind only netserver to core M
> N,M - bind netperf to core N and netserver to core M
> 
> Without a comma between N and M knuth only knows what the command line parser 
> will do :)
> 
> >         fi
> >         result_file=result/netperf_${start_port_client}.${date}
> >         #./netperf -t UDP_STREAM -l 60 -H 127.0.0.1 -- -P 15895 12391 -s 32768 -S 32768 -m 4096
> >         #./netperf -t UDP_STREAM -l 60 -H 127.0.0.1 -i 50 3 -I 99 5 -- -P 12384 12888 -s 32768 -S 32768 -m 4096
> >         #${PROG_DIR}/netperf -p ${port_num} -t TCP_RR -l 60 -H 127.0.0.1 ${pin_param} -- -r 1,1 >${result_file} &
> >         ${PROG_DIR}/netperf -t UDP_STREAM -l 60 -H 127.0.0.1 ${pin_param} -- -P ${start_port_client} ${start_port_server} -s 32768 -S 32768 -m 4096 >${result_file}  &
> 
> Same thing here for the -P option - there needs to be a comma between the two 
> port numbers otherwise, the best case is that the second port number is ignored. 
>   Worst case is that netperf starts doing knuth only knows what.
Thanks.

> 
> 
> To get quick profiles, that form of aggregate netperf is OK - just the one 
> iteration with background processes using a moderatly long run time.  However, 
> for result reporting, it is best to (ab)use the confidence intervals 
> functionality to try to avoid skew errors.
Yes. My formal testing uses -i 50. I just wanted a quick testing. If I need
finer-tuning or investigation, I would turn on more options.

>   I tend to add-in a global -i 30 
> option to get each netperf to repeat its measurments 30 times.  That way one is 
> reasonably confident that skew issues are minimized.
> 
> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance
> 
> And I would probably add the -c and -C options to have netperf report service 
> demands.
Yes. That's good. I'm used to start vmstat or mpstat to monitor cpu utilization
in real time.

> 
> 
> >         sub_pid="${sub_pid} `echo $!`"
> >         port_num=$((${port_num}+1))
> >         all_result_files="${all_result_files} ${result_file}"
> >         start_port_server=$((${start_port_server}+1))
> >         start_port_client=$((${start_port_client}+1))
> > done;
> > 
> > wait ${sub_pid}
> > killall netserver
> > 
> > result="0"
> > for i in `echo ${all_result_files}`; do
> >         sub_result=`awk '/Throughput/ {getline; getline; getline; print " "$6}' ${i}`
> >         result=`echo "${result}+${sub_result}"|bc`
> > done;
> 
> The documented-only-in-source :( "omni" tests in top-of-trunk netperf:
> 
> http://www.netperf.org/svn/netperf2/trunk
> 
> ./configure --enable-omni
> 
> allow one to specify which result values one wants, in which order, either as 
> more or less traditional netperf output (test-specific -O), CSV (test-specific 
> -o) or keyval (test-specific -k).  All three take an optional filename as an 
> argument with the file containing a list of desired output values.  You can give 
> a "filename" of '?' to get the list of output values known to that version of 
> netperf.
> 
> Might help simplify parsing and whatnot.
Yes, it does.

> 
> happy benchmarking,
> 
> rick jones
Thanks again. I learned a lot.

> 
> > 
> > echo $result
> 
> > 

