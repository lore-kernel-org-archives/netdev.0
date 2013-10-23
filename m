From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: -27% netperf TCP_STREAM regression by "tcp_memcontrol: Kill
 struct tcp_memcontrol"
Date: Wed, 23 Oct 2013 12:46:47 +0100
Message-ID: <20131023114647.GA30252@localhost>
References: <20131022214129.GB2715@localhost>
 <20131022.180023.1141845387743361648.davem@davemloft.net>
 <87k3h461ql.fsf@tw-ebiederman.twitter.com>
 <20131023061019.GA15698@localhost>
 <87a9i0l3v1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87a9i0l3v1.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 23, 2013 at 02:43:14AM -0700, Eric W. Biederman wrote:
> Fengguang Wu <fengguang.wu@intel.com> writes:
> 
> > On Tue, Oct 22, 2013 at 09:38:10PM -0700, Eric W. Biederman wrote:
> >> David Miller <davem@davemloft.net> writes:
> >> 
> >> > From: fengguang.wu@intel.com
> >> > Date: Tue, 22 Oct 2013 22:41:29 +0100
> >> >
> >> >> We noticed big netperf throughput regressions
> >> >> 
> >> >>     a4fe34bf902b8f709c63      2e685cad57906e19add7  
> >> >> ------------------------  ------------------------  
> >> >>                   707.40       -40.7%       419.60  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
> >> >>                  2775.60       -23.7%      2116.40  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
> >> >>                  3483.00       -27.2%      2536.00  TOTAL netperf.Throughput_Mbps
> >> >> 
> >> >> and bisected it to
> >> >> 
> >> >> commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
> >> >> Author: Eric W. Biederman <ebiederm@xmission.com>
> >> >> Date:   Sat Oct 19 16:26:19 2013 -0700
> >> >> 
> >> >>     tcp_memcontrol: Kill struct tcp_memcontrol
> >> >
> >> > Eric please look into this, I'd rather have a fix to apply than revert your
> >> > work.
> >> 
> >> Will do I expect some ordering changed, and that changed the cache line
> >> behavior.
> >> 
> >> If I can't find anything we can revert this one particular patch without
> >> affecting anything else, but it would be nice to keep the data structure
> >> smaller.
> >> 
> >> Fengguag what would I need to do to reproduce this?
> >
> > Eric, attached is the kernel config.
> >
> > We used these commands in the test:
> >
> >         netserver
> >         netperf -t TCP_STREAM -c -C -l 120      # repeat 64 times and get average

Sorry it's not about repeating, but running 64 netperf in parallel.
The number 64 is 2 times the number of logical CPUs.

> > btw, we've got more complete change set (attached) and also noticed
> > performance increase in the TCP_SENDFILE case:
> >
> >     a4fe34bf902b8f709c63      2e685cad57906e19add7
> > ------------------------  ------------------------
> >                   707.40       -40.7%       419.60  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
> >                  2572.20       -17.7%      2116.20  lkp-sb03/micro/netperf/120s-200%-TCP_MAERTS
> >                  2775.60       -23.7%      2116.40  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
> >                  1006.60       -54.4%       459.40  lkp-sbx04/micro/netperf/120s-200%-TCP_STREAM
> >                  3278.60       -25.2%      2453.80  lkp-t410/micro/netperf/120s-200%-TCP_MAERTS
> >                  1902.80       +21.7%      2315.00  lkp-t410/micro/netperf/120s-200%-TCP_SENDFILE
> >                  3345.40       -26.7%      2451.00  lkp-t410/micro/netperf/120s-200%-TCP_STREAM
> >                 15588.60       -20.9%     12331.40  TOTAL netperf.Throughput_Mbps
> 
> I have a second question.  Do you mount the cgroup filesystem?  Do you
> set memory.kmem.tcp.limit_in_bytes?

No I didn't mount cgroup at all.

> If you aren't setting any memory cgroup limits or creating any groups
> this change should not have had any effect whatsoever.  And you haven't
> mentioned it so I don't expect you are enabling the memory cgroup limits
> explicitly.
> 
> If you have enabled the memory cgroups can you please describe your
> configuration as that may play a significant role.
> 
> Eric
