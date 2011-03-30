From: Rob Landley <rlandley@parallels.com>
Subject: Re: 2.6.38 containers bug: Infinite loop in /proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 05:16:19 -0500
Message-ID: <4D9302F3.6080206@parallels.com>
References: <4D92E9DC.3070405@parallels.com> <20110330.020120.02272125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	<containers@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110330.020120.02272125.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/30/2011 04:01 AM, David Miller wrote:
> From: Rob Landley <rlandley@parallels.com>
> Date: Wed, 30 Mar 2011 03:29:16 -0500
> 
>> In the host context a find on /proc completes, but inside an lxc
>> container a find on /proc never completes, due to the endless loop in
>> the title.  (It's not a symlink, it seems to be a cross linked directory.)
>>
>> This is vanilla 2.6.38, I can attach my .config if you think it'd help.
>>  (The container's the lxc debian sid template but that's probably not
>> relevant.)
> 
> Please CC: netdev@vger.kernel.org when a bug might be related to
> networking, as is obviously the case here.
> 
> This bug should be fixed by the following patch:
> 
> --------------------
> commit 9d2a8fa96a44ba242de3a6f56acaef7a40a97b97
> Author: Eric W. Biederman <ebiederm@aristanetworks.com>
> Date:   Mon Mar 21 18:23:34 2011 -0700
> 
>     net ipv6: Fix duplicate /proc/sys/net/ipv6/neigh directory entries.
>     
>     When I was fixing issues with unregisgtering tables under /proc/sys/net/ipv6/neigh
>     by adding a mount point it appears I missed a critical ordering issue, in the
>     ipv6 initialization.  I had not realized that ipv6_sysctl_register is called
>     at the very end of the ipv6 initialization and in particular after we call
>     neigh_sysctl_register from ndisc_init.
>     
>     "neigh" needs to be initialized in ipv6_static_sysctl_register which is
>     the first ipv6 table to initialized, and definitely before ndisc_init.
>     This removes the weirdness of duplicate tables while still providing a
>     "neigh" mount point which prevents races in sysctl unregistering.
>     
>     This was initially reported at https://bugzilla.kernel.org/show_bug.cgi?id=31232
>     Reported-by: sunkan@zappa.cx
>     Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>


Yes, that fixed it.  Pinging the stable guys to make sure this goes in a
dot release.

Thanks,

Rob
