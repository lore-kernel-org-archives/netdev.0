From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 6/9] sctp: Move the percpu sockets counter out
 of sctp_proc_init
Date: Tue, 14 Aug 2012 23:19:45 -0400
Message-ID: <502B1551.1080706@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> <87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com> <87393zq2rb.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87393zq2rb.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2012 02:44 PM, Eric W. Biederman wrote:
>
> The percpu sctp socket counter has nothing at all to do with the sctp
> proc files, and having it in the wrong initialization is confusing,
> and makes network namespace support a pain.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>   net/sctp/protocol.c |   13 +++++++------
>   1 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 6193d20..976d765 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -93,8 +93,6 @@ int sysctl_sctp_wmem[3];
>   /* Set up the proc fs entry for the SCTP protocol. */
>   static __init int sctp_proc_init(void)
>   {
> -	if (percpu_counter_init(&sctp_sockets_allocated, 0))
> -		goto out_nomem;
>   #ifdef CONFIG_PROC_FS
>   	if (!proc_net_sctp) {
>   		proc_net_sctp = proc_mkdir("sctp", init_net.proc_net);
> @@ -125,12 +123,9 @@ out_snmp_proc_init:
>   		remove_proc_entry("sctp", init_net.proc_net);
>   	}
>   out_free_percpu:
> -	percpu_counter_destroy(&sctp_sockets_allocated);
>   #else
>   	return 0;
>   #endif /* CONFIG_PROC_FS */
> -
> -out_nomem:
>   	return -ENOMEM;
>   }
>
> @@ -151,7 +146,6 @@ static void sctp_proc_exit(void)
>   		remove_proc_entry("sctp", init_net.proc_net);
>   	}
>   #endif
> -	percpu_counter_destroy(&sctp_sockets_allocated);
>   }
>
>   /* Private helper to extract ipv4 address and stash them in
> @@ -1261,6 +1255,10 @@ SCTP_STATIC __init int sctp_init(void)
>   	if (status)
>   		goto err_init_mibs;
>
> +	status = percpu_counter_init(&sctp_sockets_allocated, 0);
> +	if (status)
> +		goto err_percpu_counter_init;
> +
>   	/* Initialize proc fs directory.  */
>   	status = sctp_proc_init();
>   	if (status)
> @@ -1481,6 +1479,8 @@ err_ahash_alloc:
>   	sctp_dbg_objcnt_exit();
>   	sctp_proc_exit();
>   err_init_proc:
> +	percpu_counter_destroy(&sctp_sockets_allocated);
> +err_percpu_counter_init:
>   	cleanup_sctp_mibs();
>   err_init_mibs:
>   	kmem_cache_destroy(sctp_chunk_cachep);
> @@ -1521,6 +1521,7 @@ SCTP_STATIC __exit void sctp_exit(void)
>   			     sizeof(struct sctp_bind_hashbucket)));
>
>   	sctp_dbg_objcnt_exit();
> +	percpu_counter_destroy(&sctp_sockets_allocated);
>   	sctp_proc_exit();
>   	cleanup_sctp_mibs();
>
>
