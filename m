From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000 (found
 work-around)
Date: Wed, 31 May 2006 15:10:18 -0700
Message-ID: <20060531151018.17110684@localhost.localdomain>
References: <447DC830.4080201@candelatech.com>
	<447DD870.80107@intel.com>
	<447DD9B5.9050100@candelatech.com>
	<447DF085.2050604@candelatech.com>
	<447E0E69.3080006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25576 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965198AbWEaWKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 18:10:25 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <447E0E69.3080006@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 May 2006 14:45:13 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Ok, I think I found the problem.  It appears to be at least partially
> self-inflicted.  I was modifying the kernel buffer settings via /proc/*
> to improve performance.  I noticed that when I used kernel-defaults,
> the TCP connection hangs stopped (and ran ~20% slower).  My personal opinion
> is that this is still a bug somewhere in TCP, but at least I have a work-around.

If you set bogus values, you can end up consuming all the memory on your system.

> Since these settings appear somewhat delicate, it might be nice if
> the kernel could warn about configurations that could cause TCP deadlocks
> and such.
> 

There is little or no range checking on most all sysctl values. Whether or
not that is a good thing is debatable. 

> My old settings that exhibitted the problem were:
> 
> my $netdev_max_backlog = 5000;
This only matters for non-NAPI devices.

> my $wmem_max = 4096000;
> my $wmem_default = 128000;
> my $rmem_max = 8096000;
> my $rmem_default = 128000;
> 
> my $tcp_rmem_min     = 4096;
> my $tcp_rmem_default = 256000;
Receiver auto-tuning makes setting this unnecessary
in most cases. 

> my $tcp_rmem_max     = 30000000;
> 
> my $tcp_wmem_min     = 4096;
> my $tcp_wmem_default = 256000;

That's too big with current auto-tuning.

> my $tcp_wmem_max     = 30000000;
> 
> my $tcp_mem_lo       = 20000000;
> my $tcp_mem_pressure = 30000000;
> my $tcp_mem_high     = 60000000;
> 
> 
> The new settings that appear to work around the TCP connection hang,
> and still give decent performance are below.  Documentation being thin,
> I used the suggested values in Documentation/networking/ixgb.txt as
> hints:

Settings don't belong in this Documentation file because it a general
thing not specific to that hardware.


> my $netdev_max_backlog = 30000;
> my $wmem_max = 524287;
> my $wmem_default = 128000;
> my $rmem_max = 524287;
> my $rmem_default = 128000;
> 
> my $tcp_rmem_min     = 4096;
> my $tcp_rmem_default = 256000;
> my $tcp_rmem_max     = 5000000;
> 
> my $tcp_wmem_min     = 4096;
> my $tcp_wmem_default = 256000;
> my $tcp_wmem_max     = 5000000;
> 
> my $tcp_mem_lo       = 10000000;
> my $tcp_mem_pressure = 20000000;
> my $tcp_mem_high     = 30000000;
> 
> Thanks,
> Ben
> 
