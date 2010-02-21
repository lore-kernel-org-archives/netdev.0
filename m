From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Sun, 21 Feb 2010 14:35:02 +0800
Message-ID: <4B80D416.7090207@redhat.com>
References: <1266532346-11604-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752925Ab0BUGbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 01:31:34 -0500
In-Reply-To: <1266532346-11604-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> The new function can be used to read/write large bitmaps via /proc. A
> comma separated range format is used for compact output and input
> (e.g. 1,3-4,10-10).
> 
> Writing into the file will first reset the bitmap then update it
> based on the given input.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> Cc: WANG Cong <amwang@redhat.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/linux/sysctl.h |    2 +
>  kernel/sysctl.c        |  122 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 124 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index f66014c..7bb5cb6 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -980,6 +980,8 @@ extern int proc_doulongvec_minmax(struct ctl_table *, int,
>  				  void __user *, size_t *, loff_t *);
>  extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
>  				      void __user *, size_t *, loff_t *);
> +extern int proc_do_large_bitmap(struct ctl_table *, int,
> +				void __user *, size_t *, loff_t *);
>  
>  /*
>   * Register a set of sysctl names by calling register_sysctl_table
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 5259727..ef2c13d 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2635,6 +2635,128 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
>  	return 0;
>  }
>  
> +/**
> + * proc_do_large_bitmap - read/write from/to a large bitmap
> + * @table: the sysctl table
> + * @write: %TRUE if this is a write to the sysctl file
> + * @buffer: the user buffer
> + * @lenp: the size of the user buffer
> + * @ppos: file position
> + *
> + * The bitmap is stored at table->data and the bitmap length (in bits)
> + * in table->maxlen.
> + *
> + * We use a range comma separated format (e.g. 1,3-4,10-10) so that
> + * large bitmaps may be represented in a compact manner. Writing into
> + * the file will clear the bitmap then update it with the given input.

My test shows it still accepts spaces, e.g.

echo '50000 50003 50005' > ip_local_reserved_ports

works same as

echo '50000,50003,50005' > ip_local_reserved_ports

Is this expected? We will only accept commas, right?


Also, if I write an invalid value, it does reject this, but the previous
value in that file is cleared, shouldn't we keep the previous one?

