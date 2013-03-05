From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Tue, 05 Mar 2013 10:05:06 +0100
Message-ID: <5135B542.8020905@fold.natur.cuni.cz>
References: <51004F2D.9000405@fold.natur.cuni.cz> <1359043367-30180-1-git-send-email-vyasevich@gmail.com> <20130127.193511.2294954038548420781.davem@davemloft.net> <87libe3w69.fsf@xmission.com> <87obgayoo8.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	stable@kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fold.natur.cuni.cz ([195.113.57.32]:41481 "HELO
	fold.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752997Ab3CEJFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 04:05:15 -0500
In-Reply-To: <87obgayoo8.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  this is to let you know that this patch is still not in stable.
I just fetched 3.7.10 and reproduced the original problem.
I bet this slipped through because there was an initial patch from Vlad Yasevich
on Jan 24, then a follow-up patch from Eric Biedermann which did not compile and
finally a v2 patch from E. B which did compile.

  For me the last, v2 patch applies (with some hunk) to 3.7.10 and compiles
fine.

Thanks,
martin

Eric W. Biederman wrote:
> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Thu, 24 Jan 2013 11:02:47 -0500
> 
> Per-net sysctl table needs to be explicitly freed at
> net exit.  Otherwise we see the following with kmemleak:
> 
> unreferenced object 0xffff880402d08000 (size 2048):
>   comm "chrome_sandbox", pid 18437, jiffies 4310887172 (age 9097.630s)
>   hex dump (first 32 bytes):
>     b2 68 89 81 ff ff ff ff 20 04 04 f8 01 88 ff ff  .h...... .......
>     04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff815b4aad>] kmemleak_alloc+0x21/0x3e
>     [<ffffffff81110352>] slab_post_alloc_hook+0x28/0x2a
>     [<ffffffff81113fad>] __kmalloc_track_caller+0xf1/0x104
>     [<ffffffff810f10c2>] kmemdup+0x1b/0x30
>     [<ffffffff81571e9f>] sctp_sysctl_net_register+0x1f/0x72
>     [<ffffffff8155d305>] sctp_net_init+0x100/0x39f
>     [<ffffffff814ad53c>] ops_init+0xc6/0xf5
>     [<ffffffff814ad5b7>] setup_net+0x4c/0xd0
>     [<ffffffff814ada5e>] copy_net_ns+0x6d/0xd6
>     [<ffffffff810938b1>] create_new_namespaces+0xd7/0x147
>     [<ffffffff810939f4>] copy_namespaces+0x63/0x99
>     [<ffffffff81076733>] copy_process+0xa65/0x1233
>     [<ffffffff81077030>] do_fork+0x10b/0x271
>     [<ffffffff8100a0e9>] sys_clone+0x23/0x25
>     [<ffffffff815dda73>] stub_clone+0x13/0x20
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> I fixed the spelling of sysctl_header so the code actually
> compiles. -- EWB.
> 
> Reported-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> 
> The typo is fixed in the patch this time in addition to my test
> tree.
> 
>  net/sctp/sysctl.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 043889a..bf3c6e8 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -366,7 +366,11 @@ int sctp_sysctl_net_register(struct net *net)
>  
>  void sctp_sysctl_net_unregister(struct net *net)
>  {
> +	struct ctl_table *table;
> +
> +	table = net->sctp.sysctl_header->ctl_table_arg;
>  	unregister_net_sysctl_table(net->sctp.sysctl_header);
> +	kfree(table);
>  }
>  
>  static struct ctl_table_header * sctp_sysctl_header;
> 
