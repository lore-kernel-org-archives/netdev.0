From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/6] RDS: don't trust the LL_SEND_FULL bit
Date: Thu, 02 Apr 2015 17:06:24 +0300
Message-ID: <551D4CE0.8090706@cogentembedded.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com> <dbc7c4e9d12f373c971c5b0d0e5936abb345ea7c.1427936719.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dbc7c4e9d12f373c971c5b0d0e5936abb345ea7c.1427936719.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 4/2/2015 4:50 PM, Sowmini Varadhan wrote:

> We are seeing connections stuck with the LL_SEND_FULL bit getting
> set and never cleared.  This changes RDS to stop trusting the
> LL_SEND_FULL bit and kick krdsd after any time we
> see -ENOMEM from the ring allocation code.

> Original patch by Chris Mason

> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
> ---
>   net/rds/send.c    |   11 +++++++----
>   net/rds/threads.c |    2 ++
>   2 files changed, 9 insertions(+), 4 deletions(-)

> diff --git a/net/rds/send.c b/net/rds/send.c
> index 23135a8..9d9c90c 100644
> --- a/net/rds/send.c
> +++ b/net/rds/send.c
> @@ -1108,8 +1108,10 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
>   	 */
>   	rds_stats_inc(s_send_queued);
>
> -	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
> -		rds_send_xmit(conn);
> +	ret = rds_send_xmit(conn);
> +	if (ret == -ENOMEM || ret == -EAGAIN)
> +		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
> +

    No need for extra new line here.

>
>   	rds_message_put(rm);
>   	return payload_len;
[...]

WBR, Sergei
