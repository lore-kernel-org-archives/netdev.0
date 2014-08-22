From: "Zhang Haoyu" <zhanghy@sangfor.com>
Subject: Re: [PATCH] vhost: Add polling mode
Date: Fri, 22 Aug 2014 18:01:52 +0800
Message-ID: <201408221801508088964@sangfor.com>
References: <1407659404-razya@il.ibm.com>,
 <20140810083035.0CF58380729@moren.haifa.ibm.com>,
 <53F45F3C.5000207@de.ibm.com>,
 <OF9D20825B.8FFA2829-ONC2257D3B.004A777F-C2257D3B.004C47BC@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: "abel.gordon" <abel.gordon@gmail.com>,
	"Alex Glikson" <GLIKSON@il.ibm.com>,
	"Eran Raichstein" <ERANRA@il.ibm.com>,
	"Joel Nider" <JOELN@il.ibm.com>, "kvm" <kvm@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"mst" <mst@redhat.com>, "netdev" <netdev@vger.kernel.org>,
	"virtualization" <virtualization@lists.linux-foundation.org>,
	"Yossi Kuperman1" <YOSSIKU@il.ibm.com>
To: "Zhang Haoyu" <zhanghy@sangfor.com>,
	"Razya Ladelsky" <RAZYA@il.ibm.com>,
	"Christian Borntraeger" <borntraeger@de.ibm.com>,
	"mashirle" <mashirle@us.ibm.com>,
	"Jason Wang" <jasowang@redhat.com>,
	"Michael S.Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> > 
>>> > Results:
>>> > 
>>> > Netperf, 1 vm:
>>> > The polling patch improved throughput by ~33% (1516 MB/sec -> 2046 MB/sec).
>>> > Number of exits/sec decreased 6x.
>>> > The same improvement was shown when I tested with 3 vms running netperf
>>> > (4086 MB/sec -> 5545 MB/sec).
>>> > 
>>> > filebench, 1 vm:
>>> > ops/sec improved by 13% with the polling patch. Number of exits 
>>> was reduced by
>>> > 31%.
>>> > The same experiment with 3 vms running filebench showed similar numbers.
>>> > 
>>> > Signed-off-by: Razya Ladelsky <razya@il.ibm.com>
>>> 
>>> Gave it a quick try on s390/kvm. As expected it makes no difference 
>>> for big streaming workload like iperf.
>>> uperf with a 1-1 round robin got indeed faster by about 30%.
>>> The high CPU consumption is something that bothers me though, as 
>>> virtualized systems tend to be full.
>>> 
>>> 
>>
>>Thanks for confirming the results!
>>The best way to use this patch would be along with a shared vhost thread 
>>for multiple
>>devices/vms, as described in:
>>http://domino.research.ibm.com/library/cyberdig.nsf/1e4115aea78b6e7c85256b360066f0d4/479e3578ed05bfac85257b4200427735!OpenDocument
>>This work assumes having a dedicated I/O core where the vhost thread 
>>serves multiple vms, which 
>>makes the high cpu utilization less of a concern. 
>>
>Hi, Razya, Shirley
>I am going to test the combination of 
>"several (depends on total number of cpu on host, e.g.,  total_number * 1/3) vhost threads server all VMs" and "vhost: add polling mode",
>now I get the patch "http://thread.gmane.org/gmane.comp.emulators.kvm.devel/88682/focus=88723" posted by Shirley,
>any update to this patch?
>
>And, I want to make a bit change on this patch, create total_cpu_number * 1/N(N={3,4}) vhost threads instead of per-cpu vhost thread to server all VMs,
Just like xen netback threads, whose number is equal to num_online_cpus on Dom0, 
but for kvm host, I think per-cpu vhost thread is too many.
>any ideas?
>
>Thanks,
>Zhang Haoyu
>>
>>
>>> > +static int poll_start_rate = 0;
>>> > +module_param(poll_start_rate, int, S_IRUGO|S_IWUSR);
>>> > +MODULE_PARM_DESC(poll_start_rate, "Start continuous polling of 
>>> virtqueue when rate of events is at least this number per jiffy. If 
>>> 0, never start polling.");
>>> > +
>>> > +static int poll_stop_idle = 3*HZ; /* 3 seconds */
>>> > +module_param(poll_stop_idle, int, S_IRUGO|S_IWUSR);
>>> > +MODULE_PARM_DESC(poll_stop_idle, "Stop continuous polling of 
>>> virtqueue after this many jiffies of no work.");
>>> 
>>> This seems ridicoudly high. Even one jiffie is an eternity, so 
>>> setting it to 1 as a default would reduce the CPU overhead for most cases.
>>> If we dont have a packet in one millisecond, we can surely go back 
>>> to the kick approach, I think.
>>> 
>>> Christian
>>> 
>>
>>Good point, will reduce it and recheck.
>>Thank you,
>>Razya

