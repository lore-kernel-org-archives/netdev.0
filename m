From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] sctp: fix a problem with net_namespace
Date: Tue, 28 Jan 2014 06:57:57 -0500
Message-ID: <20140128115757.GA5002@hmsreliant.think-freely.org>
References: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com>
 <20140127114904.GA17143@hmsreliant.think-freely.org>
 <52E766B8.3090406@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45447 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbaA1L6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 06:58:13 -0500
Content-Disposition: inline
In-Reply-To: <52E766B8.3090406@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 04:13:44PM +0800, Wang Weidong wrote:
> On 2014/1/27 19:49, Neil Horman wrote:
> > On Mon, Jan 27, 2014 at 11:49:01AM +0800, Wang Weidong wrote:
> >> fix a problem with net_namespace, and optimize
> >> the sctp_sysctl_net_register.
> >>
> >> Wang Weidong (2):
> >>   sctp: fix a missed .data initialization
> >>   sctp: optimize the sctp_sysctl_net_register
> >>
> >>  net/sctp/sysctl.c | 17 ++++++++++-------
> >>  1 file changed, 10 insertions(+), 7 deletions(-)
> >>
> >> -- 
> >> 1.7.12
> >>
> >>
> >>
> > I don't see that either of these patches are needed.  In sctp_init_net, the
> > sctp_hmac_alg pointer gets initalized before calling sctp_sysctl_net_register,
> > and sctp_proc_do_hmac_alg is written to specifically expect NULL values, so this
> > code may change behavior regarding default cookie selection.
> > 
> Hi Neil,
> 
> Here, I think the sctp_proc_do_hmac_alg will be called only when we change the 
> /proc/sys/net/cookie_hmac_alg. So add the .data won't effect the default value.
> and the data isn't equal to the "cookie_hmac_alg"?
> 
> > This was coded so that poniters to entires in the string table could be used,
> > rather than needing to allocate or maintain character buffers.  That said, it
> > does look like that for loop in sctp_sysctl_register_table might compute an odd
> > offset when cloning the table.  I think the right fix for that is likely to just
> > move the sysctl value initalization in sctp_init_net to below the sysctl
> > register function.
> > 
> > Neil
> > 
> 
> I found the problem is that:
> I use "ip netns add netns1/netns2"
> In any netns(netns1 or netns2 or init_net) when I change the value of the entry
> such as "addip_enable" "max_autoclose" which after the cookie_hmac_alg (contain it),
> and the other netns will be effected.
> 
> In sctp_sysctl_net_register, kmemdup does cloning the table. The offset of netns1 and
> init_net's clt_table.data is the same as two netns offset. So the for(){...} would do
> add the offset for every clt_table.data.
> 
> The code:
> 	for (i = 0; table[i].data; i++)
> 		table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
> 
> And I add a pr_info into the for(){...} in sctp_sysctl_net_register and only print 7 times for each ns.
> 7 is the index of "cookie_preserve_enable" which before the "cookie_hmac_alg". 
> 
> As the "cookie_hmac_alg" data is NULL, so we can't add offset to the rest, and all the netns use the same
> address of clt_table entry after the "cookie_hmac_alg".
> 
> So I think only "move the sysctl value initalization in sctp_init_net to below the sysctl
> register function" won't solve the problem, because the problem is at the for() {...}.
> 
I'm sorry, you're right, the kmemdup duplicates the table, not the structure in
which the table points to with its .data pointers.  I was looking at it
backwards.

> Is there something wrong?
> 
> The next patch is that, the sctp_net_table is for init_net, So when load the sctp module, we needn't
> to do the cloning tables for init_net again. And I found the ipv4 do it in the same way.
> 
> I have a doubt : how can I rmmod the sctp? only add '-f' ? If I do "rmmod -f sctp", I will get the
> log by dmesg: "Disabling lock debugging due to kernel taint"
> 
I don't know, sounds like a bug, check the log to see what tainted the kernel
during removal.

Regards
Neil

> Regards,
> Wang
> 
> 
> > 
> > 
> 
> 
> 
