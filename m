From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Tue, 27 Mar 2012 17:55:19 -0400
Message-ID: <CAAsGZS75TStwzTsRnpMGMqPy=h1AoV5uKyguXa92LvAsG4BXOQ@mail.gmail.com>
References: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
	<CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
	<20120326152730.GA10212@localhost.localdomain>
	<CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS4Jqe5ZcZyGZjurmjBCgzj=+a0cgHAEwB+esXNoQ3P7NQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC1A0@ORSMSX105.amr.corp.intel.com>
	<20120327180501.GA3878@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DC68D@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS7+L5Y7Mo8pipJf=T6x9vTUAcTS93t=BGsmCUvA3T31Zw@mail.gmail.com>
	<CAAsGZS6=wCPKC_1HnXQNn=U=6h-akbWvLZ_9ztBjfva=DFmugQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC769@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63104 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2C0VzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 17:55:20 -0400
Received: by yhmm54 with SMTP id m54so358664yhm.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 14:55:20 -0700 (PDT)
In-Reply-To: <02874ECE860811409154E81DA85FBB580DC769@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 4:58 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:

>
> I think we could see contention regardless because the spinlock doesn't guarantee the ordering of who gets it next.
>
> I am not sure. But I will try and set something like this up. However, I do think that many get-set calls is pretty high for even a 'highly' loaded system. Though the buggy app for sure is possible.
>
> Here is what I am thinking as a test case. Linuxptp running normally with a higher sync rate than once per second, plus a 'buggy' app which will try to infinitely thread the gettime calls. I hope to have something like this working soon.
>

Agreed, we don't know who would grab the lock next. But with just one
app/process we may not be able to induce the contention because
process scheduling would come into play. A single process would only
get that much time slice. With multiple processes, you will be able to
schedule them on multiple CPUs and hence contend with the driver's
completion path because that is what a real-exploit would do.

make sure numactl is installed on your system. Within a shell script,
launch multiple instances of the process as follows:

#!/bin/bash

num_cpus=`cat /proc/cpuinfo |grep -i processor |wc -l`

for ((i=0; i<$num_cpus; i++))
do
  echo "Launching instance:$(($i+1))"
  numa_cmd="numactl --physcpubind=$i /path/to/buggy-app &"
  echo "executing numa-cmd:$numa_cmd"
  eval $numa_cmd
done


> - Jake

Chetan
